const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

const file = {
  test: /\.(jpg|jpeg|png|gif|tiff|ico|svg|eot|otf|ttf|woff|woff2|mp4|mov|webm)$/i,
  use: [{
    loader: 'file-loader',
    options: {
      name: 'assets/[folder]/[name]-[hash].[ext]'
    }
  }]
}

environment.loaders.prepend('file', file)

module.exports = environment
