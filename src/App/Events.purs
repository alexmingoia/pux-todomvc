module App.Events where

import App.Effects (AppEffects)
import App.Routes (Route, match)
import App.State (State(..), Todo(..))
import Control.Applicative (pure)
import Control.Bind ((=<<), bind)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Except (runExcept)
import DOM.Event.Event (preventDefault)
import DOM.Event.KeyboardEvent (eventToKeyboardEvent, key)
import DOM.HTML (window)
import DOM.HTML.History (DocumentTitle(..), URL(..), pushState)
import DOM.HTML.Window (history)
import Data.Array (filter, last, snoc)
import Data.BooleanAlgebra (not)
import Data.Either (either)
import Data.Eq ((==), (/=))
import Data.Foreign (toForeign)
import Data.Function (const, flip, ($))
import Data.Functor (map)
import Data.Maybe (Maybe(..), maybe)
import Data.Ring ((+))
import Pux (EffModel, noEffects, onlyEffects)
import Pux.DOM.Events (DOMEvent, targetValue)

type TodoId = Int

data Event
  = PageView Route
  | Navigate String DOMEvent
  | NewTodoInput DOMEvent
  | TodoInput TodoId DOMEvent
  | ToggleEditing TodoId DOMEvent
  | ToggleCompleted TodoId DOMEvent
  | ToggleAllCompleted
  | RemoveCompleted
  | RemoveTodo TodoId DOMEvent

foldp :: ∀ fx. Event -> State -> EffModel State Event (AppEffects fx)
foldp (PageView route) (State st) =
  noEffects $ State st { route = route, loaded = true }

foldp (Navigate url ev) state =
  onlyEffects state [ do
    liftEff do
      preventDefault ev
      h <- history =<< window
      pushState (toForeign {}) (DocumentTitle "") (URL url) h
    pure $ Just $ PageView (match url)
  ]

foldp (NewTodoInput ev) (State st) = noEffects $ State
  if (eventToKeyPressed ev) == "Enter"
    then st
      { newTodo = ""
      , todos = snoc st.todos $ Todo
        { id: maybe 1 (\(Todo todo) -> todo.id + 1) $ last st.todos
        , text: st.newTodo
        , completed: false
        , editing: false
        , newText: st.newTodo
        }
      }
    else st { newTodo = targetValue ev }

foldp (TodoInput id ev) (State st) = noEffects $
  case eventToKeyPressed ev of
    "Enter" -> State st
      { todos = flip map st.todos \(Todo t) ->
          if t.id == id
             then (Todo t { text = t.newText, editing = false })
             else (Todo t)
      }
    "Escape" -> State st
      { todos = flip map st.todos \(Todo t) ->
          if t.id == id
             then (Todo t { newText = t.text, editing = false })
             else (Todo t)
      }
    _ -> State st
      { todos = flip map st.todos \(Todo t) ->
          if t.id == id then (Todo t { newText = targetValue ev })
                        else (Todo t)
      }

foldp (ToggleEditing id ev) (State st) =
  noEffects $ State st
    { todos = flip map st.todos \(Todo t) ->
        if not t.completed then
          if t.id == id
             then (Todo t { newText = t.text, editing = not t.editing })
             else (Todo t { editing = false })
          else (Todo t { editing = false })
    }

foldp (ToggleCompleted id ev) (State st) = noEffects $ State st
  { todos = flip map st.todos \(Todo t) ->
      if t.id == id then (Todo t { completed = not t.completed }) else (Todo t)
  }

foldp ToggleAllCompleted (State st) =
  noEffects $ State st { todos = st.todos }

foldp RemoveCompleted (State st) =
  noEffects $ State st { todos = flip filter st.todos \(Todo t) -> not t.completed }

foldp (RemoveTodo id ev) (State st) =
  noEffects $ State st { todos = flip filter st.todos \(Todo t) -> t.id /= id }

eventToKeyPressed :: DOMEvent -> String
eventToKeyPressed ev = either (const "") key $ runExcept $ eventToKeyboardEvent ev
