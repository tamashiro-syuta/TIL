# A Tour Of Go の More types のメモ
リンク : https://go-tour-jp.appspot.com/moretypes

## Pointers
- ポインタは値のメモリアドレスを指す
- 変数 T のポインタは、 `*T` 型で、ゼロ値は `nil`
- `&` 演算子は、そのオペランド(operand)へのポインタを引き出す
  - `&`をつけたら、その変数のアドレスを取得できる
- `*` 演算子は、ポインタの指す先の変数を示す
  - `*`をつけたら、そのポインタが指す先の変数を取得できる
- 使う場面としては、以下らしい by GPT-4o
  - 関数に渡す引数
    > Goでは関数に引数を渡す際、デフォルトでは値渡し（値のコピー）が行われます。大きな構造体やデータを関数に渡すとき、値渡しはメモリと処理のオーバーヘッドを生じさせます。このため、ポインタを使ってデータのアドレスを渡すことで、関数内で直接データを操作できます。
  - 可変データ構造の操作
    > スライスやマップなどの可変データ構造に対して操作を行う場合、ポインタを使うことで直接データを操作できます。
  - 共有データの更新
    > 複数のゴルーチン（goroutine）間でデータを共有する場合、ポインタを使うことで共有データを安全かつ効率的に操作できます。特に、同期メカニズム（例：チャネルやミューテックス）を使用する場合に有効です。

```go
package main

import "fmt"

func main() {
	i, j := 42, 2701

	p := &i         // NOTE 変数iのアドレス(ポイント)を取得
	fmt.Println(p)  // NOTE 変数iのアドレス(ポイント)を表示 ex: 0xc0000160e0
	fmt.Println(*p) // NOTE ポインタを経由して変数iの値(42)を表示
	*p = 21         // NOTE ポインタを経由して変数iに21を代入
	fmt.Println(i)  // NOTE 変数iの値が21になっていることを確認

	p = &j         // NOTE 変数jのアドレス(ポイント)を取得
	*p = *p / 37   // NOTE ポインタを経由して変数jに2701/37を代入(変数jの値を書き換えるのではなく、変数jのポインタを経由して変数jのメモリアドレスを取得し、直接値を書き換えて、結果としてjの値も変わっている、変数とポインタが同じメモリアドレスを参照しており、参照先をポインタ経由で変更したので変数jの値も変更されている)
	fmt.Println(j) // NOTE 変数jの値が73になっていることを確認
}
```

## Structs
- Structs(構造体)は、フィールドの集まり

```go
type Vertex struct {
	X int
	Y int
}

func main() {
  v := Vertex{1, 2}
  v.X = 4
  fmt.Println(v.X) // NOTE 4
}
```

- structのフィールドをポインタ経由で取得する際は、`(*p).X`のように書くか、`p.X`のように書くかどちらでも良い

```go
package main

import "fmt"

type Vertex struct {
	X int
	Y int
}

func main() {
	v := Vertex{1, 2}
	p := &v
	p.X = 123
	fmt.Println(v) // NOTE {123 2}
}
```

- こんな書き方もできるよシリーズ
```go
package main

import "fmt"

type Vertex struct {
	X, Y int
}

var (
	v1 = Vertex{1, 2}  // has type Vertex
	v2 = Vertex{X: 1}  // Y:0 is implicit
	v3 = Vertex{}      // X:0 and Y:0
	p  = &Vertex{1, 2} // has type *Vertex
)

func main() {
	fmt.Println(v1, p, v2, v3)
}
```
