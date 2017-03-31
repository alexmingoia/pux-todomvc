module App.View.Layout where

import App.View.TodoList as TodoList
import App.View.NotFound as NotFound
import App.Routes (Route(..))
import App.State (State(..))
import App.Events (Event)
import Pux.DOM.HTML (HTML)

view :: State -> HTML Event
view (State st) = case st.route of
  All -> TodoList.view (State st)
  Active -> TodoList.view (State st)
  Completed -> TodoList.view (State st)
  (NotFound url) -> NotFound.view (State st)
