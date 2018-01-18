module DataHaskell.Prelude
  ( module Export
  , AppConfig(..)
  , AppT(..)
  , App
  , DeployEnvironment(..)
  , (&)
  , runDb
  )
where

import Prelude as Export

import Control.Monad.Logger as Export
import Control.Monad.Reader as Export
import Control.Monad.Except as Export
import Data.Function ((&))
import Data.Maybe as Export
import Data.Monoid as Export
import Data.Vector as Export (Vector)

import Database.Persist.Postgresql
import Servant as Export
import Servant.HTML.Lucid as Export
import Data.Text as Export (Text)
import GitHub.Auth as GitHub


-- | On which environment are we running on
data DeployEnvironment
  = Dev
  | Production
  | Test
  deriving (Eq, Show, Read)


-- | All the global configuration for the App
data AppConfig = AppConfig
  { dataHaskellPool        :: ConnectionPool
  , dataHaskellEnvironment :: DeployEnvironment
  , dataHaskellAuth        :: Maybe GitHub.Auth
  }


-- | This type represents an environment which is
-- the minimum that we need to run our application.
-- We require a 'Reader' so we can access our 'AppConfig'
-- from everywhere.
-- 'ExceptT ServantErr' is the environment of 'Servant'.
newtype AppT monad return = AppT
  { runApp :: ReaderT AppConfig (ExceptT ServantErr monad) return
  } deriving ( Functor
             , Applicative
             , Monad
             , MonadReader AppConfig
             , MonadError ServantErr
             , MonadIO
             )


-- | We specialize our type to 'IO' as it is where we
-- will execute everything.
type App = AppT IO


runDb :: (MonadReader AppConfig m, MonadIO m) => SqlPersistT IO b -> m b
runDb query = do
    pool <- asks dataHaskellPool
    liftIO $ runSqlPool query pool
