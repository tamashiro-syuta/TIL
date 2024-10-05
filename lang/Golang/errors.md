---
title: "error型"
tags: ["Go"]
---
# error型 の基本
Goのプログラムは、エラーの状態を error 値で表現します。

error 型は fmt.Stringer に似た組み込みのインタフェースです

```go
type error interface {
    Error() string
}
```

よく、関数は error 変数を返します。そして、呼び出し元はエラーが nil かどうかを確認することでエラーをハンドル(取り扱い)します。

nil の error は成功したことを示し、 nilではない error は失敗したことを示します。
```go
i, err := strconv.Atoi("42")
if err != nil {
    fmt.Printf("couldn't convert number: %v\n", err)
    return
}
fmt.Println("Converted integer:", i)
```

```go
package main

import (
	"fmt"
	"time"
)

// NOTE: カスタムエラーを定義
type MyError struct {
	// NOTE: エラーが発生した時間
	When time.Time
	// NOTE: エラーの内容
	What string
}
// NOTE: MyError型はErrorメソッドを実装することでerrorインターフェースを実装している
// NOTE: ※ errorインターフェースはError() stringメソッドを持つインターフェース
func (e *MyError) Error() string {
	return fmt.Sprintf("at %v, %s",
		e.When, e.What)
}

// NOTE: カスタムエラーを返す関数
func run() error {
	return &MyError{
		time.Now(),
		"it didn't work",
	}
}

func main() {
	// NOTE: err には、run関数から返されたMyError型のポインタが代入される = ポインタが返されるので、nilチェックがが可能
	if err := run(); err != nil {
		fmt.Println(err)
	}
}

// NOTE: 出力結果
// at 2009-11-10 23:00:00 +0000 UTC m=+0.000000001, it didn't work
```
