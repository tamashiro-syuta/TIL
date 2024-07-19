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

// NOTE: 出力結果
// {1 2} &{1 2} {1 0} {0 0}
```
## Arrays
- `[n]T` 型は、型 `T` の n 個の変数の配列を表す
	- `var a [10]int` : 10個のint型変数の配列
	- `primes := [6]int{2, 3, 5, 7, 11, 13}` のように初期化もできる

```go
package main

import "fmt"

func main() {
	var a [2]string
	a[0] = "Hello"
	a[1] = "World"
	fmt.Println(a[0], a[1])
	fmt.Println(a)

	primes := [6]int{2, 3, 5, 7, 11, 13}
	fmt.Println(primes)
}
```

## Slices
- スライスは配列と違い可変長なので、より柔軟
	- 実際には、スライスは配列よりもより一般的
- 型 `[]T` は 型 T のスライスを表します。配列の数指定なしverで宣言できる
- `a[1:4]`とすると、aの配列やスライスのうち、インデックス1から3までの要素を参照する
	- ※ インデックス4は含まれないので注意
- 詳しく学びたい時は https://go.dev/blog/slices-intro

```go
package main

import "fmt"

func main() {
	primes := [6]int{2, 3, 5, 7, 11, 13}

	var s []int = primes[1:4]
	fmt.Println(s)
}

// NOTE: 出力結果
// [3 5 7]
```

- **スライスの実態は配列を部分的に参照したもので、スライス自体がデータを格納はしていない**
- なので、スライスのリテラルは長さのない配列リテラルのようなもの

```go
package main

import "fmt"

func main() {
	names := [4]string{
		"John",
		"Paul",
		"George",
		"Ringo",
	}
	fmt.Println(names)

	a := names[0:2]
	b := names[1:3]
	fmt.Println(a, b)

	// NOTE: 別のスライスのポインタを取得しても同じメモリのアドレスを指す
	fmt.Println("&a[1] == &b[0] : ", &a[1] == &b[0])

	b[0] = "XXX"
	fmt.Println(a, b)
	fmt.Println(names)
}

// NOTE: 出力結果
// [John Paul George Ringo]
// [John Paul] [Paul George]
// &a[1] == &b[0] : true
// [John XXX] [XXX George]
// [John XXX George Ringo]
```

- スライスのデフォルトは下限が 0 で上限はスライスの長さ
	- `var a [10]int` において、以下のスライスは等価
		```go
		a[0:10]
		a[:10]
		a[0:]
		a[:]
		```

- スライスは "長さ(length)" と "容量(capacity)" を持っている
	- 長さ : スライスに含まれる要素の数
	- 容量 : スライスの最初の要素から数えて元となる配列の要素数
	- `len(s)` と `cap(s)` で取得できる

```go
package main

import "fmt"

func main() {
	s := []int{2, 3, 5, 7, 11, 13}
	printSlice(s)

	// Slice the slice to give it zero length.
	s = s[:0]
	printSlice(s)

	// Extend its length.
	s = s[:4]
	printSlice(s)

	// Drop its first two values.
	s = s[2:]
	printSlice(s)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}

// NOTE: 出力結果
// len=6 cap=6 [2 3 5 7 11 13]
// len=0 cap=6 []
// len=4 cap=6 [2 3 5 7]
// len=2 cap=4 [5 7]
```

- スライスのゼロ値は `nil`
  - nil スライスは 0 の長さと容量を持っており、何の元となる配列も持っていない

- `make` 関数でスライスを作成すると、動的サイズの配列を作成ことができる
	- `make(初期化したスライス, length, capacity)`
	- ❌ `make([]int{2, 3, 5, 7, 11, 13}, 5)` はエラー、第1引数は型だよ、スライス(インスタンス)で渡すんじゃねぇよらしい

```go
package main

import "fmt"

func main() {
	a := make([]int, 5)
	printSlice("a", a)

	b := make([]int, 0, 5)
	printSlice("b", b)

	c := b[:2]
	printSlice("c", c)

	d := c[2:5]
	printSlice("d", d)
}

func printSlice(s string, x []int) {
	fmt.Printf("%s len=%d cap=%d %v\n",
		s, len(x), cap(x), x)
}
```

- 組み込みの`append`関数でスライスに値を追加できる
	- `append(スライス, 追加する値)` で追加
	- 関数の定義は `func append(s []T, vs ...T) []T`

```go
package main

import "fmt"

func main() {
	var s []int
	printSlice(s)

	// append works on nil slices.
	s = append(s, 0)
	printSlice(s)

	// The slice grows as needed.
	s = append(s, 1)
	printSlice(s)

	// We can add more than one element at a time.
	s = append(s, 2, 3, 4)
	printSlice(s)

	hoge := make([]int, 5, 5)
	printSlice(hoge)

	// NOTE: 容量(capacity)を超える場合はより大きいサイズの配列を割り当て直す
	huga := append(hoge, 1, 1, 1, 1, 1, 1)
	printSlice(huga)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}

// NOTE: 出力結果
// len=0 cap=0 []
// len=1 cap=1 [0]
// len=2 cap=2 [0 1]
// len=5 cap=6 [0 1 2 3 4]
// len=5 cap=5 [0 0 0 0 0]
// len=11 cap=12 [0 0 0 0 0 1 1 1 1 1 1]
```

## Range
- for ループに利用する range は、スライスや、マップ( map )をひとつずつ反復処理するために使う
- スライスをrangeで繰り返す場合、rangeは反復毎に2つの変数を返す
	- 1つ目 : 変数はインデックス( index )
	- 2つ目 : インデックスの場所の要素のコピー

```go
package main

import "fmt"

var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
	for i, v := range pow {
		fmt.Printf("2**%d = %d\n", i, v)

		// NOTE: rangeで取得できるvalue(変数v)はコピーなので、元の配列には影響を与えない
		v = 1
	}

	fmt.Printf("%v\n", pow)
}


// NOTE: 出力結果
// 2**0 = 1
// 2**1 = 2
// 2**2 = 4
// 2**3 = 8
// 2**4 = 16
// 2**5 = 32
// 2**6 = 64
// 2**7 = 128
// [1 2 4 8 16 32 64 128] ← rangeで取得できるvalue(変数v)はコピーなので、元の配列には影響を与えない
```

## Map
- keyとobjectをマッピングする辞書型みたいなやつ
- マップのゼロ値は nil
	- nil マップはキーは持ってなく、キーを追加することもできない

```go
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m map[string]Vertex

func main() {
	m = make(map[string]Vertex)
	m["Bell Labs"] = Vertex{
		40.68433, -74.39967,
	}
	fmt.Println(m)
	fmt.Println(m["Bell Labs"])
}

// NOTE: 出力結果
// map[Bell Labs:{40.68433 -74.39967}]
// {40.68433 -74.39967}
```

- 渡す型が単純な型名である場合は、リテラルの要素から推定できるので、その型名を省略できる

```go
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}

func main() {
	fmt.Println(m)
}
```

- mapに関する操作
	- 取得 : `elem = m[key]`
		- キーに対応する要素があるかどうかは、2つ目の返り値で確認できる(以下のokで確認できる)
		- `ok`はbooleanで、`true`の場合は要素が存在し、`false`の場合は要素が存在しない(ゼロ値を返す
		- ex) `elem, ok = m[key]`
	- 更新 : `m[key] = elem`
	- 削除 : `delete(m, key)`
