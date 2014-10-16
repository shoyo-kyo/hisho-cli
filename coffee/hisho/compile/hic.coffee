#
# @name hisho.compile.hic
# @version 0.0.1
# @author shoyo kyo
# @description
#  中間言語（メタ言語）をコンパイルし、css,html,jsに変換
#
((global, hisho)->

	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')
	colors = require('colors')

	#compile module require
	compiler = hisho.getCompiler("name")
	compilerInfo = hisho.getCompiler("type")

	#Set subModule
	subModule = 

		#type
		type: "hic"

		#各種メッセージの設定
		message:
			start:  "BUILD.HIC.START"
			create: "BUILD.HIC.COMPILE"

		#ファイル分割時に、cheerioで実行するセレクタ設定
		selector: 
			template : null #html file
			scripts  : null #style & script
			import   : null #import tag
			removeTag: null #htmlから除外するtag

		#コンパイル時実行するcompilerのメソッド名
		compileMethod: "compileHic"


		#
		# @initialize(callback)
		# 対象ファイルのコンパイルを実行。
		#
		initialize: (minify, callback = ->)->
			#開始メッセージ表示
			hisho.showMessage(@message.start)

			#一時格納データ初期化
			@tmp = 
				update: {}
				compile: {}
				import: {}
				beforeUpdate  : hisho.getData( hisho.template(@filePath.update, type:@type) )
				beforeCompile : hisho.getData( hisho.template(@filePath.compile, type:@type) )

			#ファイルの削除をチェックし、コンパイルファイルを削除
			hisho.deleteFile("hic","output")

			#指定ディレクトリ内にある全てのファイルを取得し、メタ言語の形式にコンパイルする
			hisho.dirIterator 
				dir: @_getInputDir()

				#/components内のhtmlとフォルダのみ対象
				filter: (filePath)=>
					return @_hasTargetFile(filePath)

				#コンパイル処理
				onGetFile: (filePath)=>
					_.each compiler, (v,k)=>
						if filePath.match(v.extension.hic)

							#更新日時格納
							@temp.update[filePath] = fs.statSync(filePath, "utf8").mtime

							#output path生成
							outputPath = @_getOutputPath(filePath, v)
							hisho.makeDir(outputPath)

							#build処理
							v[@compileMethod](
								input: filePath
								output: outputPath
								minify: minify
							,(stdout, stderr)=>
								hisho.showMessage(@message.create, file: outputPath)
							)

							#Set compile data
							@temp.compile[filePath] = [] if not @temp.compile[filePath]
							@temp.compile[filePath].push(outputPath)
							return false

					return true

			#compleate
			setTimeout( =>

				#ファイルの削除をチェックし、コンパイルファイルを削除
				@_deleteFile(@tmp.beforeUpdate, @tmp.update, @beforeCompile)

				#一時格納データ保存
				hisho.setData( hisho.template(@filePath.update, type:@type), @temp.update)
				hisho.setData( hisho.template(@filePath.compile, type:@type), @temp.compile)
				callback()
			,150)
			return @

		#
		# [setting] initializeで使用
		# コンパイル元ファイルの入ってるディレクトリパスを取得
		# ./src/components
		#
		_getInputDir: ()->
			return hisho.config.dir.hic

		#
		# [setting] initializeで使用
		# fileパスが処理対象の物か判定
		# xxx.html or directory true
		#
		_hasTargetFile: (filePath)->
			str = hisho.config.dir.components.replace("/","")
			return if not filePath.match(str) then true else false

		#
		# @_setWriteFile(datas)
		# ファイルの生成処理
		#

		#
		# [setting] _parseで使用 
		# outputするファイルのパスを取得
		# ./dist/{type}/{subDir}/{fileName}
		#
		_getOutputPath: (filePath, compileInfo)->
			pathData = hisho.getPathData(filePath)

			outputPathData = 
				main     : hisho.config.dir.output
				type     : compileInfo.dir.output
				subDir   : pathData.subDir
				fileName : pathData.name + compileInfo.extension.output

			result = hisho.template("./${main}/${type}/${subDir}/${fileName}", outputPathData);
			result = path.normalize(result)
			return result


	#extend module
	coreModule = require('./core')
	_.extend(module.exports, coreModule, subModule);


)(global, global.hisho)



