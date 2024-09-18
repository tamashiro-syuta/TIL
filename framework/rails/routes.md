---
title: "ルーティング周りのTips"
tags: ["Rails", "Tips"]
---

# ルーティング周りのTips

## formatの指定
`format: :hoge`のように指定することで、そのパスへのリクエストが来た際にデフォルトのフォーマットを指定ができる

※ あくまでもデフォルトの設定なので、controller側でjsonで返せばjsonで返ってくる
```ruby
# routes.rb
get 'users/:id', to: 'users#show', defaults: { format: :csv }
```
