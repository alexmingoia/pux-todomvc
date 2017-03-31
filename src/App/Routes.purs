module App.Routes where

import Control.Alt ((<|>))
import Control.Applicative ((<*))
import Data.Eq (class Eq)
import Data.Function (($))
import Data.Functor ((<$))
import Data.Generic (class Generic, gEq, gShow)
import Data.Maybe (fromMaybe)
import Data.Show (class Show)
import Pux.Router (end, router, lit)

data Route
  = All
  | Active
  | Completed
  | NotFound String

derive instance genericRoute :: Generic Route

instance eqRoute :: Eq Route where
  eq = gEq

instance showRoute :: Show Route where
  show = gShow

match :: String -> Route
match url = fromMaybe (NotFound url) $ router url $
  All <$ end
  <|>
  Active <$ (lit "active") <* end
  <|>
  Completed <$ (lit "completed") <* end

toURL :: Route -> String
toURL All = "/"
toURL Active = "/active"
toURL Completed = "/completed"
toURL (NotFound url) = url
