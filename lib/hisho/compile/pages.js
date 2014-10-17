(function(global, _arg) {
  var coreModule, fs, path, subModule, _;
  global.hisho = _arg.hisho;
  fs = require('fs');
  path = require('path');
  _ = require('underscore');
  subModule = {
    type: "pages",
    message: {
      start: "BUILD.PAGES.START",
      create: "BUILD.PAGES.COMPILE"
    },
    selector: {
      template: "html",
      scripts: null,
      "import": 'link[rel="import"]',
      removeTag: 'link[rel="import"]'
    },
    compileMethod: "parsePages",
    _getInputDir: function() {
      return hisho.config.dir.input;
    },
    _hasTargetFile: function(filePath) {
      var str;
      str = hisho.config.dir.components.replace("/", "");
      if (!filePath.match(str)) {
        return true;
      } else {
        return false;
      }
    },
    _getOutputPath: function(filePath, compileInfo) {
      var outputPathData, pathData, result;
      pathData = hisho.getPathData(filePath);
      outputPathData = {
        main: hisho.config.dir.hic,
        type: compileInfo.dir.hic,
        subDir: pathData.subDir,
        fileName: pathData.name + compileInfo.extension.hic
      };
      result = hisho.template("./${main}/${type}/${subDir}/${fileName}", outputPathData);
      result = path.normalize(result);
      return result;
    }
  };
  coreModule = require('./core');
  _.extend(module.exports, coreModule, subModule);
})(global, {
  hisho: global.hisho
});
