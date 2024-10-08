---
title: "「手を動かしてわかるクリーンアーキテクチャ」のメモ"
tags: ["イベント", "Nextjs", "技術選定"]
---

# チーム開発に耐える技術選定
## Next.jsの使い方(例)
- フロントエンドのみで使っている
- バックエンド感のI/F定義はOpenAPI
- Next.js === BFF として使っている

## Next使う上での2つの鉄則
### 共通化しすぎない
  - 失敗例
    - ステークホルダーが違うとリリースサイクルが合わない
    -UIの共通化
      - UIは偶発的・論理的な凝集になりやすい
      - UIの共通化は非常に外しやすい
    - 共通パッケージを使っても、みんな使うと限らない。
      - 速度よりメンテコストの方が高い
      - WORKSPACE内のINTERNAL PACKAGE化にとどめている
      - ボイラーテンプレートでコードを生成するのも良い

### ツールは薄く使う
  - 独自のツールを作ると、辛くなる
    - 未来予測は難しい。課題が出てきてから対応する
    - linterなどは移り変わりが早い
    - ツールのメンテナンスが大変
    - システムの課題が何か？導入するツールがそれを解決するか？の視点が大事
    - Turborepoの初期セットが大体満たせている。
  - デファクトがない => 「長いものに巻かれろ」
    - 長いもの = Vercel
    - 長いものに巻かれる = Next  + turborepo
    - turborepoの使い道
      - リリースサイクルや性質、同一経済圏で物レポを構築
    - 考えるな、ドキュメントを読め
  - 説明コストを限りなく 0 にする
