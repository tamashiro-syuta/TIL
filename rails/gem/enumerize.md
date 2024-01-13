# enumerize

## `.text`メソッド
gem `enumerize` を利用して、enumを定義した場合、`text`メソッドが使える。

i18で定義した値を取得することができる。
※ ローカライズファイルがない場合は、enumに定義した値がそのまま返る。(以下の例だと、`Table.new(column: :foo).column.text` で `foo`が返る。)

aliasとして、`カラム名_text`でも同様の結果を得ることができる。
  - `ex) table.column_text`

```ruby
# app/models/table.rb
class Table < ApplicationRecord
  extend Enumerize

  enumerize :column, in: { foo: 0, bar: 1, buzz: 2 }
end

```

```yml
# config/locales/ja.yml
ja:
  enumerize:
    table:
      column:
        foo: ふー
        bar: ばー
        buzz: ばず
```

```shell
$ rails c
> table = Table.new(column: :foo)

> table.column.text
=> "ふー"

> table.column_text
=> "ふー"
```
