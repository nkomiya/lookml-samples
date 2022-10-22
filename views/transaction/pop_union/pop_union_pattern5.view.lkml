# ============================================================
# PoP Pattern5: 任意期間 vs 任意期間
# ------------------------------------------------------------
# Pattern4 までと異なり、比較対象の期間を任意に選べるパターン。
# 代わりに、日付フィールドを軸にした昨対比推移は見れない。
# (分析期間と比較期間の二色に分けるのみ)
# ============================================================
view: pop_union_pattern5 {

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

  filter: compare_period_filter {
    label: "比較期間指定"
    type: date
  }
#}


  # ==================================================
  # 表示用期間
  # ==================================================
  #{
  ### 期間名
  #{
  dimension: period_name {
    label: "期間名"
    type: string
    case: {
      when: {
        sql: ${is_analysis_period} ;;
        label: "分析期間"
      }
      when: {
        sql: ${is_compare_period} ;;
        label: "比較期間"
      }
    }
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
        -- PoP5: 有効
        ${is_analysis_period} OR ${is_compare_period}

      {% else %}
        -- PoP5: 無効
        TRUE

      {% endif %}
      ;;
  }
  #}
#}

}
