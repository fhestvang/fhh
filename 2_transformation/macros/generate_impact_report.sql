{% macro generate_impact_report() %}
{%- set models_changed = [] -%}
{%- set models_affected = [] -%}

{# This macro is meant to be called after running state comparison #}
{# It generates a human-readable impact report #}

{{ log("", info=True) }}
{{ log("═══════════════════════════════════════════════════════════", info=True) }}
{{ log("  IMPACT ANALYSIS REPORT", info=True) }}
{{ log("═══════════════════════════════════════════════════════════", info=True) }}
{{ log("", info=True) }}

{% endmacro %}
