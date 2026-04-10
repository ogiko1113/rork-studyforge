# StudyForge — CLAUDE.md

## プロジェクト概要
汎用フラッシュカード学習アプリ「StudyForge」。
SM-2間隔反復スケジューリング、完全なオフライン、Android配信。
Re:Memo開発前の「学習アプリUX検証」ツールとして位置づける。

## 現在のフェーズ
**Phase 0: オフラインMVP**
- 音声なし、API通信なし
- ローカルSM-2 + UserDefaultsのみ
- 実機でユーザー行動データ収集が目的

## 将来の拡張候補（Phase 1以降で検討）
- 音声teach-back（Re:Memo技術の先行検証）
- AI問題生成（テキストからフラッシュカード自動生成）
- Supabase連携（クラウド同期、ユーザー分析）
- 課金（段階的サブスクリプション）

※ Phase 0では上記を一切実装しないが、拡張時にデータモデルの破壊的変更が不要な設計を意識する。

## 技術スタック
- SwiftUI ネイティブ iOS アプリ（Swift 5 / iOS 18）
- Xcode プロジェクト: ios/StudyForge.xcodeproj
- UserDefaults（Phase 0唯一の永続化手段）
- SwiftUI Animation（カードめくり）
- SF Symbols アイコン
- アクセントカラー: #6366F1

## データモデル（変更禁止）
```swift
struct Card: Codable, Identifiable {
    let id: String
    var front: String       // 表面（問題）
    var back: String        // 裏面（答え）
    var deck: String        // デッキ名
    var ef: Double          // EaseFactor 初期値2.5
    var interval: Double    // 日数
    var repetitions: Int    // 成功連続回数
    var nextReview: Double  // timestamp ms
    var lastReview: Double  // timestamp ms
    var grade: Int          // 最後の評価
    var created: Double     // timestamp ms
}

struct ReviewLog: Codable, Identifiable {
    let id: String
    let cardId: String
    let deck: String
    let grade: Int
    let reviewedAt: Double  // timestamp ms
    let success: Bool       // grade >= 3
}
```

## SM-2アルゴリズム（変更禁止）
- grade: 1=もう一度, 3=難しい, 4=普通, 5=簡単
- grade >= 3（成功）: rep0→1日, rep1→6日, else→round(interval*EF), rep++
- grade < 3（失敗）: rep=0, interval=1日
- EF = max(1.3, EF + 0.1 - (5-grade)*(0.08 + (5-grade)*0.02))
- nextReview = now + interval * 86400000
- EF更新はgrade<3でも行う
- 新規カード: nextReview = created（即復習対象）

## UserDefaults Keys（変更禁止）
- studyforge_cards
- studyforge_review_logs

## 画面構成
1. ホーム → デッキ一覧（due数ソート、長押しで削除ダイアログで詳細）
2. 復習 → デッキ選択 → めくりカード → 4段階評価 → 完了画面
3. 追加 → 単体/一括（TAB/CSV）、デッキ選択or新規作成
4. 統計 → サマリー4つ、7日棒グラフ、デッキ別進捗、平均EF

## 制約（Phase 0）
- 外部API通信禁止
- Firebase/Supabase/SQLite追加禁止
- 外部ライブラリ追加禁止（SPM/CocoaPods/Carthage いずれも）
- データモデルのフィールド名変更禁止
- UserDefaults key変更禁止
