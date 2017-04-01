module App.View.TodoList where

import App.Routes (Route(..))
import App.State (State(..), Todo(..))
import App.Events (Event(..))
import Control.Bind (bind)
import Data.Array (filter, length)
import Data.BooleanAlgebra (not)
import Data.Eq ((==))
import Data.Foldable (for_)
import Data.Function (const, flip, ($))
import Data.Monoid (mempty)
import Data.Show (show)
import Pux.DOM.Events (onClick, onChange, onDoubleClick, onKeyUp)
import Pux.DOM.HTML (HTML, memoize)
import Pux.DOM.HTML.Attributes (focused, key)
import Text.Smolder.HTML (a, button, div, footer, h1, header, input, label, li, p, section, span, strong, ul)
import Text.Smolder.HTML.Attributes (checked, className, for, href, placeholder, type', value)
import Text.Smolder.Markup ((!), (!?), (#!), text)

item :: Todo -> HTML Event
item = memoize \(Todo todo) ->
  li
    ! className (if todo.completed then "completed" else (if todo.editing then "editing" else ""))
    ! key (show todo.id) $ do
    if todo.editing then
      input
        #! onKeyUp (TodoInput todo.id)
        ! type' "text"
        ! className "edit"
        ! focused
        ! value todo.newText
      else
        div ! className "view" $ do
          (input
            !? todo.completed) (checked "checked")
            #! onChange (ToggleCompleted todo.id)
            ! className "toggle"
            ! type' "checkbox"
          label #! onDoubleClick (ToggleEditing todo.id) $ text todo.text
          button
            #! onClick (RemoveTodo todo.id)
            ! className "destroy"
            $ mempty

view :: State -> HTML Event
view (State st) =
  div do
    let filtered = case st.route of
                     Active -> flip filter st.todos \(Todo t) -> not t.completed
                     Completed -> flip filter st.todos \(Todo t) -> t.completed
                     _ -> st.todos

    section ! className "todoapp" $ do
      header ! className "header" $ do
        h1 $ text "Todos"
        input
          #! onKeyUp NewTodoInput
          ! className "new-todo"
          ! placeholder "What needs to be done?"
          ! value st.newTodo
      section ! className "main" $ do
        input ! className "toggle-all" ! type' "checkbox"
        label ! for "toggle-all" $ text "Mark all as complete"
        ul ! className "todo-list" $ do
          for_ filtered item
      if ((length st.todos) == 0) then mempty else footer ! className "footer" $ do
        span ! className "todo-count" $ do
          let len = length (flip filter st.todos \(Todo t) -> not t.completed)
          strong $ text (show len)
          span $ text $ if len == 1 then " item left" else " items left"
        ul ! className "filters" $ do
          li $ (a !? (st.route == All)) (className "selected") ! href "/" #! onClick (Navigate "/") $ text "All"
          li $ (a !? (st.route == Active)) (className "selected") ! href "/active" #! onClick (Navigate "/active") $ text "Active"
          li $ (a !? (st.route == Completed)) (className "selected") ! href "/completed" #! onClick (Navigate "/completed") $ text "Completed"
        button
          #! onClick (const RemoveCompleted)
          ! className "clear-completed"
          $ text "Clear completed"
    footer ! className "info" $ do
      p $ text "Double-click to edit a todo"
      p $ do
        span $ text "Template by "
        a ! href "http://sindresorhus.com" $ text "Sindre Sorhus"
      p $ text "Created by Alex Mingoia"
      p $ do
        span $ text "Part of "
        a ! href "http://todomvc.com" $ text "TodoMVC"
