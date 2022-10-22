# ============================================================
# PoP Pattern4: 任意期間 vs 複数組込期間
# ------------------------------------------------------------
# Pattern3の拡張。比較対象の期間を複数個にする。
#
# 補足
# オリジナルにある比較期間 "Period" は、
# このパターンの本質ではないので削除。
# ============================================================
view: pop_pattern4 {

  dimension: axis {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE(${order_items.created_raw}, "{{ _query._query_timezone }}")
    ;;
  }

  # ==================================================
  # フィルタ
  # ==================================================
  #{
  filter: analysis_period_filter {
    label: "分析期間指定"
    type: date
  }

  parameter: compare_period_selector {
    label: "比較期間指定"
    type: unquoted
    default_value: "Period"

    allowed_value: {label: "前週"     value: "Week"}
    allowed_value: {label: "前月"     value: "Month"}
    allowed_value: {label: "前四半期" value: "Quarter"}
    allowed_value: {label: "前年"     value: "Year"}
  }

  parameter: compare_period_number_selector {
    label: "比較期間数指定"
    type: number
    default_value: "1"
    allowed_value: {label: "1" value: "1"}
    allowed_value: {label: "2" value: "2"}
  }
#}


  # ==================================================
  # 表示用期間
  # ==================================================
  #{
  dimension_group: analysis_period {
    label: "分析期間"
    type: time
    datatype: date
    timeframes: [date]
    sql:
      DATE_ADD(${analysis_period_start}, INTERVAL ${days_elapsed_in_period} DAY)
    ;;
  }

  ### 期間名
  #{
  dimension: period_name {
    label: "期間名"
    type: string
    sql:
      CASE
        WHEN ${is_analysis_period}           THEN '分析期間'
        WHEN ${is_compare_period_one_before} THEN ${compare_period_one_before_label}
        WHEN ${is_compare_period_two_before} THEN ${compare_period_two_before_label}
      END
    ;;
    order_by_field: period_name_order
  }

  dimension: period_name_order {
    hidden: yes
    label: "期間名 表示順"
    type: number
    sql:
      CASE
        WHEN ${is_analysis_period}           THEN 1
        WHEN ${is_compare_period_one_before} THEN 2
        WHEN ${is_compare_period_two_before} THEN 3
      END
    ;;
  }
#}
#}


  # ==================================================
  # 補助フィールド
  # ==================================================
  #{
  ### 期間ラベル
  #{
  dimension: compare_period_one_before_label {
    type: string
    hidden: yes
    sql:
      {%    if compare_period_selector._parameter_value == 'Week'    %} '前週'
      {% elsif compare_period_selector._parameter_value == 'Month'   %} '前月'
      {% elsif compare_period_selector._parameter_value == 'Quarter' %} '前四半期'
      {% elsif compare_period_selector._parameter_value == 'Year'    %} '前年'
      {% endif %}
    ;;
  }

  dimension: compare_period_two_before_label {
    type: string
    hidden: yes
    sql:
      {%    if compare_period_selector._parameter_value == 'Week'    %} '前々週'
      {% elsif compare_period_selector._parameter_value == 'Month'   %} '前々月'
      {% elsif compare_period_selector._parameter_value == 'Quarter' %} '前々四半期'
      {% elsif compare_period_selector._parameter_value == 'Year'    %} '前々年'
      {% endif %}
    ;;
  }
#}


  ### 期間の開始/終了日
  #{
  # 分析期間
  dimension: analysis_period_start {
    hidden: yes
    type: date
    datatype: date
    sql: DATE({% date_start analysis_period_filter %}) ;;
  }

  dimension: analysis_period_end {
    hidden: yes
    type: date
    datatype: date
    sql: DATE_ADD(DATE({% date_end analysis_period_filter %}), INTERVAL -1 DAY) ;;
  }

  # 比較期間 (一期前)
  dimension: compare_period_one_before_start {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${analysis_period_start}, INTERVAL -1 {% parameter compare_period_selector %})
    ;;
  }

  dimension: compare_period_one_before_end {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${analysis_period_end}, INTERVAL -1 {% parameter compare_period_selector %})
    ;;
  }

  # 比較期間 (二期前)
  dimension: compare_period_two_before_start {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${compare_period_one_before_start}, INTERVAL -1 {% parameter compare_period_selector %})
    ;;
  }

  dimension: compare_period_two_before_end {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${compare_period_one_before_end}, INTERVAL -1 {% parameter compare_period_selector %})
    ;;
  }
#}


  ### 期間内 経過日数
  dimension: days_elapsed_in_period {
    hidden: yes
    type: number
    sql:
      CASE
        WHEN ${is_analysis_period}            THEN DATE_DIFF(${axis}, ${analysis_period_start}, DAY)
        WHEN ${is_compare_period_one_before}  THEN DATE_DIFF(${axis}, ${compare_period_one_before_start}, DAY)
        WHEN ${is_compare_period_two_before}  THEN DATE_DIFF(${axis}, ${compare_period_two_before_start}, DAY)
      END
    ;;
  }
#}


  ### フラグ
  #{
  dimension: is_analysis_period {
    hidden: yes
    type: yesno
    sql:
      ${axis} BETWEEN ${analysis_period_start} AND ${analysis_period_end}
    ;;
  }

  dimension: is_compare_period_one_before {
    hidden: yes
    type: yesno
    sql:
      ${axis} BETWEEN ${compare_period_one_before_start} AND ${compare_period_one_before_end}
    ;;
  }

  dimension: is_compare_period_two_before {
    hidden: yes
    type: yesno
    sql:
      ${axis} BETWEEN ${compare_period_two_before_start} AND ${compare_period_two_before_end}
    ;;
  }

  dimension: is_inactive_or_axis_in_any_period {
    hidden: yes
    description: "explore の定義側における絞り込みに利用するフラグ"
    type: yesno
    sql:
      {%
        if
          analysis_period_filter._is_filtered
          and compare_period_selector._is_filtered
      %}
        -- PoP4: 有効
        -- 比較期間数: {{ compare_period_number_selector._parameter_value }}
        {% if compare_period_number_selector._parameter_value == 1 %}
          ${is_analysis_period}
          OR ${is_compare_period_one_before}

        {% elsif compare_period_number_selector._parameter_value == 2 %}
          ${is_analysis_period}
          OR ${is_compare_period_one_before}
          OR ${is_compare_period_two_before}

        {% endif %}

      {% else %}
        -- PoP4: 無効
        TRUE
      {% endif %}
    ;;
  }
#}
#}

}
