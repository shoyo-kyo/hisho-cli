(function() {
  var args, compile, compileType, init, isMinify, isWatch, mode, options, opts, version;
  opts = require("opts");
  options = [
    {
      short: 'v',
      long: 'version',
      description: 'Show version',
      value: false,
      required: false
    }, {
      short: 'c',
      long: 'compile',
      description: 'compile files (all, components, pases, static)',
      value: true,
      required: false
    }, {
      short: 'w',
      long: 'watch',
      description: 'Run predefined tasks whenever watched files compile.',
      value: false,
      required: false
    }, {
      short: 'm',
      long: 'minify',
      description: 'Minify to sass and js files',
      value: false,
      required: false
    }
  ];
  opts.parse(options, true);
  isMinify = opts.get("minify") || false;
  isWatch = opts.get("watch") || false;
  compileType = opts.get("compile") || "all";
  args = opts.args();
  mode = args[0] || "compile";
  if (opts.get("version")) {
    mode = "version";
  }
  switch (mode) {
    case "version":
      version = require("./version");
      version.run();
      break;
    case "init":
      init = require("./init");
      init.run();
      break;
    case "compile":
      compile = require("./compile");
      compile.run(compileType, isWatch, isMinify);
  }
})();
