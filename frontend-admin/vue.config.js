const { defineConfig } = require('@vue/cli-service')

// const path = require('path')

module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: '/',
  outputDir: 'dist',
  lintOnSave: process.env.NODE_ENV === 'development',
  productionSourceMap: false,
  devServer: {
    port: 18802,
    open: true,
    client: {
      overlay: false,
    },
    proxy: {
      '/myapp/admin': {
        target: 'http://127.0.0.1:8000',
        changOrigin: true
      },
      '/upload': {
        target: 'http://127.0.0.1:8000',
        changOrigin: true
      },
    }
  },
  chainWebpack(config) {
    config.optimization.minimizer('terser').tap((args) => {
      args[0].terserOptions.compress.drop_console = true
      return args
    })
  }
})
