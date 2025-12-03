{% macro generate_schema_name(custom_schema_name, node) -%}
    {#-
        Override default schema naming to remove the target schema prefix
        Default behavior: {target_schema}_{custom_schema} (e.g., main_bronze)
        New behavior: {custom_schema} (e.g., bronze)
    -#}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
