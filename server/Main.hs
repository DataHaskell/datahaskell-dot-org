{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import DataHaskell.Prelude

import Data.ByteString.Char8
import Text.Read
import System.Environment

import qualified DataHaskell.App as App


fromEnvironmentVariableOrElse :: Read a => String -> a -> IO a
fromEnvironmentVariableOrElse s def = do
  envString <- lookupEnv s
  let env = envString >>= readMaybe
  return $ maybe def id env


getToken :: IO (Maybe ByteString)
getToken = do
  token <- lookupEnv "DH_GITHUB_TOKEN"
  return (pack <$> token)


main :: IO ()
main = do
  token <- getToken
  env <- "DH_ENV" `fromEnvironmentVariableOrElse` Dev
  port <- "PORT" `fromEnvironmentVariableOrElse` 8080
  App.run token env port
