#
# @name hisho.version
# @version 0.0.1
# @author shoyo kyo
# @description
#  バージョン情報表示
#
do (global) ->

	module.exports = 

		#
		# run task
		#
		run : ->
			pkg = require "../../package.json"
			console.log("v#{pkg.version}")
			return @

	return




