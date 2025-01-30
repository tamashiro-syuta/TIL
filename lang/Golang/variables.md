---
title: "変数と定数"
tags: ["Go"]
---
# 変数 の基本
- `var`で変数を宣言する
- ゼロ値っていう初期値的なやつがあるっぽい
  - 初期値のイメージ、「あれ？値指定しないなら、これにしちゃうよ？」ってやつ
	- 組み込み型のゼロ値
		| 型                           | ゼロ値 |
		|------------------------------|--------|
		| int, int8, int16, int32, int64 | 0      |
		| uint, uint8, uint16, uint32, uint64 | 0      |
		| byte, rune, uintptr          | 0      |
		| float32, float64             | 0      |
		| complex64, complex128        | 0      |
		| bool                         | false  |
		| string                      | ""     |
		| error                       | nil    |
	- ※ byte は uint8 のエイリアス
	- ※ rune は int32 のエイリアス(Unicode のコードポイントを表す)
	- 詳しくは → https://qiita.com/tenntenn/items/c55095585af64ca28ab5
- 宣言方法は複数あるが、大切なのは **「開発者の意図が伝わるような宣言方法を選ぶ」** こと
  - ex) ゼロ値を表現したい → `var x int`
  - ex) intではなく、byte型として扱いたい → `var x byte = 2`
- 複数の変数をワンライナーで宣言できるが、これは複数の値を返す関数からの戻り値を代入する時だけ使った方が良い
  - こうすることで、関数からの戻り値が複数であることを明示的に表現できる(体と思う)
  - `var result, err = someFunction()` ← `someFunction()`が複数の値を返す関数であると表現している
- `:=`を用いて宣言できるのは、関数の中だけでパッケージのトップレベルでは使えないので注意
  - トップレベルでは`var`や`const`を使う
- int, uint, uintptr 型は、32-bitのシステムでは32 bitで、64-bitのシステムでは64 bitです。 サイズ、符号なし( unsigned )整数の型を使うための特別な理由がない限り、整数の変数が必要な場合は int を使うようにしましょう。

```go
package main

import "fmt"

func main() {
  // NOTE: ① varで宣言する + ゼロ値が入る
  var i int

  // NOTE: ② var で宣言した変数に値を代入する
	var j int = 1

  // NOTE: ③ := で変数宣言と代入を同時に行う(型類推してくれる)
	k := 2

  // NOTE: ④ まとめて宣言することもできる
	c, python, java := true, false, "no!"

  // NOTE: ⑤ まとめて宣言することもできる パート2
  var (
    ToBe   bool       = false
    MaxInt uint64     = 1<<64 - 1
    z      complex128 = cmplx.Sqrt(-5 + 12i)
  )

  fmt.Println(i, j, k, c, python, java) // 0 1 2 true false no!

  fmt.Printf("Type: %T Value: %v\n", ToBe, ToBe) // Type: bool Value: false
  fmt.Printf("Type: %T Value: %v\n", MaxInt, MaxInt) // Type: uint64 Value: 18446744073709551615
  fmt.Printf("Type: %T Value: %v\n", z, z) // Type: complex128 Value: (2+3i)
}
```

## 型変換
他の言語と同じように、`型(変数)` でキャストできる
```go
package main

import (
	"fmt"
	"math"
)

func main() {
	var x, y int = 3, 4
	var f float64 = math.Sqrt(float64(x*x + y*y))
	var z uint = uint(f)
	fmt.Println(x, y, z) // 3,4,5
}
```

***

# 定数
- `const` で定数を宣言できる
- **Goにおける定数 = リテラルに名前を付与するもの**
  - **変数がイミュータブルであることを宣言する方法はない**
  - Rubyでいう`freeze`みたいなものはない
- 定数には「型なし」と「型付き」の2種類がある
  - 型なし : `const x = 10`
    - `untyped`とも呼ばれる
    - この時、`x`は型なしなので、以下のように異なる型に代入できる
      ```go
      const x = 10
      var y int = x
      var z float64 = x
      ```
    - 型なしのメリットは「柔軟さ」
  - 型付き : `const x int = 10`
    - この時、`x`は`int`型なので、以下のように異なる型に代入できない
      ```go
      const x int = 10
      var y int = x
      var z float64 = x // コンパイルエラー
      ```
    - 型付きのメリットは「安全性」
- 定数は未使用でもコンパイルエラーにならない
  - コンパイル時に未使用の定数は、削除されバイナリファイルには含まれなくなる
- 定数は文字(character)、文字列(string)、boolean、数値(numeric)のみで使える
- 定数は := を使って宣言できない

## Goでの`const`の使い分け
- Goでは、以下のような場合に`const`を使用することが一般的
  - パッケージレベルで再利用される値
  - 複数の場所で使用される重要な定数（例：ステータスコード、設定値など）
  - 数値の型を明示的に制御したい場合
  - iotaを使用する列挙型の定義
- 一方で、以下のような場合は変数を使用することが推奨される
  - 関数スコープ内でのみ使用される文字列
  - エラーメッセージのようなフォーマット文字列
  - 1回しか使用しない値

```go
// Not Good
const errNoTargetCustomers = "no target customers found, targetCustomerIDs: %v, targetYearHalf: %s"

// GooD
msg := "no target customers found, targetCustomerIDs: %v, targetYearHalf: %s"
```

```go
package main

import "fmt"

const Pi = 3.14

func main() {
	const World = "世界"
	fmt.Println("Hello", World)
	fmt.Println("Happy", Pi, "Day")

	const Truth = true
	fmt.Println("Go rules?", Truth)
}
```

以下では、Int型の範囲を超えているので、`fmt.Println(needInt(Big))` でエラーになる
> 数値の定数は、高精度な 値 ( values )です。 \
> 型のない定数は、その状況によって必要な型を取ることになります。
>
> 例で needInt(Big) も出力してみてください。 \
> ( int は最大64-bitの整数を保持できますが、環境によっては精度が低いこともあります)

int型のサイズは、プログラムが実行されるターゲットシステムのアーキテクチャ（32ビットか64ビットか）に依存するので、EC2やLambdaの設定によって実行結果が変わるので、注意が必要！！！！

```go
package main

import "fmt"

const (
	// NOTE: 1ビットを左に100シフトして巨大な数を作る。つまり、1の後に0が100個続く2進数である。
	Big = 1 << 100
  // NOTE: それをまた99箇所右にずらすと、1<<1、つまり2になる。
	Small = Big >> 99
)

func needInt(x int) int { return x*10 + 1 }
func needFloat(x float64) float64 {
	return x * 0.1
}

func main() {
	fmt.Println(needInt(Small)) // 21
	fmt.Println(needFloat(Small)) // 0.2
	fmt.Println(needFloat(Big)) // 1.2676506002282295e+29
	fmt.Println(needInt(Big)) // cannot use Big (untyped int constant 1267650600228229401496703205376) as int value in argument to needInt (overflows)
}
```
