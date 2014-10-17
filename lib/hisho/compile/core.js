(function(global, _arg) {
  var cheerio, compiler, compilerInfo, fs, path, _;
  global.hisho = _arg.hisho;
  fs = require('fs');
  path = require('path');
  _ = require('underscore');
  cheerio = require('cheerio');
  compiler = hisho.getCompiler("name");
  compilerInfo = hisho.getCompiler("type");
  module.exports = {
    type: null,
    message: {
      start: '',
      create: ''
    },
    selector: {
      template: null,
      scripts: null,
      "import": null,
      removeTag: null
    },
    compileMethod: "",
    filePath: {
      update: hisho.config.dir.hic_update + "/${type}.json",
      compile: hisho.config.dir.hic_compile + "/${type}.json",
      "import": hisho.config.dir.hic_import + "/${type}.json"
    },
    temp: {
      update: {},
      compile: {},
      "import": {},
      beforeUpdate: {}
    },
    initialize: function(minify, callback) {
      if (callback == null) {
        callback = function() {};
      }
      hisho.showMessage(this.message.start);
      this.tmp = {
        update: {},
        compile: {},
        "import": {},
        beforeUpdate: hisho.getData(hisho.template(this.filePath.update, {
          type: this.type
        })),
        beforeCompile: hisho.getData(hisho.template(this.filePath.compile, {
          type: this.type
        }))
      };
      hisho.dirIterator({
        dir: this._getInputDir(),
        filter: (function(_this) {
          return function(filePath) {
            return _this._hasTargetFile(filePath);
          };
        })(this),
        onGetFile: (function(_this) {
          return function(filePath) {
            var codeData, fileData;
            _this.tmp.update[filePath] = fs.statSync(filePath, "utf8").mtime;
            if (minify === false || _this._hasCompile()) {
              fileData = fs.readFileSync(filePath, "utf8");
              codeData = _this._parse(filePath, fileData);
              _this._setWriteFile(codeData);
              hisho.showMessage(_this.message.create, {
                file: filePath
              });
              _this.tmp.compile[filePath] = _this._parseTmpCompileData(codeData);
            }
            return true;
          };
        })(this)
      });
      setTimeout((function(_this) {
        return function() {
          _this._deleteFile(_this.tmp.beforeUpdate, _this.tmp.update, _this.beforeCompile);
          hisho.setData(hisho.template(_this.filePath.update, {
            type: _this.type
          }), _this.tmp.update);
          hisho.setData(hisho.template(_this.filePath.compile, {
            type: _this.type
          }), _this.tmp.compile);
          return callback();
        };
      })(this), 150);
      return this;
    },
    _getInputDir: function() {
      return null;
    },
    _hasTargetFile: function(filePath) {
      return false;
    },
    _hasCompile: function() {
      if (!this.tmp.beforeUpdate) {
        return true;
      }
      return new Date(this.tmp.update[filePath]) - new Date(this.tmp.beforeUpdate[filePath]) !== 0;
    },
    _parseTmpCompileData: function(data) {
      var result;
      result = [];
      _.each(data, function(v) {
        if (v.path) {
          return result.push(v.path);
        }
      });
      return result;
    },
    _deleteFile: function(before, current, outputList) {
      if (!before || !outputList || (befor.length === current.length)) {
        return false;
      }
      _.each(before, (function(_this) {
        return function(v, k) {
          if (!current[k]) {
            _.each(outputList[k], function(v2) {
              fs.unlinkSync(v2);
              return _this.showMessage("DELETE.FILE", {
                file: v2
              });
            });
            return false;
          }
        };
      })(this));
      return false;
    },
    _setWriteFile: function(data) {
      _.each(data, (function(_this) {
        return function(v, k) {
          var isData;
          isData = v && v.path && v.code && v.code !== "";
          if (isData) {
            hisho.makeDir(v.path);
            return fs.writeFileSync(v.path, v.code, 'utf8');
          }
        };
      })(this));
      return this;
    },
    _parse: function(filePath, fileData) {
      var $, $import, $scripts, $template, html, result, scripts;
      result = {};
      fileData = fileData.replace(/<([a-zA-Z0-9|\-|_|\.]+?)\/>/gm, "<$1>\[_\]</$1>").replace(/<([a-zA-Z0-9|\-|_|\.]+?)><\/([a-zA-Z0-9|\-|_|\.]+?)>/gm, "<$1>\[_\]</$2>");
      $ = cheerio.load(fileData, {
        decodeEntities: false
      });
      if (this.selector.template) {
        $template = $(this.selector.template);
      }
      if (this.selector.scripts) {
        $scripts = $(this.selector.scripts);
      }
      if (this.selector["import"]) {
        $import = $(this.selector["import"]);
      }
      this.importList = this._parseImport($import, filePath, $);
      scripts = this._parseScripts($scripts, filePath, $);
      html = this._parseHtml($template, filePath, $);
      result = _.extend({}, scripts, html);
      _.each(result, (function(_this) {
        return function(v, k) {
          var datas, outputPath;
          if (v && v.code) {
            outputPath = _this._getOutputPath(filePath, compiler[k]);
            datas = {};
            datas.code = compiler[k][_this.compileMethod]({
              code: v.code,
              input: filePath,
              output: outputPath,
              tplDir: hisho.config.dir.hic_tpl,
              "import": _this._convComponentPath(_this.importList, k)
            });
            datas.path = outputPath;
            if (datas.path && datas.code && datas.code !== "") {
              result[k] = datas;
            }
          }
        };
      })(this));
      return result;
    },
    _parseImport: function($el, filePath, $) {
      var result;
      result = [];
      if (!$el || !$el.length || $el.length === 0) {
        return result;
      }
      $el.each((function(_this) {
        return function(i, s) {
          var $s, href;
          $s = $(s);
          href = $s.attr("href");
          if (href) {
            href = path.resolve(path.dirname(filePath), href);
            href = href.replace(process.cwd(), "");
            result.push(href);
          }
        };
      })(this));
      return result;
    },
    _parseScripts: function($el, filePath, $) {
      var result;
      result = {};
      if (!$el || !$el.length || $el.length === 0) {
        return result;
      }
      $el.each((function(_this) {
        return function(i, s) {
          var $s, code, key, type;
          $s = $(s);
          type = $s.attr("type") ? $s.attr("type") : $s.is("script") ? "text/javascript" : "text/css";
          key = compilerInfo[type].contentName;
          code = _this._getCodeData($s, filePath);
          if (result[key] === void 0 || result[key].code === void 0) {
            result[key] = {
              path: null,
              code: ""
            };
          }
          if (code) {
            result[key].code += code;
          }
        };
      })(this));
      return result;
    },
    _parseHtml: function($el, filePath, $) {
      var key, result, type;
      result = [];
      if (!$el || !$el.length || $el.length === 0) {
        return result;
      }
      $el.find(this.selector.removeTag).remove();
      type = $el.attr("type") || "text/html";
      key = compilerInfo[type].contentName;
      result[key] = {
        path: null,
        code: this.type === "components" ? $el.html() : $.xml()
      };
      return result;
    },
    _convComponentPath: function(paths, code) {
      var list, result;
      result = [];
      list = hisho.getData(".hisho/compile/components.json");
      if (list) {
        _.each(paths, (function(_this) {
          return function(p) {
            var outputPath, _ref, _ref1;
            p = p.replace(/^(\/|\\)/i, "");
            outputPath = null;
            outputPath = (_ref = list[p]) != null ? (_ref1 = _ref.output[code]) != null ? _ref1.path : void 0 : void 0;
            if (outputPath) {
              outputPath = outputPath.replace(/(\\)/g, "/");
            }
            if (outputPath) {
              result.push(outputPath);
            }
          };
        })(this));
      } else {
        _.each(paths, (function(_this) {
          return function(p) {
            var name, newPath, pData;
            pData = hisho.getPathData(p);
            name = "_" + pData.name + compiler[code].extension.hic;
            newPath = path.join(hisho.config.dir.hic, compiler[code].dir.hic, pData.component, pData.subDir, name);
            newPath = newPath.replace(/(\\)/g, "/");
            return result.push(newPath);
          };
        })(this));
      }
      return result;
    },
    _getOutputPath: function(filePath, compileInfo) {
      return null;
    },
    _getCodeData: function($el, filePath) {
      var error, fileData, fileRoot, result, url;
      result = "";
      url = $el.attr("href") || $el.attr("src") || null;
      if (url) {
        fileRoot = path.dirname(filePath);
        try {
          fs.existsSync(path.join(fileRoot, url));
        } catch (_error) {
          error = _error;
          hisho.showMessage("ERROR.FILE", {
            file: o.dir
          });
          process.exit(1);
        }
        fileData = fs.readFileSync(path.join(fileRoot, url), 'utf-8');
        if (fileData) {
          result = fileData;
        }
      } else {
        result = $el.html();
      }
      return result;
    }
  };
})(global, {
  hisho: global.hisho
});
