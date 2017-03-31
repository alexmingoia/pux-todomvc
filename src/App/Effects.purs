module App.Effects where

import DOM (DOM)
import DOM.HTML.Types (HISTORY)
import DOM.WebStorage (STORAGE)
import Network.HTTP.Affjax (AJAX)

type AppEffects fx = (storage :: STORAGE, ajax :: AJAX, dom :: DOM, history :: HISTORY | fx)
