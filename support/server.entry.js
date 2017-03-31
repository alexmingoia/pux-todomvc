var ServerEntry = require('../src/Server.purs');

if (process.env.NODE_ENV === 'production') {
  ServerEntry.main();
} else {
  module.exports = ServerEntry.mainHot;
}

if (module.hot) {
  module.hot.accept();
}
