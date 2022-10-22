view: order_items {
  sql_table_name: bigquery-public-data.thelook_ecommerce.order_items ;;

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: user_id {
    hidden: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_id {
    hidden: yes
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: inventory_item_id {
    hidden: yes
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw, year, quarter, month, week, date,
      month_name, day_of_year, day_of_month, day_of_week,
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw, year, quarter, month, week, date,
      month_name, day_of_year, day_of_month, day_of_week,
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw, year, quarter, month, week, date,
      month_name, day_of_year, day_of_month, day_of_week,
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw, year, quarter, month, week, date,
      month_name, day_of_year, day_of_month, day_of_week,
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    hidden: yes
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  measure: order_count {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
  }
}
