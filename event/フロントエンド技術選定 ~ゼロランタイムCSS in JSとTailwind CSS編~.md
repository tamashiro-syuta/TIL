---
title: "これからのスタイリング、どう向き合っていく？〜技術選定と事業成長の狭間で〜"
tags: ["イベント", "CSS", "フロントエンド"]
---

# これからのスタイリング、どう向き合っていく？〜技術選定と事業成長の狭間で〜
## CSSライブラリの技術選定の観点
- Web標準に準拠しているか？離れ過ぎていないか？
- 既存の資産を移行しやすいか？？
- 外部ライブラリの依存度は少ないか？？

デファクトがない分、移植性が高い方が良いよね。

# デザインシステムを`Tailwind CSS`と`CSS in JS`の両対応で作っておいてよかった話
## tailwind(ユーティリティファーストなCSSライブラリ)の採用理由
### 背景
- 複数プロダクトでも共通のデザインシステムを持って会社としてブランディングしたい(2020当時)

PostCSSべーすなので、css in JS ではないため、JSに依存してない = CSSが動けば動く！
色やスペーシングなどを統一できれば、styledコンポーネントにしなくても、共通化しやすい

### 普及した方法
- 途中から導入しやすい方針にしたのが良かった
- デザインガイドラインに沿っていないと目立つので、レビューしやすい
  - `mb-[26]`など、`[]`が入るので、目立つ

### 疎結合が選択肢を生む
- 技術の移り変わりが早いので、デザインシステムを依存度を下げるだけでなく、選択肢を増やすことができると移行しやすかった


# 甘い香りに誘われて`vanilla-extract`を1年間運用してみた
## vanilla-extractとは
- ゼロランタイムのCSSinJS
- ビルド時にCSSファイルを生成

## 選定材料
### 背景
- JSランタイム環境が必須なツールはRSCで利用不可(ChakuraUIなど)
- システムの移行でUIは徐々に変化、どう進めるか不明確だった

### 理想
- デザイントークンを定義、運用したい
- ライブラリは問わずユーティリティファーストで実装したい (TailwindCSS, CSSinJSのような)

## 運用した振り返り
- RSC起因の問題は特になし
- Next側の問題で、CSSの読み込みが遅れて、ページ遷移でチラつく
- 学習コストが低いのはオンボーディングが楽
- ただのJSなので、IDE拡張も不要

↓↓↓ tailwindを導入する流れになった(vanilla-extractと併用中) ↓↓↓
- tailwindのやり方に乗ったやり方 = 制約がある
- 途中から方針を変更になったが、方針が未定な状態からtailwindを使うと、違う方針になった場合移行しにくかったはず
  - 最初の未確定要素が多いフェーズでは、vanilla-extractの選択肢はアリ

# `Kuma UI`の設計思想と頑張らないゼロランタイムCSS-in-JS
## Kuma UI の設計思想
- 目的は、開発体験の維持 & エコシステムへの追従
  - RSCのような環境での利用できないと生き残れない...
  - 描き心地が良い
  - パフォーマンス特化というわけではない
- RSCで動くCSSinJSを作ろう！
  - 静的解析ができるスタイルはゼロランタイム
  - できないものはランタイム + SSRで対応
- パフォーマンスも悪くないが、主目的はエコシステムへの互換性!!!

## まとめ
- 社内システムなど、パフォーマンス要件が緩い要件
  - ランタイムCSSinJS + 必要に応じてSSR
- toCなどのパフォーマンスを気にする要件
  - ランタイムCSSinJS + SSR + (ボトルネックに応じてゼロランタイム + RSC)
- edge環境などにデプロイしたいからバンドルサイズを小さくしたい
  - ゼロランタイム + RSC + (一部Lazy Load)
