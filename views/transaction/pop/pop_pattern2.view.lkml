# ============================================================
# PoP Pattern2: 組込期間 vs 組込期間
# ------------------------------------------------------------
# この view で行える期間比較は Pattern1 と同じ。
# parameter を介することで、Dashborad でも分析軸を変更できる。
#
# Pattern1について
# Looker の標準機能でも期間比較は可能。
# 方法の詳細は quick start を参照。
# ============================================================
view: pop_pattern2 {

  dimension_group: axis {
    hidden: yes
    type: time
    timeframes: [
      raw, year, quarter, month, week, date,
      month_name, month_num,
      day_of_week_index,
      day_of_year, day_of_month, day_of_week,
    ]
    sql: ${order_items.created_raw} ;;
  }

  # ==================================================
  # フィルタ
  # ==================================================
  #{
  parameter: analysis_axis_selector {
    label: "分析軸指定"
    type: unquoted
    default_value: "Month"
    allowed_value: {label: "月"     value: "Month"} # 月 in 年
    allowed_value: {label: "通年日" value: "DOY"}   # 日 in 年
    allowed_value: {label: "通月日" value: "DOM"}   # 日 in 月
    allowed_value: {label: "曜日"   value: "DOW"}   # 日 in 週
  }

  parameter: group_unit_selector {
    label: "集約単位指定"
    type: unquoted
    default_value: "year"
    allowed_value: {label: "年別" value: "year"}
    allowed_value: {label: "月別" value: "month"}
    allowed_value: {label: "週別" value: "week"}
  }
#}


  # ==================================================
  # 分析軸
  # ==================================================
  #{
  dimension: analysis_axis  {
    label: "分析軸"
    type: string
    sql:
      {% if    analysis_axis_selector._parameter_value == 'Month'  %} ${axis_month_name}
      {% elsif analysis_axis_selector._parameter_value == 'DOY'    %} ${axis_day_of_year}
      {% elsif analysis_axis_selector._parameter_value == 'DOM'    %} ${axis_day_of_month}
      {% elsif analysis_axis_selector._parameter_value == 'DOW'    %} ${axis_day_of_week}
      {% endif %}
    ;;
    label_from_parameter: analysis_axis_selector
    order_by_field: analysis_axis_order
  }

  dimension: analysis_axis_order {
    hidden: yes
    type: number
    sql:
      {% if    analysis_axis_selector._parameter_value == 'Month' %} ${axis_month_num}
      {% elsif analysis_axis_selector._parameter_value == 'DOY'   %} ${axis_day_of_year}
      {% elsif analysis_axis_selector._parameter_value == 'DOM'   %} ${axis_day_of_month}
      {% elsif analysis_axis_selector._parameter_value == 'DOW'   %} ${axis_day_of_week_index}
      {% endif %}
    ;;
  }
#}


  # ==================================================
  # 集約単位
  # ==================================================
  #{
  dimension: group_unit {
    type: string
    label: "集約単位"
    sql:
      {% if    group_unit_selector._parameter_value == 'year'  %} ${axis_year}
      {% elsif group_unit_selector._parameter_value == 'month' %} ${axis_month_name}
      {% elsif group_unit_selector._parameter_value == 'week'  %} ${axis_week}
      {% endif %}
    ;;
    label_from_parameter: group_unit_selector
    order_by_field: group_unit_order
  }

  dimension: group_unit_order {
    hidden: yes
    type: number
    sql:
      {% if    group_unit_selector._parameter_value == 'year'  %} ${axis_year}
      {% elsif group_unit_selector._parameter_value == 'month' %} ${axis_month_num}
      {% elsif group_unit_selector._parameter_value == 'week'  %} ${axis_week}
      {% endif %}
    ;;
  }
#}

}
