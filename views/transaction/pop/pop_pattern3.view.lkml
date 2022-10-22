# ============================================================
# PoP Pattern3: 任意期間 vs 組込期間
# ------------------------------------------------------------
# 任意の分析したい期間と、所定日数を遡った期間を比較する。
# → 直近3日間を分析対象にして前週との比較を行う、など。
#
# 補足
# オリジナルにある比較期間 "Period" は pattern 7 に引っ越し。
# ============================================================
view: pop_pattern3 {

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
        WHEN ${is_analysis_period} THEN '分析期間'
        WHEN ${is_compare_period}  THEN ${compare_period_label}
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
        WHEN ${is_analysis_period} THEN 1
        WHEN ${is_compare_period}  THEN 2
      END
    ;;
  }
  #}
#}


  # ==================================================
  # filter measures
  # ==================================================
  #{
  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${order_items.id} ;;
  }

  measure: analysis_period_order_count {
    group_label: "オーダー数 (filter measure)"
    group_item_label: "分析期間"
    label: "オーダー数 分析期間"
    type: count_distinct
    sql: ${order_items.order_id} ;;
    filters: [is_analysis_period: "yes"]
  }

  measure: compare_period_order_count {
    group_label: "オーダー数 (filter measure)"
    group_item_label: "比較期間"
    label: "オーダー数 比較期間"
    type: count_distinct
    sql: ${order_items.order_id} ;;
    filters: [is_compare_period: "yes"]
  }
#}


  # ==================================================
  # 補助フィールド
  # ==================================================
  #{
  ### 期間ラベル
  dimension: compare_period_label {
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

  # 比較期間
  dimension: compare_period_start {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${analysis_period_start}, INTERVAL -1 {% parameter compare_period_selector %})
    ;;
  }

  dimension: compare_period_end {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${analysis_period_end}, INTERVAL -1 {% parameter compare_period_selector %})
    ;;
  }
  #}

  ### 期間内の経過日数
  dimension: days_elapsed_in_period {
    hidden: yes
    type: number
    sql:
      CASE
        WHEN ${is_analysis_period} THEN DATE_DIFF(${axis}, ${analysis_period_start}, DAY)
        WHEN ${is_compare_period}  THEN DATE_DIFF(${axis}, ${compare_period_start}, DAY)
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

  dimension: is_compare_period {
    hidden: yes
    type: yesno
    sql:
      ${axis} BETWEEN ${compare_period_start} AND ${compare_period_end}
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
        -- PoP3: 有効
        ${is_analysis_period} OR ${is_compare_period}

      {% else %}
        -- PoP3: 無効
        TRUE
      {% endif %}
      ;;
  }
  #}
#}

}
