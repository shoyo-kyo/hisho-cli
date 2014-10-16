{% for item in @import : %}
<link rel="import" href="{%- item %}">
{% end %}

{%- @code %}