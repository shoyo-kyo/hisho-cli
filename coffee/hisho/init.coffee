#
# @name hisho.init
# @version 0.0.1
# @author shoyo kyo
# @description
#  プロジェクト生成
#
do (global) ->

	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')
	exec = require('child_process').exec
	prompt = require('prompt');
	hisho = {}

	module.exports = 

		#
		# run task
		#
		run : ->
			
			#require
			hisho = global.hisho = require("./util/util")

			hisho.showMessage "INIT.START"
			hisho.showMessage "COMMON.CHECK", text: "Target Folder"
			hisho.showMessage process.cwd() + "\n"

			#ファイルの存在及び、hishoバージョンのチェック
			files = fs.readdirSync("./")
			if files.length is 0
				hisho.showMessage "INIT.CHECK.CREATE"
			else
				try
					hishoVersion = require("../../package.json").version
					currentVersion = require(path.normalize(process.cwd() + "/package.json")).version
				catch error
					hisho.showMessage "INIT.CHECK.OVERRIDE"

				if hishoVersion is currentVersion
					hisho.showMessage "INIT.CHECK.OVERRIDE"
				else
					hisho.showMessage "INIT.CHECK.VERSION"

			#prompt
			prompt.start();

			setting = 
				properties: 
					answer: 
						required: true

			prompt.get setting, (err, result)=>
				if result.answer is "y"
					@create()
					@installNpm(()->
						hisho.showMessage "COMMON.SUCCESS", text: '"hisho init" task is completed.'
					)
				else
					process.exit(0)

			return @

		#
		# Create files 
		#
		create: ->
			hisho.showMessage "INIT.START.COPY"

			#コピー元ファイルパス
			targetPath = path.normalize(hisho.cliPath + "/files")

			#ディレクトリ再起処理
			hisho.dirIterator
				dir: targetPath
				onGetFile: (filePath)=>
					@_setCopyFile(filePath)

			hisho.showMessage "INIT.SUCCESS.COPY"
			return @

		#
		# @_setWriteFile(filePath)
		# ファイルの複製処理
		#
		_setCopyFile: (filePath)-> 
			#パス整形
			basePath = filePath.replace(/^.*?files.(.*?)$/g, "$1")
			outputPath = path.normalize(process.cwd() + "/" + basePath)

			#読み込み
			try
				str = fs.readFileSync(filePath, 'utf-8')
			catch error
				hisho.showMessage("ERROR.FILE", {file: filePath})
				process.exit(0)

			#書き込み
			if str
				hisho.makeDir(outputPath)
				fs.writeFileSync(outputPath, str, 'utf8')
				hisho.showMessage "COMMON.ARROW", text: "GET " + basePath

			return @

		#
		# npm load
		#
		installNpm: (callback)->
			hisho.showMessage "INIT.START.NPM"

			cmd = "npm install";
			exec(cmd, (err, stdout, stderr)->
				if err isnt null

					errorTexts = String(err).split(/\n/)
					_.each errorTexts, (v)=>
						hisho.showMessage "COMMON.ARROW.RED", text: v
					hisho.showMessage "INIT.ERROR.NPM"
					process.exit(1);

				else
					hisho.showMessage "COMMON.ARROW", text: stdout
					hisho.showMessage "COMMON.ARROW", text: stderr
					hisho.showMessage "INIT.SUCCESS.NPM"
					callback()
			)
			return @

	return