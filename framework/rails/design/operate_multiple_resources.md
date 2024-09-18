---
title: "Railsで複数リソースを一括操作する"
tags: ["Rails", "Tips"]
---

# Railsで複数リソースを一括操作する

## 前提
- RailsはRESTfulな設計を前提としている
- そのため、基本的にGET, POST, PATCH, DELETEの4つのHTTPメソッドは、単一のリソースの操作に対して行う

以上のことを前提に、それでも複数リソースを一括操作するユースケースが発生する場合は以下の方法を用いてる(あくまで一例)

# Controllerに複数リソース用のエンドポイントを用意する
- ex) `/api/v1/users/`の場合
  - `POST /api/v1/users/bulk_create`で複数ユーザーを一括作成
  - `POST /api/v1/users/bulk_update`で複数ユーザーを一括更新
  - ...etc

```ruby
# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      def bulk_create
        # ...
      end

      def bulk_update
        # ...
      end
    end
  end
end
```

- `routes.rb`にエンドポイントを追加する
- `member`や`collection`を使うってカスタムしたエンドポイントを作成
  - `member`と`collection`の違いは、`member`はリソースのIDを必要とするかどうか
  - https://gizanbeak.com/post/rails-member-collection
  - リソースの一括操作はIDを必要としないので、`collection`を使う方が適切
    - https://railsguides.jp/routing.html#%E3%82%B3%E3%83%AC%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E3%83%AB%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0%E3%82%92%E8%BF%BD%E5%8A%A0%E3%81%99%E3%82%8B
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        collection do
          post :bulk_create
          post :bulk_update
        end
      end
    end
  end
end
```

- 既存のHTTPメソッドと組み合わせる時は以下
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i(create update) do
        collection do
          post :bulk_create
          post :bulk_update
        end
      end
    end
  end
end
```

- `rails c`で確認すると以下のようなルーティングが確認できる

| HTTPメソッド | パス | コントローラー#アクション | 備考 |
|:-----------:|:----:|:-------------------------:|:----:|
| POST | /api/v1/users | api/v1/users#create | ユーザーを作成(通常のHTTPメソッド) |
| PATCH | /api/v1/users/:id | api/v1/users#update | ユーザーを更新(通常のHTTPメソッド) |
| POST | /api/v1/users/bulk_create | api/v1/users#bulk_create | 複数ユーザーを一括作成(カスタム) |
| POST | /api/v1/users/bulk_update | api/v1/users#bulk_update | 複数ユーザーを一括更新(カスタム) |
