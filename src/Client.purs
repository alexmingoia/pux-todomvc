module Client where

import App.Effects (AppEffects)
import App.Events (Event(..), foldp)
import App.Routes (match)
import App.State (State, init)
import App.View.Layout (view)
import Control.Bind (bind)
import Control.Monad.Eff (Eff)
import DOM.HTML (window)
import DOM.HTML.Window (localStorage)
import DOM.WebStorage.Storage (getItem, setItem)
import Data.Argonaut (Json, decodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Either (Either(..), either)
import Data.Function (id, ($))
import Data.Functor ((<$>))
import Data.Maybe (Maybe(Just, Nothing))
import Data.Nullable (toMaybe)
import Data.Show (show)
import Data.Unit (Unit)
import Pux (CoreEffects, start)
import Pux.DOM.History (sampleURL)
import Pux.Renderer.React (renderToDOM)
import Signal (runSignal, (~>))

main :: ∀ fx. String -> State -> Eff (CoreEffects (AppEffects fx)) Unit
main url state = do
  win <- window
  -- | Fetch previous state from localStorage
  storage <- localStorage win
  stored_state_json <- getItem "pux:state" storage
  let initialState = case (jsonParser <$> toMaybe stored_state_json) of
        Nothing -> state
        Just (Left _) -> state
        Just (Right json) -> readState json

  -- | Create a signal of URL changes.
  urlSignal <- sampleURL win

  -- | Map a signal of URL changes to PageView actions.
  let routeSignal = urlSignal ~> \r -> PageView (match r)

  app <- start
    { initialState
    , view
    , foldp
    , inputs: [routeSignal] }

  renderToDOM "#app" app.markup app.input

  -- | Persist state to localStorage
  runSignal $ app.state ~> \st ->
    setItem "pux:state" (show (encodeJson st)) storage

readState :: Json -> State
readState json = either (\_ -> init "/") id $ decodeJson json
