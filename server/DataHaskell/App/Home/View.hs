module DataHaskell.App.Home.View where

import DataHaskell.Prelude

import Cheapskate
import Cheapskate.Lucid
import Lucid

import DataHaskell.App.Home.Models.Page
import DataHaskell.App.Home.Models.TilPost


instance ToHtml Page where
  toHtmlRaw = toHtml
  toHtml page = do
    head_ $ do
      title_ "dataHAskell"
      meta_
        [ name_ "viewport", content_ "width=device-width, initial-scale=1"]
    body_ $ do
      h1_ "Welcome"
      p_ "to dataHaskell"
