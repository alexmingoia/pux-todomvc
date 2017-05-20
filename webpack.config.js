const appConfig = require('./src/App/Config.js').config
const path = require('path')
const webpack = require('webpack')
const isProd = process.env.NODE_ENV === 'production'

const entries = [path.join(__dirname, 'support/entry.js')]

const plugins = [
  new webpack.DefinePlugin({
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV)
  })
]

if (isProd) {
  plugins.push(
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false
    })
  )
}

module.exports = {
  entry: entries,
  context: __dirname,
  target: 'web',
  output: {
    path: path.join(__dirname, 'static', 'dist'),
    filename: 'bundle.js',
    publicPath: appConfig.public_path
  },
  module: {
    loaders: [
      {
        test: /\.purs$/,
        loader: 'purs-loader',
        exclude: /node_modules/,
        query: isProd ? {
          bundle: true,
          bundleOutput: 'static/dist/bundle.js'
        } : {
          psc: 'psa',
          pscIde: true
        }
      }
    ],
  },
  plugins: plugins,
  resolveLoader: {
    modules: [
      path.join(__dirname, 'node_modules')
    ]
  },
  resolve: {
    alias: {
      'react': 'preact-compat',
      'react-dom': 'preact-compat'
    },
    modules: [
      'node_modules',
      'bower_components'
    ],
    extensions: ['.js', '.purs']
  },
  performance: { hints: false },
  stats: {
    hash: false,
    timings: false,
    version: false,
    assets: false,
    errors: true,
    colors: false,
    chunks: false,
    children: false,
    cached: false,
    modules: false,
    chunkModules: false
  }
}
