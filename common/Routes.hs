module DataHaskell.Routes where

import Data.Proxy

import Servant.API


type ClientRoutes = Home

type Home = View Action
