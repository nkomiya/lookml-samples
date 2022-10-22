# ============================================================
# PoP Pattern7: 任意期間 vs 直前期間
# ------------------------------------------------------------
# 分析したい期間と、その直前期間との比較を行う。
# 直前期間の日数は分析したい期間と同じにする。
#
# 補足
# オリジナルに、日付軸のフィールド (analysis_period) を追加。
# (オリジナルの method 3 から引っ越し)
# ============================================================
view: pop_pattern7 {

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
#}

  # ==================================================
  # 表示用期間
  # ==================================================
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
    sql:
      DATE_ADD(${analysis_period_start}, INTERVAL -${total_days_in_period} DAY)
    ;;
  }

  dimension: compare_period_end {
    hidden: yes
    type: date
    datatype: date
    sql:
      DATE_ADD(${analysis_period_start}, INTERVAL -1 DAY)
    ;;
  }
  #}


  ### 日数
  dimension: total_days_in_period {
    hidden: yes
    label: "一期間の日数"
    type: number
    sql:
      DATE_DIFF(${analysis_period_end}, ${analysis_period_start}, DAY) + 1
    ;;
  }


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
      {% if analysis_period_filter._is_filtered %}
        -- PoP7: 有効
        ${is_analysis_period} OR ${is_compare_period}

      {% else %}
        -- PoP7: 無効
        TRUE

      {% endif %}
    ;;
  }
  #}
#}


  # ==================================================
  # オリジナルにないフィールド (method 3から引っ越し)
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

  # 期間内の経過日数
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

}
