---
title: "フロントエンドの技術選定 ~2023を振り返る~ Lunch LT"
tags: ["フロントエンド", "技術選定", "イベント"]
---

# フロントエンドの技術選定 ~2023を振り返る~ Lunch LT
- Connpassリンク
  - https://findy.connpass.com/event/306714/

## メモ

### LT①「僕はWeb標準との触れ合い方をRemixに教わった」
- remixのメリット
  - Web標準に沿っているので、remixをやるとWeb標準に詳しくなる

### LT②「React ViteからNext.jsへ切り替えたプロセスとApp Router化のボトルネック」
- ViteからNext.jsへの移行
  - チャンクの取得が遅い
    - ページごとにバンドルされるので、4MBからMAX1MBまで短縮
  - レンダリングが遅い
    - 200ms -> 50ms に短縮(Nextのプリレンダリング👏)
    - JSは実行されるがハイドレーションのみでレンダリングには関係なかった
  - ↑ Nextに乗り換えるだけで、パフォーマンスが向上した
  - 移行プロセス
    - viteとNextが共存する環境を用意
    - pagesを1つずつ切り出して移行
- App Router化のボトルネック
  - Next(Pages Router)でFCPは改善したが、LCPは変わらず...
    - App Routerに移行したい
  - ボトルネックはルーティング
    - Pages Routerは、ルーティングとブラウザバックをサポートしており、そのためにPages RouterのAPIに大きく依存している
      - App Routerではまだサポートがされていない
      - 今後はサポートされそう？らしい
- 移行期間とプロセス
  - 1ヶ月くらいかけた
- Routing以外の懸念点
  - ZeroRunTimeCssInJSを導入するかもくらい
  - パフォーマンスに関する懸念はない
### LT③「一休レストランで Next.js App Router から Remix に乗り換えた話」
- App Router採用理由
  - Pages Routerを使っていたので、ある程度ノウハウあり
  - RSCの発表があった
    - 一休ではtoCサービスなので、チューニングできそうだったのが魅力
- App Router問題理由
  - 実現が難しそうな
    - HistoryAPI のstateを操作できない
      - 予約までの流れをオーバーレイで実装している
      - URLは変更したくない -> （空席情報など時間ごとに変化の激しい情報なので）共有できないようにしたい
      - 今だと、App RouterからHistoryAPIを操作できるようになってる
    - Cache Controlを自由に設定できない
      - NextのConventionで設定される
    - ばーじょナップ
      - パッチバージョンを上げると、buildできないことが何回か起きてた
      - e2eがあるわけではないので、検証が大変
- Remixの採用
  - HistoryAPIのstateを操作できる
  - Cache Controlを自由に設定できる
    - RequestからResponseを返すだけでシンプル！
  - アップデートへの安心感
    - Shopify傘下になったことで、破壊的変更も緩和されるはず(App Routerよりはマシそう)
  - Web標準APIの重視が魅力的
- 乗り換えた結果
  - 問題なく追随できている
  - CDNを有効活用して、レスポンス速度を改善できた
  - cacheが使える -> prefetchを積極的に使える
  - (意図してないが)
    - メモリ使用量が1/4になった
    - CloudRunのコンテナ起動が20秒強から10秒になった
- 今後の展望
  - View Transitions APIの活用など...
### LT④「Next.js App Router を例に考える、技術との距離感と技術選定」
- 事前に決まっていたこと
  - フロントはReact
- 採用するにあたり
  - WebFWの外側の仕組みを決めたい
    - build, routing etc...
- 開発スタート時の意思決定
  - Next.js（AppRouter）を採用
    - AppRouterへの深入りはしない
  - なぜApp Routerを導入？？？
    - 「ルーティング機構とそれに最適化されたビルドシステが欲しい」
  - 学習コスト高くない？？？
    - RSC, SSRなどに深入りせず、Routingのメリットのみを享受する選択をとれば、学習コストは低い
  - RSCなどん変化に期待と投資
    - 今後のメインストリームになりそう
    - ※ ただし、深煎りはしない!!!(良いバランスを保ってやる) -> 良いとこどりしよう
- 意思決定時に重要視したこと
  - Bet Technology, but 撤退可能
    - 発展途中で、まだ良くなりそう
    - 決定的な差がない場合は、入れる or 入れない ではなく、Bet Technology, but 撤退可能に保つのもアリ
  - 優先度の低い観点を見極める
    - パフォーマンスが低かったので、App Routerを採用して失敗しても撤退可能だし、学習コストを抑えられる
  - 適度に距離を保つのも選択肢になる
- 実際のリリースでは...
  - Pages Routerへ移行した
    - Routing周りで実現できない問題があった
    - 1日ないくらいで差し戻しできた(「Bet Technology, but 撤退可能」のおかげ)

### その他メモ
