---
title: "activerecord-importの`on_duplicate_key_update`オプションについて"
tags: ["Rails"]
---

# `on_duplicate_key_update`オプションについて
毎度毎度、忘れてしまうのでメモ。(戒め)

## 超要約すると...
- idが被ったデータに関しては、`on_duplicate_key_update`で指定したやつは更新しますよ。
- idが被っていないやつは、新しいレコードとして追加しますよ。
