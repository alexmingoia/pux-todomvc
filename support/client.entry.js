var ClientEntry = require('../src/Client.purs');
var debug = process.env.NODE_ENV === 'development'

var initialState = ClientEntry.readState(window.__puxInitialState);

if (module.hot) {
  ClientEntry.main(window.location.pathname)(window.__puxLastState || initialState)()

  app.state.subscribe(function (state) {
   window.__puxLastState = state;
  });

  module.hot.accept();
} else {
  ClientEntry.main(window.location.pathname)(puxInitialState)()
}
