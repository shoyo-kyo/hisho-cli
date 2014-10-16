#
# @name hisho-cli
# @version 0.0.1
# @author shoyo kyo
# @git 
#
do ->

	#require
	async = require('async')
	opts = require("opts")
	nodeWatch = require('node-watch')
	dateUtils = require('date-utils')
	hishoUtils = require('./util/util')

	#hisho util
	hisho = global.hisho = hishoUtils.initialize()

	#module
	compile =
		components : require("./compile/components")
		pages : require("./compile/pages")
		hic : require("./compile/hic")

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
	isMinify = opts.get("minify") || false
	isWatch = opts.get("watch") || false
	mode = if opts.get("version") then "version" else opts.get("compile") or "all"

	#
	# ビルド終了メッセージ表示
	#
	showEndMessage = (isWatch, startDate)->
		endDate = new Date();
		time =  (endDate - startDate) / 1000
		hisho.showMessage("BUILD.END",{ time: time, date: endDate.toFormat("YYYY.MM.DD HH24:MI:SS") })
		if isWatch
			console.log hisho.getMessage("WATCH.WAITING")
		return false

	#
	# watch判定および、メッセージ表示
	#
	watchOption = (iswatch, callback)->
		if iswatch
				hisho.showMessage("WATCH.START")
				hisho.showMessage("WATCH.WAITING")
				
				dirs = [hisho.config.dir.input, hisho.config.dir.hic_tpl]

				nodeWatch dirs, (filename)=>
					if filename
						console.log(hisho.getMessage("COMMON.ARROW") + hisho.getMessage("WATCH.CHANGE", {file:filename}))
					else
						console.log(hisho.getMessage("COMMON.ARROW") + hisho.getMessage("WATCH.CREATE"))

					callback()
			else
				callback()
		return false


	#実行
	switch mode
		when "version"
			pkg = require "../../package.json"
			hisho.showMessage("v#{pkg.version}")

		when "conponents"
			watchOption isWatch, =>
				startDate = new Date();
				hisho.showMessage("BUILD.START")
				async.series([
					(callback)=> compile.components.initialize(isMinify, callback),
					(callback)=> 
						setTimeout(=>
							showEndMessage(isWatch, startDate)
						,500)
				])

		when "pages"
			watchOption isWatch, =>
				startDate = new Date();
				hisho.showMessage("BUILD.START")
				async.series([
					(callback)=> compile.pages.initialize(isMinify, callback),
					(callback)=> 
						setTimeout(=>
							showEndMessage(isWatch, startDate)
						,500)
				])

		when "build"
			watchOption isWatch, =>
				startDate = new Date();
				hisho.showMessage("BUILD.START")
				async.series([
					(callback)=> compile.hic.initialize(isMinify, callback)
					(callback)=> 
						setTimeout(=>
							showEndMessage(isWatch, startDate)
						,500)
				])

		when "all"
			watchOption isWatch, =>
				startDate = new Date();
				hisho.showMessage("BUILD.START")
				async.series([
					(callback)=> compile.components.initialize(isMinify, callback),
					(callback)=> compile.pages.initialize(isMinify, callback),
					(callback)=> compile.hic.initialize(isMinify, callback)
					(callback)=> 
						setTimeout(=>
							showEndMessage(isWatch, startDate)
						,500)
				])
	return 






