(function(global, _arg) {
  var coreModule, fs, path, subModule, _;
  global.hisho = _arg.hisho;
  fs = require('fs');
  path = require('path');
  _ = require('underscore');
  subModule = {
    type: "components",
    message: {
      start: "BUILD.COMPONENT.START",
      create: "BUILD.COMPONENT.COMPILE"
    },
    selector: {
      template: "hisho-module template",
      scripts: 'hisho-module script, hisho-module template style, hisho-module template link[rel="stylesheet"]',
      "import": 'link[rel="import"]',
      removeTag: 'style, link[rel="import"], link[rel="stylesheet"]'
    },
    compileMethod: "parseCompnent",
    _getInputDir: function() {
      return path.join(hisho.config.dir.input, hisho.config.dir.components);
    },
    _hasTargetFile: function(filePath) {
      if (filePath.match(/.*\.html$/) || !filePath.match(/.*\..*?$/)) {
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
        component: pathData.component,
        subDir: pathData.subDir,
        fileName: pathData.name + compileInfo.extension.hic
      };
      result = hisho.template("./${main}/${type}/${component}/${subDir}/_${fileName}", outputPathData);
      result = path.normalize(result);
      return result;
    }
  };
  coreModule = require('./core');
  _.extend(module.exports, coreModule, subModule);
})(global, {
  hisho: global.hisho
});
