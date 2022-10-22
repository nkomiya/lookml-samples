# ======================================================================
# オリジナル版
# ----------------------------------------------------------------------
# PivotやLiquidを利用して、レコードを各期間に振り分ける方法。
#
# 制限:{
# 分析/比較期間に重なりがある場合は不整合を生じる。
#
# 例として、下記のように実績の昨日比推移を取得したい場合、
# 期間に重複があると複数行で参照が必要なデータが生じる (下表だと2022-10-20分)。
#   見たい形式           | 参照が必要なデータ
#   ---------------------+-------------------
#   分析期間日付  昨日比 | 当日実績  昨日実績
#   2022-10-21    xxx    | yyy       zzz
#   2022-10-20    xxx    | yyy       zzz
#   ...           ...    | ...       ...
#
# SQLで上記を達成するには、JoinやWindow関数が必要となり、
# オリジナル版のmethod1 ~ 7では実現不可。
# }
# ======================================================================
include: "/views/master/users.view"
include: "/views/master/products.view"
include: "/views/transaction/*.view"
include: "/views/transaction/pop/*.view"

explore: pop {
  label: "PoP patterns"
  view_label: "01. Order Items"
  view_name: order_items
  from: order_items

  # ------------------------------
  # filters for PoP
  # ------------------------------
  sql_always_where:
        ${pop_pattern3.is_inactive_or_axis_in_any_period}
    AND ${pop_pattern4.is_inactive_or_axis_in_any_period}
    AND ${pop_pattern5.is_inactive_or_axis_in_any_period}
    AND ${pop_pattern6.is_inactive_or_axis_in_any_period}
    AND ${pop_pattern7.is_inactive_or_axis_in_any_period}
  ;;

  # ------------------------------
  # joins for PoP
  # ------------------------------
  #{
  join: pop_pattern2 { view_label: "_Pattern 2: 制御用" }
  join: pop_pattern3 { view_label: "_Pattern 3: 制御用" }
  join: pop_pattern4 { view_label: "_Pattern 4: 制御用" }
  join: pop_pattern5 { view_label: "_Pattern 5: 制御用" }
  join: pop_pattern6 { view_label: "_Pattern 6: 制御用" }
  join: pop_pattern7 { view_label: "_Pattern 7: 制御用" }
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
  query: pop_pattern1_example {
    label: "1. 組込期間 vs 組込期間"
    description: "軸変更: Explore 操作"
    dimensions: [order_items.created_month_name]
    pivots: [order_items.created_year]
    measures: [order_items.order_count]
    sorts: [order_items.created_month_name: asc]
  }

  query: pop_pattern2_example {
    label: "2. 組込期間 vs 組込期間"
    description: "軸変更: フィルタ操作"
    dimensions: [pop_pattern2.analysis_axis]
    pivots: [pop_pattern2.group_unit]
    measures: [order_items.order_count]
    filters: [
      pop_pattern2.analysis_axis_selector: "Month",
      pop_pattern2.group_unit_selector: "year",
      order_items.created_date: "2 years",
    ]
    sorts: [pop_pattern2.analysis_axis: asc]
  }

  query: pop_pattern3_example_pivot {
    label: "3. 任意期間 vs 組込期間"
    dimensions: [pop_pattern3.analysis_period_date]
    pivots: [pop_pattern3.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_pattern3.analysis_period_filter: "7 days",
      pop_pattern3.compare_period_selector: "Week",
    ]
    sorts: [pop_pattern3.analysis_period_date: asc]
  }

  query: pop_pattern4_example_pivot {
    label: "4. 任意期間 vs 複数組込期間"
    dimensions: [pop_pattern4.analysis_period_date]
    pivots: [pop_pattern4.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_pattern4.analysis_period_filter: "7 days",
      pop_pattern4.compare_period_selector: "Week",
      pop_pattern4.compare_period_number_selector: "2",
    ]
    sorts: [pop_pattern4.analysis_period_date: asc]
  }

  query: pop_pattern5_example_pivot {
    label: "5. 任意期間 vs 任意期間"
    description: "日付軸: 設定不可"
    dimensions: [users.traffic_source]
    pivots: [pop_pattern5.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_pattern5.analysis_period_filter: "7 days",
      pop_pattern5.compare_period_filter: "14 days ago for 7 days",
    ]
  }

  query: pop_pattern6_example_pivot {
    label: "6. 任意期間 vs 任意期間"
    description: "日付軸: 期間内 経過日数のみ"
    dimensions: [pop_pattern6.analysis_days_in_period]
    pivots: [pop_pattern6.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_pattern6.analysis_period_filter: "7 days",
      pop_pattern6.compare_period_filter: "14 days ago for 7 days",
    ]
    sorts: [pop_pattern6.analysis_days_in_period: asc]
  }

  query: pop_pattern7_example_pivot {
    label: "7. 任意期間 vs 直前期間"
    description: "日付軸: 任意のtimeframe"
    dimensions: [pop_pattern7.analysis_period_date]
    pivots: [pop_pattern7.period_name]
    measures: [order_items.order_count]
    filters: [
      pop_pattern7.analysis_period_filter: "7 days",
    ]
  }
  #}
}
