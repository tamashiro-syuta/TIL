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

errorがないことを nil で表現するのは **nilがインターフェースのゼロ値** だから

```go
i, err := strconv.Atoi("42")
if err != nil {
    fmt.Printf("couldn't convert number: %v\n", err)
    return
}
fmt.Println("Converted integer:", i)
```

エラーメッセージは慣習的に、①大文字で始めない ②最後に句点や改行を入れない ようになっており、これは **「エラーメッセージが他の出力で利用されることがあるため」**

## エラーの生成方法
1. errors.new
    ```go
	func divide(a, b float64) (float64, error) {
		if b == 0 {
			return 0, errors.New("division by zero")
		}
		return a / b, nil
	}
	```
2. fmt.Errorf
  - こっちでは、Print系で使える`%w`などが使えて便利
    ```go
	func divide(a, b float64) (float64, error) {
		if b == 0 {
			return 0, fmt.Errorf("division by zero (a=%v)", a)
		}
		return a / b, nil
	}
	```

## センチネルエラー
センチネルエラーとは、特定のエラーを表す変数として定義された、パッケージレベルで公開されているエラー値のことです。

例えば、`io.EOF`や`sql.ErrNoRows`など(`io.EOF`は例外だが、通常は`Err`で始まる)
これらは`var`で定義された変数で、パッケージ外部からも参照可能。

センチネルエラーは、処理を開始 or 終了できないことを示すために通常は利用される。


# エラーをカスタマイズ
Goのerrorは、`Error() string`のメソッドを持つインターフェースであれば良いのでカスタマイズが簡単

ただし、独自のエラー型を定義しても、エラーの結果用に返す方は常にerrorを使う方が良い。

👉 異なるタイプのエラーを戻すことができ、関数の呼び出し側が特定のエラーに依存しないことを選択できるため

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

# `Is`と`As`
`errors.Is`と`errors.As`を使ってエラー補足時に特定のエラーのみをハンドリングできる

| 関数 | 用途 |
|------|------|
| `errors.Is` | エラーが特定のエラーの **`値`** と等しいかを判定する。エラーチェーンを遡って比較する。 |
| `errors.As` | エラーを特定の **`型`** に変換できるかを判定する。エラーチェーンを遡って型アサーションを試みる。 |

ポイントは、`errors.Is`はエラーの **`値`** と比較しているのに対し、`errors.As`は **`型`** を比較している点

👉 (基本的には`errors.Is`で十分だと思うが) `errors.Is`だと、同じカスタムエラー型だけど、メッセージ等がの値が違う場合は`false`判定になる

# panic と recover
Goのランタイムが次に何をすればよいのかの判断ができないとき、panicが生成される(スライスの範囲を超えた読み込みや、メモリ不足など)

## panicの挙動
1. panicが発生
2. 実行中の処理を即座に終了
3. (その関数にdeferがあれば) deferを実行
4. (関数を呼び出した関数にdeferがあれば) deferを実行
5. `4`の処理を`main`関数まで続ける
6. メッセージとスタックトレースを表示して終了

## recover
`recover`を使えば、panicを捕捉して静かに終了したり、終了させないようにすることができる

panicが起こっていればそのpanicに際して代入された値が返されます。(以下のコードだとrecoverが呼び出されれば実行は通常通り続けられます)

```go
func hoge(i int) {
	defer func() {
		if v := recover(); v != nil {
			// panic 発生!!!!
			fmt.Println(v)
		}
	}()

	fmt.Println(60/i)
}

func main() {
	hoge(0)
}
```

**panicやrecoverは例外処理っぽいけど、そうではない！！**

よくある使用例は、panicをrecoverして、現状をログに書き出し、`os.Exit(1)`で終了する例

どうせ処理を続けたところで同じエラーでpanicになるので、潔く処理止めた方が良い(変に続けて不整合なデータができるのが一番最悪)

UNIX哲学でも、予想しないエラーが起きたらシステム止めた方が良いぜって言ってた

