---
title: "「手を動かしてわかるクリーンアーキテクチャ」のメモ"
tag: "アーキテクチャ"
---

# 依存権系の逆転

## クリーンアーキテクチャの各層の概要
![clean_architecture](/image/architecture/clean_architecture_handson/clean_architecture.jpg)


### 🟥 アプリケーションビジネスルール層(図の赤色)
- エンティティを操作する
- 一般的にサービス層と呼ばれるもの
  - 単一の責任しか持たないように扱うものの粒度をより細かくしたもの
- アプリケーションの関心ごとを実装する
