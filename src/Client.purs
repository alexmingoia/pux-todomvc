module Client where

import App.Effects (AppEffects)
import App.Routes (match)
import App.State (State, init)
import App.Events (Event(..), foldp)
import App.View.Layout (view)
import Control.Bind ((=<<), bind)
import Control.Monad.Eff (Eff)
import DOM.HTML (window)
import DOM.WebStorage (getLocalStorage)
import DOM.WebStorage.JSON (getItem, setItem)
import Data.Argonaut (Json, decodeJson)
import Data.Either (either)
import Data.Function (id, ($))
import Data.Generic (class Generic)
import Data.Maybe (maybe)
import Data.Unit (Unit)
import Pux (CoreEffects, start)
import Pux.DOM.History (sampleURL)
import Pux.Renderer.React (renderToDOM)
import Signal (runSignal, (~>))

data LocalStorageKey a = LocalStorageKey

derive instance genericLocalStorageKey :: Generic (LocalStorageKey a)

main :: ∀ fx. String -> State -> Eff (CoreEffects (AppEffects fx)) Unit
main url state = do
  -- | Fetch previous state from localStorage
  localStorage <- getLocalStorage
  stored_state <- getItem localStorage LocalStorageKey

  -- | Create a signal of URL changes.
  urlSignal <- sampleURL =<< window

  -- | Map a signal of URL changes to PageView actions.
  let routeSignal = urlSignal ~> \r -> PageView (match r)

  app <- start
    { initialState: maybe state (\s -> readState s) stored_state
    , view
    , foldp
    , inputs: [routeSignal] }

  renderToDOM "#app" app.markup app.input

  -- | Persist state to localStorage
  runSignal $ app.state ~> \st ->
    setItem localStorage LocalStorageKey st

readState :: Json -> State
readState json = either (\_ -> init "/") id $ decodeJson json
