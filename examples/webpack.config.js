'use strict';

const path                  = require('path');
const HtmlWebpackPlugin     = require('html-webpack-plugin');
const CopyWebpackPlugin     = require('copy-webpack-plugin');
const UglifyJSPlugin        = require('uglifyjs-webpack-plugin');

const port              = 8080;
const host              = 'localhost';
const title             = 'ELM Table Examples';
const author            = 'Gribouille';
const target            = process.env.npm_lifecycle_event;
const entryPath         = path.join(__dirname, 'index.js');
const outputPath        = path.join(__dirname, 'dist');
const outputFilename    = target === 'dist' ? '[name]-[hash].js' : '[name].js'


const htmlPlugin = new HtmlWebpackPlugin({
  template: 'index.html',
  inject: 'body',
  filename: 'index.html',
  title: title,
  author: author
});


module.exports = {
  output: {
    path: outputPath,
    filename: `static/js/${outputFilename}`,
  },
  resolve: {
    extensions: ['.js', '.elm'],
    modules: ['node_modules']
  },
  entry: entryPath,
  devServer: {
    port: port,
    clientLogLevel: "warning",
    contentBase: [
      path.join(__dirname, ""),
      path.join(__dirname, "node_modules")
    ],
    watchOptions: {
      ignored: path.join(__dirname, "node_modules")
    }
  },
  module: {
    noParse: /\.elm$/,
    rules: [
      // {
      //   test: /\.(eot|ttf|woff|woff2|svg)$/,
      //   use: 'url-loader?limit=10000'
      //   // use: 'file-loader?publicPath=../../&name=static/css/[hash].[ext]'
      // },
      { 
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/, 
        use: "url-loader?limit=10000&mimetype=application/font-woff" },
      { 
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, 
        use: "file-loader" 
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          {
            loader: 'elm-webpack-loader',
            options: {
              verbose: true,
              warn: true,
              debug: true
            }
          }
        ]
      }, 
      {
        test: /\.sc?ss$/,
        use: [
          {loader: 'style-loader'}, 
          { loader: 'css-loader' }, 
          {
            loader: 'sass-loader',
            options: {
              includePaths: [
                path.resolve(__dirname, 'node_modules'),
              ]
            }
          }
        ]
      }
    ]
  },
  plugins: [ 
    new CopyWebpackPlugin([
        { from: 'node_modules/font-awesome/fonts', to: 'font-awesome/fonts'},
        { from: './favicon.ico', to: './favicon.ico'}
    ]),
    htmlPlugin, 
    new UglifyJSPlugin({
      uglifyOptions: {
        ie8: false,
        ecma: 8,
        output: {
          comments: false,
          beautify: false
        },
        warnings: false
      }
    })
  ]
};
