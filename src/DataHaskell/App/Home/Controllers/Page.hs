module DataHaskell.App.Home.Controllers.Page
  ( controller )
where

import DataHaskell.Prelude

import DataHaskell.App.Home.Models.Page


controller :: App Page
controller = pure Page
