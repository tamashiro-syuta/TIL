---
title: "Zenn,しずかなインターネット「どうやって開発したの？」開発者catnoseさんにきいてみた"
tags: ["イベント", "個人開発"]
---

# Zenn,しずかなインターネット「どうやって開発したの？」開発者catnoseさんにきいてみた
- Connpassリンク
  - https://findy.connpass.com/event/306774/

## メモ
- 時間を作るコツ
  - 作りたいものがあるときは、SNSを見ない!!w
- 個人開発のスケジュール感
  - ざっくりしたスケジュール感を引く
  - MVPを作って、一旦リリースする
  - あとはサンクコストに任せて、継続していく
- しずかなインターネットでは、最初に記事一覧とエディターから開発してた
  - 一つの機能を作り込んで、モチベを上げてた
- サービス決定からアーキテクチャ選定までのフロー
  - ざっくりとしたUI、ページ遷移から決める
    - **UIを決めてからじゃないと、エンドユーザー目線に立った開発ができない**
    - 自分が使っててストレスのないUIを作る
  - テーブル設計
  - 開発スタート
- 機能をどう削ぎ落とすか？
  - MVPリリースでは最低限
  - あってもなくても良い機能は削る
- ZennではRailsを使っていたが、見送った理由は？
  - Cloud Run + Next でスケールしやすい構成にしたかった
  - Railsのときはスケールに時間かかってた
- 技術選定は、運用コストを最低限に抑えられるものを選んでいる
