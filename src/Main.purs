module Client where

import Prelude
import App.Effects (AppEffects)
import App.Events (Event(..), foldp)
import App.Routes (match)
import App.State (State, init)
import App.View.Layout (view)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import DOM.HTML (window)
import Pux (App, CoreEffects, start)
import Pux.DOM.Events (DOMEvent)
import Pux.DOM.History (sampleURL)
import Pux.Renderer.React (renderToDOM)
import Signal ((~>))

type TodoApp = App (DOMEvent -> Event) Event State

main :: ∀ fx. String -> State -> Eff (CoreEffects (AppEffects (exception :: EXCEPTION | fx))) TodoApp
main url state = do
  -- | Create a signal of URL changes.
  urlSignal <- sampleURL =<< window

  -- | Map a signal of URL changes to PageView actions.
  let routeSignal = urlSignal ~> \r -> PageView (match r)

  app <- start
    { initialState: state
    , view
    , foldp
    , inputs: [routeSignal] }

  renderToDOM "#app" app.markup app.input

  pure app

initialState :: State
initialState = init "/"
