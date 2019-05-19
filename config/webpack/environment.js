const { environment } = require('@rails/webpacker')

const webpack = require('webpack');
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  JQuery: 'jquery',
  jquery: 'jquery'
}));

environment.loaders.append('file', {
  test: /\.(jpg|jpeg|png|gif|tiff|ico|svg|eot|otf|ttf|woff|woff2|mp4|mov|webm)$/i,
	use: [
    {
      loader: 'file-loader',
      options: {
				useRelativePath: true,
				name: 'assets/[folder]/[name]-[hash].[ext]',
      }
    }
  ]
})

// const fileLoader = environment.loaders.get('file-loader')
// fileLoader.test = /\.(jpg|jpeg|png|gif|tiff|ico|svg|eot|otf|ttf|woff|woff2|mp4|mov|webm)$/i

module.exports = environment;