view: inventory_items {
  sql_table_name: bigquery-public-data.thelook_ecommerce.inventory_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }
}
