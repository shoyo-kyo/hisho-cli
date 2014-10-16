#
# @name hisho-cli
# @version 0.0.1
# @author shoyo kyo
# @git 
#
do ->

	#
	# Set command options
	#

	#require
	opts = require("opts")

	#command option setting
	options = [
		{
			short : 'v'
			long : 'version'
			description : 'Show version'
			value: false
			required: false
		},
		{
			short : 'c'
			long : 'compile'
			description : 'compile files (all, components, pases, static)'
			value: true
			required: false
		},
		{
			short : 'w'
			long : 'watch'
			description : 'Run predefined tasks whenever watched files compile.'
			value: false
			required: false
		},
		{
			short : 'm'
			long : 'minify'
			description : 'Minify to sass and js files'
			value: false
			required: false
		}
	]

	#command option parse
	opts.parse(options, true)
	isMinify = opts.get("minify") or false
	isWatch = opts.get("watch") or false
	compileType = opts.get("compile") or "all"

	args = opts.args()
	mode = args[0] || "compile"

	if opts.get("version")
		mode = "version"

	#実行
	switch mode
		when "version"
			version = require("./version")
			version.run();

		when "init"
			init = require("./init")
			init.run();

		when "compile"
			compile = require("./compile")
			compile.run(compileType);

	return 






