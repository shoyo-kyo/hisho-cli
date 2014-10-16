/*
 * =================================
 * @name {%- @name %} 
 * @path {%- @output %} 
 * @base {%- @input %} 
 * =================================
 */

{% if @import.length > 0 :%}
// require components
// concat target files

{% for item in @import : %}
//@require {%- item %};
{% end %}

{% end %}
// main script
// Script of "{%- @input %}"
{%- @code %}


