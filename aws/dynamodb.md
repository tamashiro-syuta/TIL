# Dynamo db 概要

- [公式のハンズオン資料](https://docs.aws.amazon.com/ja_jp/amazondynamodb/latest/developerguide/getting-started-step-1.html) を触りながらのメモ

## 単一データの取得

- パーティションキーとソートキーを指定して取得する
  ```shell
  aws dynamodb get-item --consistent-read \
          --table-name Music \
          --key '{ "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "Howdy"}}'
  ```

## データの更新
- 多分、パーティションキーとソートキーはセットで RDB でいうプライマリーキー(複合主キー)的な存在になるからデータを一意に特定できるはず
  - 調べたら、パーティションキーは必須で、ソートキーは任意らしい
  - AWS CLI でも、`--key` オプションで指定しているから、そうだと思う(以下、例)
  ```shell
  aws dynamodb update-item \
          --table-name Music \
          --key '{ "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "Happy Day"}}' \
          --update-expression "SET AlbumTitle = :newval" \
          --expression-attribute-values '{":newval":{"S":"Updated Album Title"}}' \
          --return-values ALL_NEW
  ```
- パーティションキーとソートキーは変更できない
  - 変更しようとすると以下のようなエラー
    ```shell
    An error occurred (ValidationException) when calling the UpdateItem operation: One or more parameter values were invalid: Cannot update attribute SongTitle. This attribute is part of the key.
    ```
  - 意訳すると、`SongTitle` はキーの一部なので変更できないよ、というエラー

## 複数データの取得
- パーティションキーを指定して取得する
  ```shell
  aws dynamodb query \
          --table-name Music \
          --key-condition-expression "Artist = :name" \
          --expression-attribute-values  '{":name":{"S":"Acme Band"}}'
  ```
- パーティションキー以外を指定して取得するにはグローバルセカンダリインデックス(GSI)を設定する必要がある
- GSIをインデックスとして検索
  - GSIの解説は[グローバルセカンダリーインデックス(GSI)](#グローバルセカンダリーインデックスgsi)を参照
  - `--index-name AlbumTitle-index` でインデックスを指定(デフォルトでは、パーティションキー)
  ```shell
  aws dynamodb query \
          --table-name Music \
          --index-name AlbumTitle-index \
          --key-condition-expression "AlbumTitle = :name" \
          --expression-attribute-values  '{":name":{"S":"Somewhat Famous"}}'
  ```

# グローバルセカンダリーインデックス(GSI)
  - GSIは、超簡単にいうと、パーティションキー以外で検索するためのインデックス
  - GSIを作成する際には、そのキー属性がテーブルのすべての項目に存在することを確認する必要がある(not null 制約みたいなもの)
  - GSIは「イベンチャル整合性」があり、テーブルへの書き込みがすぐにGSIに反映されるわけではなく、短い遅延があるので注意
  - GSIの作成ではインデックスの他にソートキーも新しく設定できる
    - **つまり、GSIを作るのは、既存のデータに新しくschemaを追加するようなイメージ**

# テーブル設計で考えそうなこと(GPT君に聞いたベストプラクティス)
- アクセスパターンを理解する
  - DynamoDBのテーブル設計の最初のステップは、アプリケーションのアクセスパターンを理解することです。どのようなクエリが実行されるのか、どの項目が最も頻繁にアクセスされるのかを理解することで、最適なテーブル設計を行うことができます。
- 単一テーブルデザイン
  - 可能な限り単一テーブルデザインを採用することを推奨します。これは、複数のテーブル間でジョインを行う必要がなく、パフォーマンスを最適化するためです。
- 適切な主キーを選択
  - 主キーはテーブル内の各項目を一意に識別します。適切な主キー（パーティションキーとオプションのソートキー）を選択することで、データの分散とアクセスパフォーマンスを最適化できます。
- インデックスを効果的に使用
  - 頻繁にアクセスされる項目に対しては、グローバルセカンダリインデックス（GSI）またはローカルセカンダリインデックス（LSI）を作成することで、クエリのパフォーマンスを向上させることができます。
- 読み取り/書き込み容量モードを適切に選択
  - DynamoDBはオンデマンドとプロビジョニングの2つの読み書き容量モードを提供しています。アクセスパターンが不確定な場合や突発的なトラフィックが予想される場合はオンデマンドモード、一定のトラフィックが予想される場合はプロビジョニングモードを選択します。
- 項目のサイズを最小限に保つ
  - DynamoDBの料金は保存するデータの量に基づいているため、不要なデータは削除し、項目のサイズを最小限に保つことが重要です。
