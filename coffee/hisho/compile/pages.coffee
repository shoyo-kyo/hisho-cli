#
# @name hisho.compile.pages
# @version 0.0.1
# @author shoyo kyo
# @description
#  ページファイルを中間言語（メタ言語）にコンパイル
#
((global, hisho)->

	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')

	#Set subModule
	subModule = 

		#type
		type: "pages"

		#各種メッセージの設定
		message:
			start:  "BUILD.PAGES.START"
			create: "BUILD.PAGES.COMPILE"

		#ファイル分割時に、cheerioで実行するセレクタ設定
		selector:
			template : "html"
			scripts  : null
			import   : 'link[rel="import"]'
			removeTag: 'link[rel="import"]'

		#コンパイル時に実行するcompilerのメソッド名
		compileMethod: "parsePages"

		#
		# @initialize(callback)
		# 対象ファイルを検索しmeta言語へ変換後、ファイル生成を行う
		#

		#
		# [setting] initializeで使用
		# コンパイル元ファイルの入ってるディレクトリパスを取得
		# ./src/
		#
		_getInputDir: ()->
			return hisho.config.dir.input

		#
		# fileパスが処理対象の物か判定
		# not /components true
		#
		_hasTargetFile: (filePath)->
			str = hisho.config.dir.components.replace("/","")
			return if not filePath.match(str) then true else false

		#
		# @_setWriteFile(datas)
		# ファイルの生成処理
		#

		#
		# @_parse(filePath, fileData)
		# ファイルの変換処理を行う
		# データ分離後、各種コンパイラを通し、新規生成するファイル情報を返す
		#

		#
		# [setting] _parseで使用 
		# outputするファイルのパスを取得
		# ./hic/{type}/{subDir}/{fileName}
		#
		_getOutputPath: (filePath, compileInfo)->
			pathData = hisho.getPathData(filePath)

			outputPathData = 
				main     : hisho.config.dir.hic
				type     : compileInfo.dir.hic
				subDir   : pathData.subDir
				fileName : pathData.name + compileInfo.extension.hic

			result = hisho.template("./${main}/${type}/${subDir}/${fileName}", outputPathData);
			result = path.normalize(result)
			return result

		#
		# @_getCodeData($el, filePath)
		# インライン、外部ファイルで記載したコードを取得
		#


	#extend module
	coreModule = require('./core')
	_.extend(module.exports, coreModule, subModule);


)(global, global.hisho)

