module App.Effects where

import DOM (DOM)
import DOM.HTML.Types (HISTORY)
import Network.HTTP.Affjax (AJAX)

type AppEffects fx = (ajax :: AJAX, dom :: DOM, history :: HISTORY | fx)
