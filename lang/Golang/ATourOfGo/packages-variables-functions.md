# A Tour Of Go の Basic のメモ
リンク : https://go-tour-jp.appspot.com/basics


## パッケージのimport
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

## 関数
関数は降格らしい。
あんまりTSと変わらない印象

```go
package main

import "fmt"

func add(x int, y int) int {
	return x + y
}

func main() {
	fmt.Println(add(42, 13))
}
```

引数が全部同じ型の場合は一括で宣言できるっぽい

```go
func add(x, y int) int {
  return x + y
}
```
### 複数の値を返すことができるらしい！！！
JSとかの配列を返して、分割代入で受け取るのとは異なり、ちゃんと「関数が複数の返り値を持つ」ようになっている！！！

```go
package main

import "fmt"

func swap(x, y string) (string, string) {
	return y, x
}

func main() {
	a, b := swap("hello", "world")
	fmt.Println(a, b) // world hello
}
```

なので、以下のようにするとエラーになる

`./prog.go:13:7: assignment mismatch: 1 variable but swap returns 2 values`

↑ swap関数は、2個の返り値を返すって言っているじゃん、1個だけで受け取ろうとしないでよ

```go
package main

import "fmt"

func swap(x, y string) (string, string) {
	return y, x
}

func main() {
	c := swap("hello", "world")
	fmt.Println(c) // ./prog.go:13:7: assignment mismatch: 1 variable but swap returns 2 values
}
```

### 戻り値に名前をつけることができる
```go
package main

import "fmt"

// NOTE: split関数が返すのは、xとyの2つのint型の値だよ！！
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}

func main() {
	fmt.Println(split(17)) // 7, 10

  // NOTE: 受け取る際は別の変数名をつけても良いらしい
	a, b := split(17)
	fmt.Println(a, b) // 7, 10
}
```

こうやっても同様の結果になる。
名前付き戻り値が定義されている場合でも、return節で明示的に値を返すことができて、その場合はreturnステートメントの値が優先されるっぽい

```go
func split(sum int) (a, b int) {
	x := sum * 4 / 9
	y := sum - x
	return x, y
}

func main() {
	a, b := split(17)
	fmt.Println(a, b)

	fmt.Println(split(17))
}
```

## 変数
`var`で変数を宣言する
ゼロ値っていう初期値的なやつがあるっぽい
  - 詳しくは → https://qiita.com/tenntenn/items/c55095585af64ca28ab5

組み込み型のゼロ値
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

※ byte は uint8 のエイリアス、

※ rune は int32 のエイリアス(Unicode のコードポイントを表す)

(訳注：runeとは古代文字を表す言葉(runes)ですが、Goでは文字そのものを表すためにruneという言葉を使います。)

int, uint, uintptr 型は、32-bitのシステムでは32 bitで、64-bitのシステムでは64 bitです。 サイズ、符号なし( unsigned )整数の型を使うための特別な理由がない限り、整数の変数が必要な場合は int を使うようにしましょう。

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

### 型変換
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

### 定数
`const` で定数を宣言できる

定数は文字(character)、文字列(string)、boolean、数値(numeric)のみで使える

定数は := を使って宣言できない

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
