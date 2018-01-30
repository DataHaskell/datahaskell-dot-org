module DataHaskell.Common where

import Miso
import Miso.String

data Model = Model
  { modelUri :: URI
  , modelMsg :: String
  }

data Action
  = ServerMessage String
  | ChangeURI URI
  | HandleURI URI
  | NoOp
  deriving (Show, Eq)
