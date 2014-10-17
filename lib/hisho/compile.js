(function(global) {
  var async, dateUtils, fs, hisho, nodeWatch, path, _;
  fs = require('fs');
  path = require('path');
  _ = require('underscore');
  hisho = {};
  async = require('async');
  nodeWatch = require('node-watch');
  dateUtils = require('date-utils');
  module.exports = {
    run: function(type, isWatch, isMinify) {
      var compile, startDate;
      hisho = global.hisho = require("./util/util");
      compile = {
        components: require("./compile/components"),
        pages: require("./compile/pages"),
        hic: require("./compile/hic")
      };
      startDate = new Date();
      hisho.showMessage("BUILD.START");
      switch (type) {
        case "conponents":
          this._setWatch(isWatch, (function(_this) {
            return function() {
              return async.series([
                function(callback) {
                  return compile.components.initialize(isMinify, callback);
                }, function(callback) {
                  return setTimeout(function() {
                    return _this._setShowMsg(isWatch, startDate);
                  }, 500);
                }
              ]);
            };
          })(this));
          break;
        case "pages":
          this._setWatch(isWatch, (function(_this) {
            return function() {
              return async.series([
                function(callback) {
                  return compile.pages.initialize(isMinify, callback);
                }, function(callback) {
                  return setTimeout(function() {
                    return _this._setShowMsg(isWatch, startDate);
                  }, 500);
                }
              ]);
            };
          })(this));
          break;
        case "build":
          this._setWatch(isWatch, (function(_this) {
            return function() {
              return async.series([
                function(callback) {
                  return compile.hic.initialize(isMinify, callback);
                }, function(callback) {
                  return setTimeout(function() {
                    return _this._setShowMsg(isWatch, startDate);
                  }, 500);
                }
              ]);
            };
          })(this));
          break;
        case "all":
          this._setWatch(isWatch, (function(_this) {
            return function() {
              return async.series([
                function(callback) {
                  return compile.components.initialize(isMinify, callback);
                }, function(callback) {
                  return compile.pages.initialize(isMinify, callback);
                }, function(callback) {
                  return compile.hic.initialize(isMinify, callback);
                }, function(callback) {
                  return setTimeout(function() {
                    return _this._setShowMsg(isWatch, startDate);
                  }, 500);
                }
              ]);
            };
          })(this));
      }
      return this;
    },
    _setWatch: function(iswatch, callback) {
      var dirs;
      if (iswatch) {
        hisho.showMessage("WATCH.START");
        hisho.showMessage("WATCH.WAITING");
        dirs = [hisho.config.dir.input, hisho.config.dir.hic_tpl];
        nodeWatch(dirs, (function(_this) {
          return function(filename) {
            if (filename) {
              hisho.showMessage("WATCH.CHANGE", {
                file: filename
              });
            } else {
              hisho.showMessage("WATCH.CREATE");
            }
            return callback();
          };
        })(this));
      } else {
        callback();
      }
      return this;
    },
    _setShowMsg: function(isWatch, startDate) {
      var endDate, time;
      endDate = new Date();
      time = (endDate - startDate) / 1000;
      hisho.showMessage("BUILD.END", {
        time: time,
        date: endDate.toFormat("YYYY.MM.DD HH24:MI:SS")
      });
      if (isWatch) {
        hisho.showMessage("WATCH.WAITING");
      }
      return this;
    }
  };
})(global);
