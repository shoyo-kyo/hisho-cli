#
# @name hisho.compile
# @version 0.0.1
# @author shoyo kyo
# @description
#  コンパイル処理記載
#
do (global) ->

	#require
	fs = require('fs')
	path = require('path')
	_ = require('underscore')
	hisho = {}
	async = require('async')
	nodeWatch = require('node-watch')
	dateUtils = require('date-utils')

	module.exports = 

		#
		# run task
		#
		run : (type, isWatch, isMinify)->

			#require
			hisho = global.hisho = require("./util/util")
			compile =
				components : require("./compile/components")
				pages : require("./compile/pages")
				hic : require("./compile/hic")

			#message
			startDate = new Date();
			hisho.showMessage "BUILD.START"

			#実行
			switch type
				when "conponents"
					@_setWatch isWatch, =>
						async.series([
							(callback)=> compile.components.initialize(isMinify, callback),
							(callback)=> 
								setTimeout(=>
									@_setShowMsg(isWatch, startDate)
								,500)
						])

				when "pages"
					@_setWatch isWatch, =>
						async.series([
							(callback)=> compile.pages.initialize(isMinify, callback),
							(callback)=> 
								setTimeout(=>
									@_setShowMsg(isWatch, startDate)
								,500)
						])

				when "build"
					@_setWatch isWatch, =>
						async.series([
							(callback)=> compile.hic.initialize(isMinify, callback)
							(callback)=> 
								setTimeout(=>
									@_setShowMsg(isWatch, startDate)
								,500)
						])

				when "all"
					@_setWatch isWatch, =>
						async.series([
							(callback)=> compile.components.initialize(isMinify, callback),
							(callback)=> compile.pages.initialize(isMinify, callback),
							(callback)=> compile.hic.initialize(isMinify, callback)
							(callback)=> 
								setTimeout(=>
									@_setShowMsg(isWatch, startDate)
								,500)
						])
			return @


		#
		# watch判定および、メッセージ表示
		#
		_setWatch : (iswatch, callback)->
			#watch有効時
			if iswatch
				hisho.showMessage "WATCH.START"
				hisho.showMessage "WATCH.WAITING"
				
				dirs = [hisho.config.dir.input, hisho.config.dir.hic_tpl]

				nodeWatch dirs, (filename)=>
					if filename
						hisho.showMessage "WATCH.CHANGE", {file:filename}
					else
						hisho.showMessage "WATCH.CREATE"

					callback()
			#無効
			else
				callback()
			return @

		#
		# ビルド終了メッセージ表示
		#
		_setShowMsg : (isWatch, startDate)->
			endDate = new Date();
			time =  (endDate - startDate) / 1000
			hisho.showMessage "BUILD.END", { time: time, date: endDate.toFormat("YYYY.MM.DD HH24:MI:SS") }
			if isWatch
				hisho.showMessage "WATCH.WAITING"
			return @

	return



