#
# @name hisho.util
# @version 0.0.1
# @author shoyo kyo
# @description
#  グローバル変数に格納する設定や共通関数を定義(global.hishoで呼び出す)
#
do (global) ->

	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')
	mkdirp = require('mkdirp')

	#
	# module
	#
	module.exports = 

		# hisho cli path
		cliPath: path.normalize( process.argv[1].replace(/^(.*?hisho-cli).*$/, "$1") )

		#hisho compiler module npm path
		modulePath: path.normalize( process.cwd() + "/node_modules" )

		# ver
		_config: null
		_message: null
		_compilers:null
		#
		# get hisho-config json
		#
		config: (->
			try
				@_config = require(process.cwd() + '/.hisho/config.js')
			catch e
				return null
			return @_config;
		)()

		#
		# get hisho-compiler List
		# type: "name" or "type"
		#
		getCompiler: (type)->
			if not @_compilers
				#初期化
				@_compilers =
					name:{}
					type:{}
				
				#hisho-compiler格納
				_.each @config.compiler.include, (v,i)=>
					item = require(@modulePath + "/" + v)
					@_compilers.name[item.contentName] = item
					for t in item.contentType
						@_compilers.type[t] = item

			return @_compilers[type]

		#
		# message data get
		#
		getMessage: (type, datas=null)->
			#get message JSON 
			if not @_message
				@_message = require('./message')

			result = @_message[type]
			result = @template(result, datas)
			return result

		#
		# message data get
		#
		showMessage: (type, datas=null)->
			message = @getMessage(type, datas) || type
			console.log(message)
			return false

		#
		# cache Data get
		#
		getData: (filePath)->
			result = null
			try
				result = fs.readFileSync(path.normalize(filePath), 'utf-8')
				result = JSON.parse(result)
			catch error
				result = null
			return result

		#
		# cache Data set
		#
		setData: (filePath, json)->
			@makeDir(filePath)
			json = JSON.stringify(json)
			fs.writeFileSync(path.normalize(filePath), json, 'utf8')
			return false

		#
		# Get file path list
		#
		getFileList: (type)->
			mainDirectory = path.normalize("./" + @config.dir[type])
			result = {}

			#メインフォルダがない場合はとりあえず生成
			@makeDir(mainDirectory)

			#フォルダ内のファイルチェック
			@dirIterator 
				dir: mainDirectory,
				onGetFile: (filePath)=>
					if filePath.match(/\.(.+?)$/g) isnt null
						pathData = @getPathData(filePath)
						
						if type is "output"
							_.each @getCompiler("name"), (v,k)=>
								pathData.subDir = pathData.subDir.replace(v.dir.output,"")

						name = pathData.name
						name = name.replace(/^_/g, "") if name.match(/^_/g)
						name = name.replace(/^(.*?)\.[a-zA-Z]+?$/g, "$1") if name.match(/\.[a-zA-Z]+?$/g)
						name = pathData.subDir + "/" + name
						result[name] = [] if not result[name]
						result[name].push(filePath)

			return result

		#
		# Delete the output file
		#
		deleteFile: (input, output)->
			inputFiles = hisho.getFileList(input)
			outputFiles = hisho.getFileList(output)
			_.each outputFiles, (v,k)=>
				if not inputFiles[k]
					_.each v, (v2)=>
						fs.unlinkSync(v2)
						@showMessage("DELETE.FILE", file: v2)
					return false
			return false

		#
		# Get path type
		#
		getPathType: (filePath)->
			filePath = filePath.split(path.sep).join("/")
			if filePath.match(new RegExp("(\|^)" + @config.dir.input.replace(".", "\.") + "(\)", "i"))
				result = "input"
			else if filePath.match(new RegExp("(\|^)" + @config.dir.hic.replace(".", "\.") + "(\)", "i"))
				result = "hic"
			else if filePath.match(new RegExp("(\|^)" + @config.dir.output.replace(".", "\.") + "(\)", "i"))
				result = "output"
			return result

		#
		# Get path Data
		#
		getPathData: (filePath)->
			filePath = path.normalize(filePath)
			filePath = filePath.split(path.sep).join("/")
			type = @getPathType(filePath)
			subDir = filePath
			
			result = 
				path: filePath
				main  : @config.dir[type]
				component: null
				subDir: null
				name  : path.basename(filePath, path.extname(filePath))
				ex    : path.extname(filePath)

			#component
			result.component = @config.dir.components if filePath.match(new RegExp("\/" + @config.dir.components + "\/", "g"))

			#sub Directory
			if result.component
				subDir = subDir.replace(result.component, "")

			subDir = subDir.replace(result.main, "").replace(new RegExp(result.name, "g"), "").replace(result.ex, "")
			
			#hicのパスの場合
			if type is "hic"
				_.each @getCompiler("name"), (v,k)=>
					subDir = subDir.replace(v.dir.hic,"")

			subDir = path.normalize(subDir).split(path.sep).join("/")
			result.subDir = subDir.replace(/^\//g, "").replace(/\/$/g, "")
			return result

		#
		# 簡易テンプレート
		#
		template: (str,obj=null)->
			if obj
				_.each obj, (v, k)=>
					v = "" if not v
					str = str.replace("${" + k + "}", v)
			return str

		#
		# ファイルパスを取得しディレクトリが存在しない場合、生成する
		#
		makeDir: (dir, callback)->
			if not dir then return false
			dir = path.normalize(dir)
			dir = dir.replace(/(.*)(\/|\\).*?\..*?$/, "$1")
			arr = dir.split("/")
			toDir = ""
			isDir = true
			_.each(arr, (v,i)->
				toDir = if i is 0 then v else "/" + v
				try
					fs.statSync(toDir)
				catch error
					isDir = false
					return false
			)
			if isDir is false
				mkdirp.sync(dir);

		#
		# ディレクトリ内に入っているファイルのパスを取得し、処理を行う
		#
		dirIterator: (options)->
			that = @

			#options
			OPTIONS = 
				dir         : null  #[str]検索ディレクトリ指定
				filter      : -> return true  #[fnc]検索の除外設定
				onCompleate : ->    #[fnc]検索完了時に実行
				onGetFile   : (filePath)->  #[fnc]ファイルパス取得時に実行

			#iterator
			iterator = (options)->
				o = _.extend({}, OPTIONS, options)

				#get File
				try
					files = fs.readdirSync(o.dir)
				catch error
					that.showMessage("ERROR.FILE", {file: o.dir})
					process.exit(1);

				len = files.length

				files
				.map (file)->
					return path.join(o.dir, file)

				.filter (filePath)-> 
					return o.filter(filePath)

				.forEach (filePath)->
					#ディレクトリの場合下層チェック
					if fs.statSync(filePath).isDirectory()
						iterator
							dir       : filePath
							filter    : o.filter
							onGetFile : o.onGetFile
						
					#ファイルの場合処理を行う
					else
						o.onGetFile(filePath);

					#処理完了
					len -= 1
					o.onCompleate() if len <= 1

				return false

			return iterator(options)

	return
