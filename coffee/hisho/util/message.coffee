#
# @name hisho.message
# @version 0.0.1
# @author shoyo kyo
# @description
#  メッセージ管理用ファイル
#
do (global) ->

	#require
	colors = require('colors')

	#
	# module
	#
	module.exports = 
		#common
		"COMMON.ARROW"     : ">>".green + " ${text}"
		"COMMON.ARROW.RED" : ">>".red + " ${text}"
		"COMMON.CHECK"     : "✓".magenta + " ${text}"
		"COMMON.QUESTION"  : "Ⓠ".yellow + " ${text}"
		"COMMON.SUCCESS"   : "✔".green + " ${text}"
		"COMMON.ERROR"     : "✘".red + " ${text}"
		"ERROR.FILE"       : "\n✘".red + 'Error: The "${file}" does not exist'.red
		"DELETE.FILE"      : "✓".magenta + 'Delete the "${file}".'.grey

		#hisho init
		"INIT.START"   : '''
--------------------------
Create a "HISHO PROJECT"
--------------------------
'''.yellow
		"INIT.CHECK.CREATE"   : "Ⓠ ".yellow + "プロジェクト作成しますがよろしいでしょうか？(y,n)"
		"INIT.CHECK.VERSION"  : "Ⓠ ".yellow + "最新バージョンにアップデートしますか？(y,n)"
		"INIT.CHECK.OVERRIDE" : "Ⓠ ".yellow + "既にファイルが存在しますが、上書きしますか？(y,n)"
		"INIT.START.COPY"     : "\n>> ".green + "Start Copying Files".green
		"INIT.START.NPM"      : ">> ".green + 'Run "npm install"'.green
		"INIT.SUCCESS.COPY"   : "✔ ".green + '"Copying Files" task is completed.\n'
		"INIT.SUCCESS.NPM"    : "✔ ".green + '"npm install" task is completed.\n'
		"INIT.ERROR.COPY"     : "✘ ".red + 'Error in the "Copying Files" task.\n'
		"INIT.ERROR.NPM"      : "✘ ".red + 'Error in the "npm install" task.\n'

		#hisho watch
		"WATCH.START"   : ">> ".green + 'Start the monitoring process of the "hisho input files".'.green
		"WATCH.WAITING" : 'Waiting...\n'
		"WATCH.CHANGE"  : ">> ".green + 'File "${file}" changed.'
		"WATCH.CREATE"  : ">> ".green + 'File Created or Delete.'

		#BUILD
		"BUILD.START"   : '''
--------------------------
Run a build of "HISHO"'
--------------------------
'''.yellow
		"BUILD.COMPONENT.START"   : "\n>> ".green + 'Running compile processing of "Component files".'.green
		"BUILD.COMPONENT.COMPILE" : "✔ ".green + 'Compile of "${file}"'
		"BUILD.PAGES.START"       : "\n>> ".green + 'Running compile processing of "Page files".'.green
		"BUILD.PAGES.COMPILE"     : "✔ ".green + 'Compile of "${file}"'
		"BUILD.HIC.START"         : "\n>> ".green + 'Running compile processing of "Hic files".'.green
		"BUILD.HIC.COMPILE"       : "✔ ".green + 'Created "${file}"'
		"BUILD.END"               : "\n✔ ".green + 'Completed in ${time}s at ${date}'.green

	return

