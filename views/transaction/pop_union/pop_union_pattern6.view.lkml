# ============================================================
# PoP Pattern6: 任意期間 vs 任意期間
# ------------------------------------------------------------
# Pattern5の拡張。
# 期間内の経過日数を軸に、昨対比推移が見れる。
# ============================================================
view: pop_union_pattern6 {

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
    type: date
    label: "分析期間指定"
  }

  filter: compare_period_filter {
    label: "比較期間指定"
    type: date
  }
#}


  # ==================================================
  # 表示用期間
  # ==================================================
  #{
  dimension: analysis_days_in_period {
    group_item_label: "分析軸 (経過日数)"
    label: "経過日数"
    description: "期間内での経過日数"
    type: number
    sql:
      1 + (
        CASE
          WHEN ${is_analysis_period} THEN DATE_DIFF(${axis}, ${analysis_period_start}, DAY)
          WHEN ${is_compare_period}  THEN DATE_DIFF(${axis}, ${compare_period_start}, DAY)
        END
      )
    ;;
    value_format: "0\日\目"
  }

  ### 期間名
  #{
  dimension: period_name {
    label: "期間名"
    type: string
    sql:
      CASE
        WHEN ${is_analysis_period} THEN '分析期間'
        WHEN ${is_compare_period}  THEN '比較期間'
      END
    ;;
    order_by_field: period_name_order
  }

  dimension: period_name_order {
    hidden: yes
    label: "比較期間 表示順"
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
  # 補助フィールド
  # ==================================================
  #{
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
    sql: DATE({% date_start compare_period_filter %}) ;;
  }

  dimension: compare_period_end {
    hidden: yes
    type: date
    datatype: date
    sql: DATE_ADD(DATE({% date_end compare_period_filter %}), INTERVAL -1 DAY) ;;
  }
  #}

  ### フラグ
  #{
  dimension: is_analysis_period {
    hidden: yes
    type: yesno
    sql:
      ${order_items.is_for_analysis_period}
      AND ${axis} BETWEEN ${analysis_period_start} AND ${analysis_period_end}
    ;;
  }

  dimension: is_compare_period {
    hidden: yes
    type: yesno
    sql:
      ${order_items.is_for_compare_period}
      AND ${axis} BETWEEN ${compare_period_start} AND ${compare_period_end}
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
          and compare_period_filter._is_filtered
      %}
        -- PoP6: 有効
        ${is_analysis_period} OR ${is_compare_period}

      {% else %}
        -- PoP6: 無効
        TRUE

      {% endif %}
      ;;
  }
  #}
#}

}
