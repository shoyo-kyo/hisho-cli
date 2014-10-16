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
		"INIT.CHECK.CREATE"   : "Ⓠ".yellow + " プロジェクト作成しますがよろしいでしょうか？(y,n)"
		"INIT.CHECK.VERSION"  : "Ⓠ".yellow + " 最新バージョンにアップデートしますか？(y,n)"
		"INIT.CHECK.OVERRIDE" : "Ⓠ".yellow + " 既にファイルが存在しますが、上書きしますか？(y,n)"
		"INIT.START.COPY"     : "\n>> Start Copying Files".green
		"INIT.START.NPM"      : '>> Run "npm install"'.green
		"INIT.SUCCESS.COPY"   : "✔".green + ' "Copying Files" task is completed.\n'.green
		"INIT.SUCCESS.NPM"    : "✔".green + ' "npm install" task is completed.\n'.green
		"INIT.ERROR.COPY"     : "✘".red + ' Error in the "Copying Files" task.\n'.red
		"INIT.ERROR.NPM"      : "✘".red + ' Error in the "npm install" task.\n'.red

		#hisho init
		
		"WATCH.START"   : 'Start the monitoring process of the "hisho input files".'.green
		"WATCH.WAITING" : 'Waiting...\n'
		"WATCH.CHANGE"  : 'File "${file}" changed.'
		"WATCH.CREATE"  : 'File Created or Delete.'
		"BUILD.END"     : '\nCompleted in ${time}s at ${date}'.green
		"BUILD.START"   : '''
--------------------------
Run a build of "hisho"'
--------------------------
'''.yellow

		"BUILD.COMPONENT.START"   : '\nRunning compile processing of "Component files".'.yellow
		"BUILD.COMPONENT.COMPILE" : 'Compile of "${file}"'
		"BUILD.PAGES.START"       : '\nRunning compile processing of "Page files".'.yellow
		"BUILD.PAGES.COMPILE"     : 'Compile of "${file}"'
		"BUILD.HIC.START"   : '\nRunning compile processing of "Intermediates files".'.yellow
		"BUILD.HIC.COMPILE" : 'Created "${file}"'

)(global)

