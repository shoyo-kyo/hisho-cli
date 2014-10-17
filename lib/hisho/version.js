(function(global) {
  module.exports = {
    run: function() {
      var pkg;
      pkg = require("../../package.json");
      console.log("v" + pkg.version);
      return this;
    }
  };
})(global);
