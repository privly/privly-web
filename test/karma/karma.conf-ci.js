var fs = require('fs');

module.exports = function(config) {

  // Use ENV vars on Travis and sauce.json locally to get credentials
  if (!process.env.SAUCE_USERNAME) {
    if (!fs.existsSync('sauce.json')) {
      console.log('Create a sauce.json with your credentials based on the sauce-sample.json file.');
      process.exit(1);
    } else {
      process.env.SAUCE_USERNAME = require('./sauce').username;
      process.env.SAUCE_ACCESS_KEY = require('./sauce').accessKey;
    }
  }

  // Check the environment variables for a binding
  // on TRAVIS_LAUNCHES_SAUCE_CONNECT, which indicates Travis
  // launches Sauce Connect instead of this script
  var thisFileLaunchesSauceConnect = true;
  if (process.env.TRAVIS_LAUNCHES_SAUCE_CONNECT) {
    thisFileLaunchesSauceConnect = false;
  }

  // Browsers to run on Sauce Labs
  var customLaunchers = {
    'sl_chrome': {
          base: 'SauceLabs',
          browserName: 'chrome',
          platform: 'Windows 7',
          version: '35'
        },
    'sl_firefox': {
      base: 'SauceLabs',
      browserName: 'firefox',
      version: '30'
    },
    'sl_ios_safari': {
      base: 'SauceLabs',
      browserName: 'iphone',
      platform: 'OS X 10.9',
      version: '7.1'
    },
    'sl_ie_11': {
      base: 'SauceLabs',
      browserName: 'internet explorer',
      platform: 'Windows 8.1',
      version: '11'
    }
  };

  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],
    

    // list of files / patterns to load in the browser
    files: [
      '../../public/apps/*/test/*.js',
      '../../public/apps/vendor/jquery.min.js',
      '../../public/apps/shared/javascripts/*.js',
      '../../public/apps/shared/javascripts/privly-web/*.js',
      '../../public/apps/shared/test/*.js',
      '../../public/apps/shared/test/*/*.js'
    ],

    // files to exclude from testing
    exclude: ['../../public/apps/shared/test/execute.js'],

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['dots', 'saucelabs'],

    tunnelIdentifier: process.env.TRAVIS_JOB_NUMBER,

    // web server port
    port: 9876,

    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    sauceLabs: {
      startConnect: thisFileLaunchesSauceConnect,
      testName: 'Privly Jasmine Testing: Karma and Sauce Labs'
    },
    captureTimeout: 120000,
    customLaunchers: customLaunchers,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: Object.keys(customLaunchers),
    singleRun: true
  });
};
