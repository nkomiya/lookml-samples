# ======================================================================
# Union版
# ----------------------------------------------------------------------
# Unionでレコードを増幅させることで、期間重複の制限を回避する方法。
# オリジナル版で期間の重複が生じ得る、pattern 3 ~ 6 を拡張。
#
# 補足:
# Unionでレコードを増幅させるため、オリジナル版に比べると処理が重い(はず)。
# 期間を重ねて見る(昨日比推移など)必要がない場合は、オリジナル版で十分。
# ======================================================================
include: "/views/master/users.view"
include: "/views/master/products.view"
include: "/views/transaction/*.view"
include: "/views/transaction/pop_union/*.view"

explore: pop_union {
  label: "PoP patterns (期間重複)"
  view_label: "01. Order Items"
  view_name: order_items
  from: pop_union_order_items

  # ------------------------------
  # filters for PoP
  # ------------------------------
  sql_always_where:
        ${pop_union_pattern3.is_inactive_or_axis_in_any_period}
    AND ${pop_union_pattern4.is_inactive_or_axis_in_any_period}
    AND ${pop_union_pattern5.is_inactive_or_axis_in_any_period}
    AND ${pop_union_pattern6.is_inactive_or_axis_in_any_period}
  ;;

  # ------------------------------
  # joins for PoP
  # ------------------------------
  #{
  join: pop_union_pattern3 { view_label: "_Pattern 3: 制御用" }
  join: pop_union_pattern4 { view_label: "_Pattern 4: 制御用" }
  join: pop_union_pattern5 { view_label: "_Pattern 5: 制御用" }
  join: pop_union_pattern6 { view_label: "_Pattern 6: 制御用" }
  #}

  # ------------------------------
  # 軸を増やすためマスタだけ join
  # ------------------------------
  join: users {
    view_label: "02. Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.id} = ${order_items.user_id} ;;
  }

  join: inventory_items {
    fields: []
    type: left_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: products {
    view_label: "03. Products"
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
  }

  # ------------------------------
  # quick start
  # ------------------------------
  #{
  query: pop_union_pattern3_example_pivot {
    label: "3. 任意期間 vs 組込期間"
    dimensions: [pop_union_pattern3.analysis_period_date]
    pivots: [pop_union_pattern3.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_union_pattern3.analysis_period_filter: "10 days",
      pop_union_pattern3.compare_period_selector: "Week",
    ]
    sorts: [pop_union_pattern3.analysis_period_date: asc]
  }

  query: pop_union_pattern4_example_pivot {
    label: "4. 任意期間 vs 複数組込期間"
    dimensions: [pop_union_pattern4.analysis_period_date]
    pivots: [pop_union_pattern4.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_union_pattern4.analysis_period_filter: "10 days",
      pop_union_pattern4.compare_period_selector: "Week",
      pop_union_pattern4.compare_period_number_selector: "2",
    ]
    sorts: [pop_union_pattern4.analysis_period_date: asc]
  }

  query: pop_union_pattern5_example_pivot {
    label: "5. 任意期間 vs 任意期間"
    description: "日付軸: 設定不可"
    dimensions: [users.traffic_source]
    pivots: [pop_union_pattern5.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_union_pattern5.analysis_period_filter: "7 days",
      pop_union_pattern5.compare_period_filter: "7 days ago for 7 days",
    ]
  }

  query: pop_union_pattern6_example_pivot {
    label: "6. 任意期間 vs 任意期間"
    description: "日付軸: 期間内 経過日数のみ"
    dimensions: [pop_union_pattern6.analysis_days_in_period]
    pivots: [pop_union_pattern6.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_union_pattern6.analysis_period_filter: "7 days",
      pop_union_pattern6.compare_period_filter: "7 days ago for 7 days",
    ]
    sorts: [pop_union_pattern6.analysis_days_in_period: asc]
  }
}
