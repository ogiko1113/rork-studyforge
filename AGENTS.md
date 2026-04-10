# AGENTS.md — StudyForge (SwiftUI iOS)

## このリポジトリについて
- SwiftUI ネイティブ iOS アプリ（Swift 5 / iOS 18）
- Xcode プロジェクト: ios/StudyForge.xcodeproj
- **Expo / React Native / TypeScript ではない**
- CLAUDE.md にデータモデル・SM-2仕様・StorageKeys の定義あり（変更禁止）

## ディレクトリ構成
```
ios/StudyForge/
  Models/          → Card.swift, ReviewLog.swift（データ定義のみ）
  Services/        → SM2.swift, StorageService.swift, ImportParser.swift（純粋ロジック）
  ViewModels/      → StudyDataStore.swift（状態管理、唯一のStorage呼び出し元）
  Views/           → 画面単位のSwiftUI View（ロジック禁止、表示とユーザー操作のみ）
  Components/      → 再利用UIパーツ（状態を持たない、propsで受け取る）
  Utilities/       → DateHelper.swift, Theme.swift（ヘルパー）
ios/StudyForgeTests/
ios/StudyForgeUITests/
```

## アーキテクチャルール

### レイヤー分離（厳守）
- Views/ にビジネスロジックを書かない。SM-2計算、フィルタ、集計は ViewModels/ または Services/ に置く
- Models/ はデータ定義のみ。メソッドを持たせない
- StorageService を直接呼ぶのは StudyDataStore のみ。Views から直接 StorageService を呼ばない

### ファイルサイズ制限
- 200行以下: OK
- 200〜250行: ⚠️ 次の変更時に分割を検討
- 250〜300行: 🟡 変更前にリファクタリング計画を立てる
- 300行以上: 🔴 先にファイルを分割してから変更する

## ビルド・テスト
```bash
xcodebuild -project ios/StudyForge.xcodeproj \
  -scheme StudyForge \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug build

xcodebuild -project ios/StudyForge.xcodeproj \
  -scheme StudyForge \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## 変更時のルール
1. CLAUDE.md のデータモデル・SM-2仕様・StorageKeys は変更禁止
2. 外部ライブラリを追加しない
3. API通信・Firebase・Supabase・SQLite を導入しない
4. Swift コードを変更したら必ずビルド確認する
5. ロジック変更にはユニットテストを追加する
6. UI変更はダークモード・Dynamic Type・空状態の3点を確認する
7. 日本語UIの折り返し・刈れ・レイアウト崩れに注意する
8. ハードコードの数値は定数化する

## 変更前の確認事項（全作業で必ず実行）
1. xcodebuild build が通ること
2. xcodebuild test が通ること
3. 300行超の Swift ファイルがないこと
4. `grep -rn 'URLSession\|Alamofire\|Firebase\|Supabase' ios/StudyForge/` が0件
5. StorageKeys の値が変わっていないこと

## Done の定義
- ビルドが通る
- 既存テストが全てパスする
- 変更対象に関連するテストが追加されている（ロジック変更の場合）
- CLAUDE.md の仕様に違反していない
- 300行超のファイルが生まれていない

## 参照ドキュメント
- CLAUDE.md → データモデル、SM-2仕様、Phase 0制約の正式定義
- PLAN.md → 機能・UI仕様
