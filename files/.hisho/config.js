/*
 * @name hisho_config.js
 * @descriptsion hishoの設定ファイル
 */
module.exports = {

	/*
	 * 1. directory names
	 */
	dir: {
		"input"      : "src",        //作業ディレクトリ名
		"hic"        : "hic",        //中間コード格納ディレクトリ名
		"output"     : "dist",       //最終コード格納ディレクトリ名
		"components" : "components", //コンポーネント格納ディレクトリ名
		"hic_tpl"    : ".hisho/template"     //中間コード変換Template格納ディレクトリ
	},


	/*
	 * 2. Setting compiler
	 */
	compiler: {

		//利用するhisho compiler定義
		include:[
			"hisho-compiler-html",
			"hisho-compiler-scss",
			"hisho-compiler-js"
		],

		//各コンパイラの設定
		setting : {

			//scss
			scss: {
				normal: {
					"style"       : "expanded",
					"sourcemap"   : false,
					"noCache"     : false,
					"stopOnError" : false,
					"readFile"    : null//-r ./sass/hisho-query/_hquery-function-0.1.rb 
				},
				minify: {
					"style"       : "compressed",
					"sourcemap"   : false,
					"noCache"     : false,
					"stopOnError" : false,
					"readFile"    : null//-r ./sass/hisho-query/_hquery-function-0.1.rb 
				}
			},

			//js
			js: {
				normal: {
					"compressed"  : false
				},
				minify: {
					"compressed"  : true
				}
			},

			//html
			html: {
				normal: {
					"compressed"  : false
				},
				minify: {
					"compressed"  : false
				}
			}

		}
		
	}


};