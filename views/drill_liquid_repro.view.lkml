view: drill_liquid_repro {
  derived_table: {
    sql:
      SELECT 'rhq_apac' AS rhq_cd, 'Singapore' AS sub_cnt_nm, 'SIN01' AS ofc_cd, 'Agreed' AS status, 100 AS amount
      UNION ALL
      SELECT 'rhq_apac' AS rhq_cd, 'Japan' AS sub_cnt_nm, 'TYO01' AS ofc_cd, 'Quoted' AS status, 200 AS amount
      UNION ALL
      SELECT 'rhq_emea' AS rhq_cd, 'Germany' AS sub_cnt_nm, 'HAM01' AS ofc_cd, 'Rejected' AS status, 150 AS amount
    ;;
  }

  # Matches customer's original unquoted parameter with allowed_values
  parameter: prmtr_sls_ofc {
    type: string
    default_value: "rhq"
    allowed_value: { label: "Sales RHQ" value: "rhq" }
    allowed_value: { label: "Sales Sub Country" value: "country" }
    allowed_value: { label: "Sales Office Code" value: "office" }
  }

  dimension: rhq_cd { type: string sql: ${TABLE}.rhq_cd ;; }
  dimension: sub_cnt_nm { type: string sql: ${TABLE}.sub_cnt_nm ;; }
  dimension: ofc_cd { type: string sql: ${TABLE}.ofc_cd ;; }
  dimension: status { type: string sql: ${TABLE}.status ;; }

  # --- BUGGY REPRO: Multiline indented link URL (matches customer LookML) ---
  dimension: dyn_sls_ofc_buggy {
    type: string
    label: "{% if prmtr_sls_ofc._parameter_value == 'country' %}Sales Sub Country{% elsif prmtr_sls_ofc._parameter_value == 'office' %}Sales Office Code{% else %}Sales RHQ{% endif %}"
    sql:
      {% if prmtr_sls_ofc._parameter_value == 'country' %} ${sub_cnt_nm}
      {% elsif prmtr_sls_ofc._parameter_value == 'office' %} ${ofc_cd}
      {% else %} ${rhq_cd}
      {% endif %}
    ;;
    link: {
      label: "Show all {{ value }} (Buggy - Indented Multiline)"
      # IMPORTANT: Keep the 4-space indentation before each &f[...] line!
      url: "{% assign vis_config = '{\"type\": \"table\", \"size_to_fit\": true}' %}
      /explore/finance_data1/drill_liquid_repro?fields=drill_liquid_repro.dyn_sls_ofc_buggy,drill_liquid_repro.status,drill_liquid_repro.total_amount
      &f[drill_liquid_repro.dyn_sls_ofc_buggy]={{ value }}
      &f[drill_liquid_repro.status]=Agreed,Quoted,Rejected
      &f[drill_liquid_repro.prmtr_sls_ofc]={{ _filters['drill_liquid_repro.prmtr_sls_ofc'] | url_encode }}
      &sorts=drill_liquid_repro.dyn_sls_ofc_buggy&limit=500
      &vis_config={{ vis_config | encode_uri }}"
    }
  }

  # --- CONTROL / FIXED: Same link with Liquid whitespace stripping (no inter-line spaces) ---
  dimension: dyn_sls_ofc_fixed {
    type: string
    sql:
      {% if prmtr_sls_ofc._parameter_value == 'country' %} ${sub_cnt_nm}
      {% elsif prmtr_sls_ofc._parameter_value == 'office' %} ${ofc_cd}
      {% else %} ${rhq_cd}
      {% endif %}
    ;;
    link: {
      label: "Show all {{ value }} (Fixed - Stripped Whitespace)"
      url: "{%- assign vis_config = '{\"type\": \"table\", \"size_to_fit\": true}' -%}
      /explore/finance_data1/drill_liquid_repro?fields=drill_liquid_repro.dyn_sls_ofc_fixed,drill_liquid_repro.status,drill_liquid_repro.total_amount
      {{- '' -}}&f[drill_liquid_repro.dyn_sls_ofc_fixed]={{ value | url_encode }}
      {{- '' -}}&f[drill_liquid_repro.status]=Agreed,Quoted,Rejected
      {{- '' -}}&f[drill_liquid_repro.prmtr_sls_ofc]={{ _filters['drill_liquid_repro.prmtr_sls_ofc'] | strip | url_encode }}
      {{- '' -}}&sorts=drill_liquid_repro.dyn_sls_ofc_fixed&limit=500
      {{- '' -}}&vis_config={{ vis_config | encode_uri }}"
    }
  }

  measure: total_amount {
    type: sum
    sql: ${TABLE}.amount ;;
  }
}
