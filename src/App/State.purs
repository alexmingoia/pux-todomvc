module App.State where

import App.Config (config)
import App.Routes (Route, match, toURL)
import Control.Applicative (pure)
import Control.Bind (bind)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, jsonEmptyObject, (.?), (:=), (~>))
import Data.Function (($))

data Todo = Todo
  { id :: Int
  , text :: String
  , newText :: String
  , completed :: Boolean
  , editing :: Boolean
  }

data State = State
  { title :: String
  , loaded :: Boolean
  , route :: Route
  , todos :: Array Todo
  , newTodo :: String
  }

instance decodeJsonState :: DecodeJson State where
  decodeJson json = do
    obj <- decodeJson json
    title <- obj .? "title"
    loaded <- obj .? "loaded"
    url <- obj .? "route"
    todos <- obj .? "todos"
    newTodo <- obj .? "newTodo"
    pure $ State { title, todos, loaded, newTodo, route: match url }

instance encodeJsonState :: EncodeJson State where
  encodeJson (State st) =
       "title"   := st.title
    ~> "loaded"  := st.loaded
    ~> "route"   := toURL st.route
    ~> "todos"   := st.todos
    ~> "newTodo" := st.newTodo
    ~> jsonEmptyObject

instance decodeJsonTodo :: DecodeJson Todo where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .? "id"
    text <- obj .? "text"
    completed <- obj .? "completed"
    pure $ Todo { id, text, completed, editing: false, newText: text }

instance encodeJsonTodo :: EncodeJson Todo where
  encodeJson (Todo todo) =
       "id" := todo.id
    ~> "text" := todo.text
    ~> "completed" := todo.completed
    ~> "editing" := todo.editing
    ~> jsonEmptyObject

init :: String -> State
init url = State
  { title: config.title
  , loaded: false
  , route: match url
  , todos: []
  , newTodo: ""
  }
