const ClientEntry = require('../src/Client.purs');

const initialState = ClientEntry.readState(window.__puxInitialState);

if (module.hot) {
  let app = ClientEntry.main(window.location.pathname)(window.__puxLastState || initialState)()

  app.state.subscribe(function (state) {
   window.__puxLastState = state;
  });

  module.hot.accept();
} else {
  ClientEntry.main(window.location.pathname)(initialState)()
}
