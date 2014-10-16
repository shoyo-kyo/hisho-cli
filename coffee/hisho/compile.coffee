((global)->
	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')
	colors = require('colors')
	cwd = process.cwd()
	config = require(cwd + '/hisho_config.js')
	
	parseComponents = require("./parseComponents").parseComponents
	parsePages = require("./parsePages").parsePages
	build = require("./build").build

	makeDir = require('./makeDir')
	directoryIterator = require('./directoryIterator')

	module.exports = 

		#
		# コンポーネントをsass,html,jsに分離し生成
		#
		components: (callback)->
			console.log('\nRunning compile processing of "Component files".\n'.yellow)

			inputDir = path.join(config.directory.input, config.directory.components)

			#指定ディレクトリ内にある全てのファイルを取得し、メタ言語の形式にコンパイルする
			directoryIterator(
				dir: inputDir

				#/components内のhtmlとフォルダのみ対象
				filter: (filePath)->
					return if filePath.match(/.*\.html$/) or not filePath.match(/.*\..*?$/) then true else false

				#コンパイル処理
				onFile: (filePath)->
					fileData = fs.readFileSync(filePath, "utf8")
					datas = parseComponents.parse(filePath,fileData)
					
					#ファイル生成
					_.each datas, (v, k)->
						if v
							makeDir(v.path)
							fs.writeFileSync(v.path, v.code, 'utf8')

					console.log( ('Compile of ' + path.dirname(filePath)) )
					return true;

				#処理完了
				onCompleate: ->
					callback() if callback
					
			)
			return false;

		#
		# ページをsass,html,jsに分離し生成
		#
		pages: (callback)->
			console.log('\nRunning compile processing of "Page files".\n'.yellow)

			inputDir = config.directory.input

			#指定ディレクトリ内にある全てのファイルを取得し、メタ言語の形式にコンパイルする
			directoryIterator(
				dir: inputDir

				#/componentsは除外
				filter: (filePath)->
					str = config.directory.components.replace("/","")
					return if not filePath.match(str) then true else false

				#コンパイル処理
				onFile: (filePath)->
					fileData = fs.readFileSync(filePath, "utf8")
					datas = parsePages.parse(filePath, fileData)
					
					#ファイル生成
					_.each datas, (v, k)->
						if v
							makeDir(v.path)
							fs.writeFileSync(v.path, v.code, 'utf8')

					console.log( ('Compile of ' + filePath) )
					return true;

				#処理完了
				onCompleate: ->
					callback() if callback
			)
			return false;

		#
		# 最終output作成
		#
		build: (minify)->
			console.log('Running build processing of "Static files".\n'.yellow)
			build.initialize();
			return false;

		#
		# 全工程実行
		#
		all: (minify)->
			@build()
			return false;

			comp = @components(=>
				@pages(=>
					@build()
				)
			)
			return false;

)(@)



