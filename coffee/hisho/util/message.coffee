#
# @name hisho.message
# @version 0.0.1
# @author shoyo kyo
# @description
#  メッセージ管理用ファイル
#
((global)->

	#require
	colors = require('colors')

	#
	# module
	#
	module.exports = 
		"COMMON.ARROW"  : ">>".green
		"ERROR.FILE"    : '\nError: The "${file}" does not exist'.red
		"DELETE.FILE"   : 'Delete the "${file}".'.grey
		"WATCH.START"   : 'Start the monitoring process of the "hisho input files".'.green
		"WATCH.WAITING" : 'Waiting...\n'
		"WATCH.CHANGE"  : 'File "${file}" changed.'
		"WATCH.CREATE"  : 'File Created or Delete.'
		"BUILD.END"     : '\nCompleted in ${time}s at ${date}'.green
		"BUILD.START"   : '''
--------------------------
Run a build of "hisho"'
--------------------------
'''.green

		"BUILD.COMPONENT.START"   : '\nRunning compile processing of "Component files".'.yellow
		"BUILD.COMPONENT.COMPILE" : 'Compile of "${file}"'
		"BUILD.PAGES.START"       : '\nRunning compile processing of "Page files".'.yellow
		"BUILD.PAGES.COMPILE"     : 'Compile of "${file}"'
		"BUILD.HIC.START"   : '\nRunning compile processing of "Intermediates files".'.yellow
		"BUILD.HIC.COMPILE" : 'Created "${file}"'

)(global)

