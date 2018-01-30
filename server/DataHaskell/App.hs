{-# LANGUAGE OverloadedStrings #-}
module DataHaskell.App
  (DataHaskell.App.run)
where

import DataHaskell.Prelude
import Control.Category ((<<<), (>>>))
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BS

import Database.Persist.Postgresql
import Network.Wai.Handler.Warp as Warp (run)
import Servant.Server
import Servant.Utils.StaticFiles
import Web.Heroku
import qualified Data.Text as Text
import GitHub.Auth as GitHub

import DataHaskell.App.Routes
import qualified DataHaskell.App.Home.Models.TilPost as TilPost

type AppAPI = Routes
  :<|> "static" :> Raw

app :: AppConfig -> Application
app cfg = serve (Proxy :: Proxy AppAPI) (appToServer cfg)

appToServer :: AppConfig -> Server AppAPI
appToServer cfg = enter (convertApp cfg >>> NT Handler) routes :<|> serveDirectoryWebApp "static"

convertApp :: AppConfig -> AppT monad :~> ExceptT ServantErr monad
convertApp cfg = runReaderTNat cfg <<< NT runApp


makePool :: ByteString -> Int -> IO ConnectionPool
makePool connString poolCapacity = runStdoutLoggingT $
  createPostgresqlPool connString poolCapacity


devInitContext :: Maybe GitHub.Auth -> IO AppConfig
devInitContext auth = do
  cs <- lookupEnv "PSQL_CONN_STRING"
  let connString = maybe (error "PSQL_CONN_STRING is undefined") id cs
  pool <- makePool (BS.pack connString) poolCapacity
  runSqlPool TilPost.doMigrations pool
  return $ AppConfig
    { dataHaskellPool = pool
    , dataHaskellEnvironment = Dev
    , dataHaskellAuth = auth
    }

herokuInitContext :: Maybe GitHub.Auth -> IO AppConfig
herokuInitContext auth = do
  conn <- dbConnParams
  let poolCapacity = 10
  let connString = unwords $ map (\(k, v) -> Text.unpack k <> "=" <> Text.unpack v) conn
  pool <- makePool (BS.pack connString) poolCapacity
  runSqlPool TilPost.doMigrations pool
  return $ AppConfig
    { dataHaskellPool = pool
    , dataHaskellEnvironment = Production
    , dataHaskellAuth = auth
    }


initContext :: DeployEnvironment -> Maybe GitHub.Auth -> IO AppConfig
initContext Production = herokuInitContext
initContext _ = devInitContext


run :: Maybe ByteString -> DeployEnvironment -> Int -> IO ()
run ghToken env port = do
  putStrLn $ "Running app on port " <> show port
  ctx <- initContext env (GitHub.OAuth <$> ghToken)
  Warp.run port $
    app ctx
