const { environment } = require('@rails/webpacker')

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
environment.loaders.get('sass')
  .use.find(item => item.loader === 'sass-loader')

module.exports = environment
