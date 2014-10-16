@charset "UTF-8";

// ===============================================
//
// @name
//   Hisho var0.1.1 alpha
//   generated sass File
//
// @html {%- @name %}.html
// @path {%- @output %}
// @base {%- @input %}
//
// 1.component css require
// 2.base css 
// ===============================================

//--------------------------------
// 1.component css require
//--------------------------------
{% for item in @import : %}
//@require {%- item %};
{% end %}

//--------------------------------
// 2.base css 
//--------------------------------
{%- @code %}