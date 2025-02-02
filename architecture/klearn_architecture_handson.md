---
title: "手を動かしてわかるクリーンアーキテクチャ"
tags: ["アーキテクチャ", "テスト", "書籍"]
---

# 📝「手を動かしてわかるクリーンアーキテクチャ」のメモ

## 目的
  - 業務で触っているシステムがオニオンアーキテクチャやDDDに近い構成なので、それらの理解を深めるために読む
    - クリーンアーキテクチャと思って書籍買ったけど勘違いだったw
    - まあでも、近い構成だと思うので、エッセンスだけ取り入れたい
  - 今まではMVCフレームワークしか使ったことないので、他のアーキテクチャへの理解を触れてみる

***

# 保守容易性
- 様々ある品質要求において、「保守容易性」が一番重要
  - そのほかの全ての要素に影響を与えるため
- 保守性が低いと変更コストが上がり、エンジニアと非エンジニアの衝突が起きやすくなる
- だから、保守容易性の高いアーキテクチャを採用しようね

***

# 従来の多層アーキテクチャの何が問題なのか？
## 前提
- 保守容易性が重要なので、アーキテクチャはそれを実現するために設計される必要がある
  - 「RLS使いたいからMySQLからPostgreSQLに変えてね〜」って言われても対応できるように
  - 従来のアーキテクチャだとそれが難しい

## 従来の多層アーキテクチャとは
- Web層、ドメイン層、永続化層の3層構成
  - たぶんRailsで言うと、Web層がコントローラ、ドメイン層がモデル、永続化層がDB周り
- 依存の流れは、Web層 👉 ドメイン層 👉 永続化層
- アーキテクチャのルール
  - 上位層は自身と同じかそれ以下の層にアクセスできる
  - 下位層は上位層にアクセスできない(依存の流れに逆らわない)

## 何が問題？
- DB中心のアプローチ
  - DBのスキーマ変更がアプリケーション全体に影響を与える
- DB中心ではアプリを設計する際にDBのスキーマから設計する
  - アプリの目的は特定のドメインの課題を解決すること
  - ってことは本来は、**ドメイン(ビジネスロジック)を中心に設計すべき**
  - ドメインから設計できれば、エンジニアが技術的な要素を無視してドメインの設計に集中できる
  - でも依存の流れで、どうしてもDB中心になってしまう
- 「従来のアーキテクチャ × ORM」でよりDB中心が進む
  - ORMを使うことで、よりドメイン層と永続化層が密結合になりやすい
    1. エンティティが永続化層にある
    2. ドメイン層からエンティティにアクセスできる
    3. ドメイン層が永続化層の関心事まで扱う
        - Railsでもモデルは一般的にビジネスロジック〜DBまでを責務としている
    4. ドメイン層と永続化層が密結合になる
        - ドメイン層のコードに影響を与えずに永続化層のコードを変更するのが難しくなる

  ![従来の多層アーキテクチャ](/image/architecture/klean_architecture_handson/orm_with_mvc_architecture.jpg)

***

# 依存権系の逆転
[ Q ] 依存関係を逆転させてドメイン中心で設計するのはわかったけど、どうやって逆転すんねん。。。

[ A ] SOLID原則の「単一責任の原則」と「依存関係逆転の原則」を使って逆転していくよ♫

クリーンアーキテクチャにおいて、
単一責任の原則はWhy(ベースとなる考え方、なんでそうするのか？)で、
依存性逆転の原則はHow(どうやって実現するのか？)

## 単一責任の原則
- 単一責任の原則 = コンポーネントを変更する理由は、1つだけになるようにすべき
- クリーンアーキテクチャにおける単一責任の原則は「Why?(なんでそうするの?)」
  - ドメイン中心にするには、ドメインが他のコンポーネントに依存しないようにしないとね
  - そのためには、ドメイン層が単一責任の原則を守らないとね
  - 全部の層で依存なしは無理だし、ドメインが中心になるように内部の層にいくにつれて依存を減らしていくよ

## 依存関係逆転の原則
- 依存関係逆転の原則 = コードベース内の依存関係は、いかなるものであっても、その方向を逆転することができる
- クリーンアーキテクチャにおける依存関係逆転の原則は「How?(どうやって依存関係を逆転させるの?)」
  - 逆転させたいコンポーネントの`interface`を内側の層に定義する
  - 外側の層は内側の層の`interface`を実装する
  - そうすることで、層単位で見た時に外側の層が内側の層に依存するようになる

## クリーンアーキテクチャの各層の概要
![klean_architecture](/image/architecture/klean_architecture_handson/klean_architecture.jpg)

### 🟨 エンタープライズビジネスルール層(図の黄色)
- エンティティ
- ドメイン層の中心
- 他の層に依存しない
- ドメインに登場する「概念」を表現する
- ドメインの関心事(ビジネスルール)を実装する
  <details>
    <summary>ユースケースとの違い</summary>

    - エンティティ: アプリケーションの有無に関わらず、業務として行えること
    - ユースケース: アプリケーションの場合にのみ発生すること
  </details>
### 🟥 アプリケーションビジネスルール層(図の赤色)
- エンティティを操作する
- 一般的にサービス層と呼ばれるもの
  - 単一の責任しか持たないように扱うものの粒度をより細かくしたもの
- アプリケーションの関心ごとを実装する

### 🟩 インターフェースアダプタ層(図の緑色)
- ビジネスルールをサポートするもの(コントローラー、ゲートウェイ、プレゼンターなど)
  - 🟥 ユースケース と 🟦 外部のインターフェースをつなぐ役割
  - ex: 永続化、UI、外部接続、デバイス

### 🟦 フレームワーク、ドライバ層(図の青色)
- Web、UI、外部接続、DB、デバイスなど
- 使用しているWebフレームワーク(echoなど)や、データベースドライバなどの外部ライブラリの設定や初期化を行う層
- echo使った際のルートのmain.goもここに当たるよ byGPT

***

# パッケージ構成に関する戦略
- アーキテクチャの構成要素を意識したパッケージ構成がおすすめ
  - 以下は、ヘキサゴナルアーキテクチャのパッケージ構成例
  ```
  adapter/
    ├── in/
    │   └── web/
    │       └── SendMoneyController
    ├── out/
    │   └── persistence/
    │       ├── AccountPersistenceAdapter
    │       └── SpringDataAccountRepository
  application/
    ├── domain/
    │   ├── model/
    │   │   └── Account
    │   └── service/
    │       └── SendMoneyService
    ├── port/
    │   ├── in/
    │   │   └── SendMoneyUseCase
    │   └── out/
    │       └── UpdateAccountStatePort
  common/
  ```
- ほとんどのソフトウェアにおいて、アーキテクチャは単なる抽象的な概念に過ぎなく、コードと直接的に結びつかない
  - そのため、アーキテクチャをコードに落とし込むためには、パッケージ構成を意識した設計が必要
  - そうすることで実装時にアーキテクチャを意識した実装がしやすくなる

***

# ユースケースの実装
- ユースケースに必要な大まかなフロー
    1. 入力値を受け取る
    2. ビジネスルールに関する妥当性を検証する
    3. ドメインモデルの状態を変更する
    4. 出力値を返す

## ユースケースの実装のポイント
### 入力値の妥当性の確認はユースケースの責務ではない
- **ユースケースはビジネスルールの実装に集中する**
- 構文的な妥当性の確認は、ユースケースの外で行う
  - ex: ヘキサゴナルアーキテクチャの場合、`port`ディレクトリに入力モデルを作成し、そこでコンストラクタの引数が正しい入力値かを検証する
  - 入力モデルは基本的にユースケースと1対1の関係になるのが望ましい
  - 使い回しは、単一責任の原則に反するため避ける

### ビジネスルールに関する妥当性の検証はユースケースの責務
- **ユースケースはビジネスルールの実装に集中する(2回目)**
- ビジネスルールに関する妥当性の検証と入力値の妥当性の検証の区別する際の考え方
  - 入力値の妥当性の検証: 構文的にチェックできる、
  - ビジネスルールに関する妥当性の検証: エンティティの状態を利用して行う
  - 以下は、送金処理のユースケース例
    - 入力値の確認: 送金額が0以上か : ビジネスルールは関係ない
    - ビジネスルールの確認: 送金元の残高が送金額以上か : エンティティから値を取得する必要がある

### 出力モデルは必要最低限かつ単一責任の原則を守る
- 出力モデルも基本的にはユースケースと1対1の関係になるのが望ましい
- 出力モデルを使い回す = ほかのユースケースで必要だからと一方にとって不必要なデータまで返すことになる
  - これは単一責任の原則に反する

### `Getter`のみのユースケースの場合、`Getter`用のサービスを作るのもあり
- その際はファイル名に`Query`をつけて、これが`Getter`用のサービスだとわかるようにするのもあり
- 最悪、直接送信ポート層にアクセスする短絡的な実装もギリッギリ許容できなくもない

## 濃いドメインモデル と 薄いドメインモデル の違い
### 濃いドメインモデル
- ドメインロジックはドメインモデル内に集中する
- この場合のユースケースは、ユーザーが何を行おうとしているのかという意図を表現するだけ
  - イメージとしては入力値をドメインモデルに渡すために整形するだけ
  - BFF的な役割になる

### 薄いドメインモデル
- エンティティはフィールドのGetter/Setterしか持たない
- ドメインロジックの実装はユースケースに集中する

### どちらを選ぶべきか？
- 結論、PJ次第
- 逆に言えばどっちでも対応できまっせ

***

# Webアダプタの実装
- Webアダプタの責務はざっくり言うと`Controller` + `middleware`
  1. 送られてきたHTMLのリクエストをプログラムで利用可能なオブジェクトに変換する
  2. 認証/認可を行う
  3. (Webアダプタ層に送られてきた)入力値の妥当性を検証する
  4. 入力値をユースケースに渡す入力モデルに変換する
  5. ユースケースを呼び出す
  6. ユースケースの結果をHTMLのレスポンスに変換する
  7. HTTPレスポンスを送信する
- ユースケースがビジネスロジックに集中できるように、それ以外のHTMLの周りなどの責務をWebアダプタ層が持ってあげてるイメージ

***

# 永続化アダプタの実装
- 永続化アダプタの責務は、通常のDB層と同じ
  1. 入力モデルを受け取る
  2. 受け取った入力モデルをDBに対して操作を行えるもにに変換する
  3. その変換したものを使ってDBを操作する
  4. DBから帰ってきた結果をアプリケーションが扱える出力モデルに変換する
  5. 変換した出力モデルを返す
- 他の層と違うのは **「ポートをどのように分割するか？」**
  - よくある単一テーブルの操作を一つの送信ポートに実装すると、複数のサービスから呼び出しされる際に、そのサービスでは使わないメソッドにも依存することになる
    - ❌ メソッドは使わないのに依存先が増える
    - ❌ テストの際、使っていないメソッドまでモックしないといけない
    - ❌ テストの際、仮に使っていないメソッドはモックせずにいた場合、引き継いだエンジニアが完全にモックされたものと勘違いし、カバーできていないメソッドを新たに作るかもしれない
  - **「必要としないお荷物に依存していると、予期せぬトラブルの元につながるということだ」**
  - **インターフェイス分離の原則** に従って、クライアントの必要最低限のものだけ定義する
    - テーブル単位で実装するのではなく、ユースケース単位で実装する
    - コンテキストごとにフォルダ分けをして、フォルダ名で明示的に担当範囲を示すのも良い
- トランザクションをどこに実装すべき？？
  - 結論、PJによる
    - 個人的にはトランザクションもinterfaceとして定義すれば、依存関係を祖結合にして、別のDBに切り替える時とかにスムーズにできそう。実装していないのでイメージだけど
  - ユースケースに書く場合
    - メリット
      - 簡単に実装できる
    - デメリット
      - アプリケーションの核が汚れる
  - ドランザクションの仕組みを自前で実装
    - メリット
      アプリケーションの核が汚れない
    - デメリット
      - 実装コストが高い
***

# アーキテクチャの構成要素に対するテスト
大体他のアーキテクチャとかと変わらない考え方だったので割愛

***

# 境界を越える際のモデルの変換
## そもそもモデルの変換って何？
- `Controller`から`Service`にデータを渡す際に、`Controller`のモデルを`Service`のモデルに変換するかどうか
  - ex: モデルを変換しない場合、そのモデルは`Controller`からも`Service`からも依存され単一責任の原則に反する
  - ex: 異なるモデルに変換する場合、単純なCable処理の場合は返って実装の手間が増えるんじゃね？ってなる

## モデルの変換戦略を決める上での考え方
- システムの規模や成長によって適切な戦略は変わる
- 1つのシステムの中で、複数の戦略が混在することもあり、それを悪いとは言えない
  - **無理に1つの戦略のみを適用させて構造的にクリーンな状態を保っても、それは実質的には無責任な単純化を推し進めているだけ**
- 大事なのは **「なぜこの戦略を選択したかをチームで共有できているか？」**
  - 選択した背景や理由が共有できていると、システムに合う戦略を選択できなくなってきた際に、選択してきた戦略が正しかったのかの評価や、今のシステムに適切な戦略を選択する基準にもなる

## モデル変換の戦略まとめ
### モデルを変換しない
![モデルを変換しない](/image/architecture/klean_architecture_handson/no_change.jpg)
- メリット
  - 変換する処理が必要ないので、実装が楽
- デメリット
  - 呼び出す層それぞれの関心事が入ってしまい、依存が増える
- 向いているケース
  - CRUD処理などのシンプルな処理でユースケースが複雑ではない場合

### 双方向でのモデルの変換
![双方向でのモデルの変換](/image/architecture/klean_architecture_handson/khange_each_other.jpg)
- 核となるモデルを元に、アプリケーションの外側に専用のモデル作成し変換する
- メリット
  - 核となるモデルのデータが変更されない限り、各層のモデルには影響がない(単一責任の原則)
  - モデルの変換に関する責務が外側の各アダプタ層が担うため、理解しやすくシンプル
- デメリット
  - 多くのに通った手続き的なコードが生まれる
  - 受信ポートと送信ポートが入力値や戻り値にドメインモデルを用いている
    - アダプタがアプリケーションの核と密結合になる

### 徹底的なモデルの変換
![徹底的なモデルの変換](/image/architecture/klean_architecture_handson/khange_in_depth.jpg)
- 各層ごとにモデルを変換する
- メリット
  - 各層ごとにモデルができるため、必要最低限の過不足ないデータのみを持つモデルを作成できる
  - 層やユースケースごとに1つのモデルになるため、実装や保守が楽
- デメリット
  - シンプルに実装が増える
    - 本来解決したいドメインの課題ではなく、モデルの変換にコストがかかる

### 一方向でのモデルの変換
![一方向でのモデルの変換](/image/architecture/klean_architecture_handson/khange_one_direction.jpg)
- 核となるモデル、アプリケーションの外側に作成するモデルの全てが一つのインテーフェーを実装するようにする
  - 実装するインターフェースは、モデルの状態を取得する`Getter`メソッドのみが定義されたもの
  - 各モデルはこのインターフェースを実装しているので、さらにメソッド等を加えて自身のモデルに変換するか、そのまま利用するかを決めることができる
    - 逆に言えばそれを決めるのは、各層の責務
    - イメージは「共通のインターフェースで最低限の準備はしたから、やりたかった勝手に変換して〜」って感じで次の層に渡すイメージ
- メリット
  - 各層に不要な処理を強制することなく、各層が自由にモデルを変換できる
- デメリット
  - 変換に関するロジックを全ての層に散在させることになるため、コードの把握が難しい

***

# アプリケーションの組み立て
## 依存の向きを正しい向きにするには、ユースケースやアダプタなどの各層の生成は1箇所で行わないといけない
- 好きな箇所でそれぞれの層を生成すると、生成した場所に対して依存が生まれる
  - クリーンアーキテクチャではインターフェースに加えて、初期化時に引数として渡すことで依存の向きを制御しようねって考えだった
  - **🤔 「けどこれ、最終的にどこかで各オブジェクトを生成しないといけなくない？？」**

## 各層の初期化を担う「構成コンポーネント」を用意してそこで行う
![構成コンポーネント](/image/architecture/klean_architecture_handson/configuration_component.jpg)

- Goでいうとmain.goであったり、wireを使って入ればwire.goがそれに当たる(と思う)
- 全部の層の外側にこの構成コンポーネントが配置される
- 構成コンポーネントは次のことができないといけない
  - Webアダプタ層の生成
  - HTTPリクエストをWebアダプタ層に渡す
  - ユースケース層の生成
  - Webアダプタ層にユースケースのオブジェクトを渡す
  - 永続化アダプタのオブジェクトを生成
  - ユースケースに永続化層を渡す
  - 永続化アダプタがDBへアクセスできるようにする
- **🤔 「あれ？この「構成コンポーネント」ってやつめちゃくちゃ色んな層に依存して、単一責任の原則に反してない？？」**
  - YES!! めちゃくちゃ反しているぜ！！
  - むしろ、他のコンポーネントがクリーンアーキテクチャに反しないように、こいつがまとめて依存を担っている感じ

# ただし構成コンポーネントはライブラリやFWの機能に頼れ
- 手動でもできるが以下のデメリットがある
  - 実装するコード量が増える
  - 全てのクラスをパブリックにする必要があり、間違った方向へ依存させちゃう可能性がある
- ライブラリやFWに頼ることで実装を自動化し、ミスもなくせる

***

# 短絡的な実装への意図した選択
- いろんな具体例書いていたけど、全体に共通していることをメモ
- ビジネスのスピード感や市況感によって短絡的な実装になってしまうことはよくある(仕方ないが、エンジニアが「これは短絡的な実装だ」とわかって実装していることが大切)
  - 後のリファクタで直して良いところだとわかるから
- また、短絡的な実装になったことをドキュメントに残しチームに広く共有することも大切
  - 後のエンジニアが短絡的な実装になった背景を知ることで、背景や仕様が変わった際の判断基準になる
- だんだん仕様が複雑になっていくアジャイル開発では、短絡的な実装による正しくない依存関係は起きやすい
  - 最初は実装スピードを優先するが、プロダクトの発展に伴い仕様が複雑化し、ドメインエンティティ以外の要因でドメインエンティティが変更されることが多い(単一責任の原則、クリーンアーキテクチャの思想に反してる)
  - 大事なのは **「プロダクトの成長やビジネスの拡大のタイミングを見て、適切な時期に適切なリファクタをする判断ができること」**
- よくある短絡的な実装例
  - ユースケース間でモデルを共有
  - 入力モデルもしくは出力モデルとしてのドメインエンティティの使用
  - 受信ポートの省略
  - サービスの省略

***

# アーキテクチャ内の境界の維持
- 時間の経過や規模の拡大によってアーキテクチャは徐々に崩れていく傾向にある
- アーキテクチャ内の境界を維持する = 依存が正しい向きで行われているかを遵守させる

## 間違った方向へ依存させないためには？
- 以下の順で検討、実施すると良い

### アクセス修飾子を用いた境界の意地
- `public`, `protected`, `private`, `package private`などを使って意図しない呼び出しができないように設計する
- 書籍では特に`package private`を推している
  - `package private`を駆使することで、よろい凝集度の高いパッケージにすることができる
- `TODO:` 書籍ではJavaで説明しているので、Goだとどうなのか調査する

## 適応度関数(`fitness function`)の活用
- 初耳だけど、適応度関数ってやつがあるらしい
- 適応度関数の概要
  > 採用しているアーキテクチャを入力値として、特定の条件(今回の場合だと、依存のルールが遵守されているのか)に関してその適用度を判断するもの
- こいつをCIに組み込んだら良いよねって話らしい
- `TODO:` JavaだとArchUnitってやつが有名らしい。Goではどういうのがあるか調査する

## 成果物の分割
- ビルドの単位をパッケージごとなど狭くすることで、ビルドに失敗する = 依存関係が間違っている として判断する方法
- ※ そもそもビルド時に判別できるのが理想なので、これは優先度は低め
- 同じ層だとビルドツールでは防げないので注意が必要
  - ex: Webアダプタと永続化アダプタは層は同じだが、これらが依存関係にあるのは通常ないのでもし依存していれば検知したい
  - 対策としては、アダプタモジュールをアダプタの種類ごとに分ける

## まとめ
- アーキテクチャにおいて重要なのは依存の管理
- 依存関係は定期的に確認が必要
- マンパワーじゃなくて、上の3つのような仕組みで解決できる方が望ましい

***

# 複数の境界づけられたコンテキストの管理

ちょっと難しかったので、割愛。(メモ取れるほど理解できなかったww)

***

# コンポーネント基盤のアーキテクチャ


***

# アーキテクチャの決定

テスト
