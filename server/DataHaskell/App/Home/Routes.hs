module DataHaskell.App.Home.Routes
  (Routes, routes)
where

import DataHaskell.Prelude

import DataHaskell.App.Home.Models.Page as Page
import DataHaskell.App.Home.Controllers.Page as Page
import DataHaskell.App.Home.View ()

type Routes
  = Get '[HTML] Page

routes = Page.controller

