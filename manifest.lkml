# ==================================================
# Looker での期間比較のパターン集
# --------------------------------------------------
# パターン一覧
# オリジナル版 (期間重複不可)
#   1. 組込期間 vs 組込期間 (軸変更: Explore操作)
#   2. 組込期間 vs 組込期間 (軸変更: Filter操作のみ)
#   3. 任意期間 vs 組込期間
#   4. 任意期間 vs 複数組込期間
#   5. 任意期間 vs 任意期間 (軸指定: 不可)
#   6. 任意期間 vs 任意期間 (軸指定: 期間内 経過日数のみ)
#   7. 任意期間 vs 直前期間 (軸指定: 任意のtimeframe)
#
# Union版 (期間重複許容)
#   3. 任意期間 vs 組込期間
#   4. 任意期間 vs 複数組込期間
#   5. 任意期間 vs 任意期間 (軸指定: 不可)
#   6. 任意期間 vs 任意期間 (軸指定: 期間内 経過日数のみ)
#
# Reference:
# https://community.looker.com/technical-tips-tricks-1021/methods-for-period-over-period-pop-analysis-in-looker-30823
# ==================================================
project_name: "looker-pop-patterns"