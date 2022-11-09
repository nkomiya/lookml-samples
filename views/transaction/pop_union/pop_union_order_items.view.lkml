include: "../order_items.view"

view: pop_union_order_items {
  extends: [order_items]

  derived_table: {
    # 期間数分だけ、フラグ立てをしつつ union でレコードを増幅させる。
    sql:
      SELECT
        *,
        1 AS period_flag
      FROM
        bigquery-public-data.thelook.order_items

      UNION ALL
      SELECT
        *,
        2 AS period_flag
      FROM
        bigquery-public-data.thelook.order_items

      -- 以下、pattern 4 でのみ利用

      UNION ALL
      SELECT
        *,
        3 AS period_flag
      FROM
        bigquery-public-data.thelook.order_items
    ;;
  }

  dimension: period_flag {
    hidden: yes
    type: number
    sql: ${TABLE}.period_flag ;;
  }

  dimension: is_for_analysis_period {
    hidden: yes
    type: yesno
    sql: ${period_flag} = 1 ;;
  }

  dimension: is_for_compare_period {
    hidden: yes
    type: yesno
    sql: ${period_flag} = 2 ;;
  }

  ### 以下、pattern 4 でのみ利用

  dimension: is_for_compare_period_one_before {
    hidden: yes
    type: yesno
    sql: ${is_for_compare_period} ;;
  }

  dimension: is_for_compare_period_two_before {
    hidden: yes
    type: yesno
    sql: ${period_flag} = 3 ;;
  }
}
