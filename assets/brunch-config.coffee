exports.config =
  files:
    javascripts:
      joinTo: 'js/app.js'
    stylesheets:
      joinTo: 'css/app.css'
    templates:
      joinTo: 'js/app.js'
  conventions:
    assets: /^(static)/
  paths:
    watched: [
      'static'
      'css'
      'js'
      'vendor'
    ]
    public: '../priv/static'
  plugins:
    babel:
      ignore: [/vendor/]
    sass:
      mode: 'native'
      options:
        includePaths: ['node_modules/bootstrap/scss']
    postcss:
      processors: [
        require('autoprefixer')([
          'Chrome >= 45'
          'Firefox ESR'
          'Edge >= 12'
          'Explorer >= 10'
          'iOS >= 9'
          'Safari >= 9'
          'Android >= 4.4'
          'Opera >= 30'
        ])
        require('postcss-flexbugs-fixes')
      ]
  modules:
    autoRequire:
      'js/app.js': ['js/app']
  npm:
    enabled: true
    globals:
      $: 'jquery'
      jQuery: 'jquery'
      Tether: 'tether'
