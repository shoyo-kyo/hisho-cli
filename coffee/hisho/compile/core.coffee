#
# @name hisho.compile.core
# @version 0.0.1
# @author shoyo kyo
# @description
#  各ファイルを中間言語（メタ言語）にコンパイルする際の共通処理を記載したcoreファイル
#  extendsして使用
#
((global, hisho)->

	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')
	cheerio = require('cheerio')

	#compile module require
	compiler = hisho.getCompiler("name")
	compilerInfo = hisho.getCompiler("type")

	#module
	module.exports = 

		#type
		type: null

		#各種メッセージの設定
		message:
			start: ''
			create: ''

		#ファイル分割時に、cheerioで実行するセレクタ設定
		selector:
			template : null #html file
			scripts  : null #style & script
			import   : null #import tag
			removeTag: null #htmlから除外するtag

		#コンパイル時実行するcompilerのメソッド名
		compileMethod: ""

		#テンポラリーパス
		filePath:
			update  : hisho.config.dir.hic_update + "/${type}.json"
			compile : hisho.config.dir.hic_compile + "/${type}.json"
			import : hisho.config.dir.hic_import + "/${type}.json"

		#テンポラリーデータ
		temp:
			update  : {}
			compile : {}
			import  : {}
			beforeUpdate: {}





		#
		# 対象ファイルを検索しmeta言語へ変換後、ファイル生成を行う
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

			#指定ディレクトリ内にある全てのファイルを取得し、メタ言語の形式にコンパイルする
			hisho.dirIterator 
				dir: @_getInputDir()

				filter: (filePath)=>
					return @_hasTargetFile(filePath)

				onGetFile: (filePath)=>
					#更新日時格納
					@tmp.update[filePath] = fs.statSync(filePath, "utf8").mtime

					if minify is false or @_hasCompile()
						#File compile
						fileData = fs.readFileSync(filePath, "utf8")
						codeData = @_parse(filePath, fileData)
						@_setWriteFile(codeData)
						hisho.showMessage(@message.create, file: filePath)

						#Set compile data
						@tmp.compile[filePath] = @_parseTmpCompileData(codeData)
					return true

			#compleate
			setTimeout( =>

				#ファイルの削除をチェックし、コンパイルファイルを削除
				@_deleteFile(@tmp.beforeUpdate, @tmp.update, @beforeCompile)

				#一時格納データ保存
				hisho.setData( hisho.template(@filePath.update, type:@type), @tmp.update)
				hisho.setData( hisho.template(@filePath.compile, type:@type), @tmp.compile)
				callback()
			,150)
			return @


		#
		# [setting] initializeで使用 
		# コンパイル元ファイルの入ってるディレクトリパスを取得
		#
		_getInputDir: ()->
			return null

		#
		# [setting] initializeで使用
		# fileパスが処理対象の物か判定
		# xxx.html or directory true
		#
		_hasTargetFile: (filePath)->
			return false


		#
		# @_hasCompile()
		# 更新日時をチェックしコンパイルを行うか判定
		#
		_hasCompile: ->
			if not @tmp.beforeUpdate then return true
			return new Date(@tmp.update[filePath]) - new Date(@tmp.beforeUpdate[filePath]) isnt 0

		#
		# @_setTmpCompile(filePath, data)
		# Set compile output path
		#
		_parseTmpCompileData: (data)->
			result = []
			_.each data, (v)->
				result.push(v.path) if v.path
			return result

		#
		# @_deleteFile(before, current, outputList)
		# Delete the output file
		#
		_deleteFile: (before, current, outputList)->
			if not before or not outputList or (befor.length is current.length) then return false
			_.each before, (v,k)=>
				if not current[k]
					_.each outputList[k], (v2)=>
						fs.unlinkSync(v2)
						@showMessage("DELETE.FILE", file: v2)
					return false
			return false


		#
		# @_setWriteFile(data)
		# ファイルの生成処理
		#
		_setWriteFile: (data)->
			_.each data, (v, k)=>
				isData = v and v.path and v.code and v.code isnt ""
				if isData
					hisho.makeDir(v.path)
					fs.writeFileSync(v.path, v.code, 'utf8')
			return @

		#
		# @_parse(filePath, fileData)
		# ファイルの変換処理を行う
		# データ分離後、各種コンパイラを通し、新規生成するファイル情報を返す
		#
		_parse: (filePath, fileData)->
			result = {}

			#空タグのパースがうまくいかないため、別の形式に変換
			fileData = fileData.replace(/<([a-zA-Z0-9|\-|_|\.]+?)\/>/gm, "<$1>\[_\]</$1>").replace(/<([a-zA-Z0-9|\-|_|\.]+?)><\/([a-zA-Z0-9|\-|_|\.]+?)>/gm, "<$1>\[_\]</$2>")
			
			#$
			$ = cheerio.load(fileData, decodeEntities: false )
			$template = $(@selector.template) if @selector.template
			$scripts = $(@selector.scripts) if @selector.scripts
			$import = $(@selector.import) if @selector.import

			#component pathData save
			@importList = @_parseImport($import, filePath, $)

			#Get script & style & html
			scripts = @_parseScripts($scripts, filePath, $)
			html    = @_parseHtml($template, filePath, $)
			result  = _.extend({}, scripts, html)

			#create File Data
			_.each result, (v,k)=>
				if v and v.code
					outputPath = @_getOutputPath(filePath, compiler[k])
					datas = {}

					#Set output file code
					#Run "hisho-compiler" method
					datas.code = compiler[k][@compileMethod](
						code   : v.code
						input  : filePath
						output : outputPath
						tplDir : hisho.config.dir.hic_tpl
						import: @_convComponentPath(@importList, k)
					)
					
					#Set output file path
					datas.path = outputPath

					if datas.path and datas.code and datas.code isnt ""
						result[k] = datas

				return
			return result;

		#
		# @_parseImport($el, filePath, $)
		# Get import path list
		#
		_parseImport: ($el, filePath, $)->
			result = []
			if not $el or not $el.length or $el.length is 0 then return result

			$el.each (i, s)=>
				$s = $(s)
				#hrefをルート相対パスに変換後パスデータを取得し格納
				href = $s.attr("href")
				if href
					href = path.resolve(path.dirname(filePath), href)
					href = href.replace(process.cwd(),"")
					result.push(href)
				return
			return result;

		#
		# @_parseScripts($el, filePath, $)
		# Get script & style code
		#
		_parseScripts: ($el, filePath, $)->
			result = {}
			if not $el or not $el.length or $el.length is 0 then return result

			$el.each (i, s)=>
				$s = $(s)
				type = if $s.attr("type") then $s.attr("type") else if $s.is("script") then "text/javascript" else "text/css"
				key = compilerInfo[type].contentName
				code = @_getCodeData($s, filePath)
				result[key] = { path : null, code : "" } if result[key] is undefined or result[key].code is undefined
				result[key].code += code if code
				return
			return result;

		#
		# @_parseHtml($el, filePath, $)
		# Get html code
		#
		_parseHtml: ($el, filePath, $)->
			result = []
			if not $el or not $el.length or $el.length is 0 then return result

			$el.find(@selector.removeTag).remove()
			type = $el.attr("type") or "text/html"
			key = compilerInfo[type].contentName
			result[key] = 
				path : null
				code : if @type is "components" then $el.html() else $.xml()

			return result;

		#
		# @_convComponentPath(paths,code)
		# Convert input path to output path
		#
		_convComponentPath: (paths,code)->
			result = []
			list = hisho.getData(".hisho/compile/components.json")

			#事前データがある場合は、それを基に最小限で生成
			if list
				_.each paths, (p)=>
					p = p.replace(/^(\/|\\)/i, "")
					outputPath = null
					outputPath = list[p]?.output[code]?.path
					outputPath = outputPath.replace(/(\\)/g, "/") if outputPath
					result.push(outputPath) if outputPath
					return
			#事前データが無い場合は、パス自動生成後、チェックし追加
			else
				_.each paths, (p)=>
					pData = hisho.getPathData(p)
					name = "_" + pData.name + compiler[code].extension.hic
					newPath = path.join(hisho.config.dir.hic, compiler[code].dir.hic, pData.component, pData.subDir, name)
					newPath = newPath.replace(/(\\)/g, "/")
					result.push(newPath)

			return result

		#
		# [setting] _parseで使用 
		# outputするファイルのパスを取得
		#
		_getOutputPath: (filePath, compileInfo)->
			return null

		#
		# @_getCodeData($el, filePath)
		# インライン、外部ファイルで記載したコードを取得
		#
		_getCodeData: ($el, filePath)->
			result = ""
			url = $el.attr("href") or $el.attr("src") or null

			#外部ファイル
			if url
				fileRoot = path.dirname(filePath)

				try
					fs.existsSync(path.join(fileRoot, url))
				catch error
					hisho.showMessage("ERROR.FILE", file: o.dir );
					process.exit(1);

				fileData = fs.readFileSync(path.join(fileRoot, url), 'utf-8')
				if fileData
					result = fileData
			#インライン
			else
				result = $el.html()

			return result

)(global, global.hisho)



