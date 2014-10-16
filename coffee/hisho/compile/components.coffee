#
# @name hisho.compile.components
# @version 0.0.1
# @author shoyo kyo
# @description
#  コンポーネントファイルを中間言語（メタ言語）にコンパイル
#
((global, hisho)->
	
	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')

	#Set subModule
	subModule = 

		#type
		type: "components"

		#各種メッセージの設定
		message:
			start:  "BUILD.COMPONENT.START"
			create: "BUILD.COMPONENT.COMPILE"

		#ファイル分割時に、cheerioで実行するセレクタ設定
		selector:
			template : "hisho-module template"
			scripts  : 'hisho-module script, hisho-module template style, hisho-module template link[rel="stylesheet"]'
			import   : 'link[rel="import"]'
			removeTag: 'style, link[rel="import"], link[rel="stylesheet"]'

		#コンパイル時実行するcompilerのメソッド名
		compileMethod: "parseCompnent"

		#
		# @initialize(callback)
		# 対象ファイルを検索しmeta言語へ変換後、ファイル生成を行う
		#

		#
		# [setting] initializeで使用
		# コンパイル元ファイルの入ってるディレクトリパスを取得
		# ./src/components
		#
		_getInputDir: ()->
			return path.join(hisho.config.dir.input, hisho.config.dir.components)

		#
		# [setting] initializeで使用
		# fileパスが処理対象の物か判定
		# xxx.html or directory true
		#
		_hasTargetFile: (filePath)->
			return if filePath.match(/.*\.html$/) or not filePath.match(/.*\..*?$/) then true else false

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
		# @_parseImport($el, filePath, $)
		# Get import path list
		#

		#
		# @_parseScripts($el, filePath, $)
		# Get script & style code
		#

		#
		# @_parseHtml($el, filePath, $)
		# Get html code
		#

		#
		# @_convComponentPath(paths,code)
		# Convert input path to output path
		#

		#
		# [setting] _parseで使用 
		# outputするファイルのパスを取得
		# ./hic/{type}/components/{subDir}/{fileName}
		#
		_getOutputPath: (filePath, compileInfo)->
			pathData = hisho.getPathData(filePath)

			outputPathData = 
				main     : hisho.config.dir.hic
				type     : compileInfo.dir.hic
				component: pathData.component
				subDir   : pathData.subDir
				fileName : pathData.name + compileInfo.extension.hic

			result = hisho.template("./${main}/${type}/${component}/${subDir}/_${fileName}", outputPathData);
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



