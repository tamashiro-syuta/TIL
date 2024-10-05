---
title: "package"
tags: ["Go"]
---
# パッケージのimport
>Goでは、最初の文字が大文字で始まる名前は、外部のパッケージから参照できるエクスポート（公開）された名前( exported name )です。 例えば、 Pi は math パッケージでエクスポートされています。

> 小文字ではじまる pi や hoge などはエクスポートされていない名前です。

- `math.pi` はエラーになる
  - piなんて知らないぞってなる。exportは必ず大文字から始まるので
- `math.Pi` はエラーにならない
- そういえば、`fmt.Println()`の`Println`も大文字から始まっている

```go
package main

// NOTE: パッケージのimportでは、イアのようにまとめてグループ化して書くのが一般的らしい
import (
	"fmt"
	"math"
)

func main() {
	fmt.Println(math.Pi)
}
```
