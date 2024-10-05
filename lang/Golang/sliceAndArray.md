---
title: "スライスと配列"
tags: ["Go"]
---
# スライス の基本
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

// NOTE: 出力結果
// a len=5 cap=5 [0 0 0 0 0]
// b len=0 cap=5 []
// c len=2 cap=5 [0 0]
// d len=3 cap=3 [0 0 0]
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

***

# 配列 の基本
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
***

## スライスの比較
- スライスは比較できない
  - 比較しようとするとコンパイルでエラーになるよ
  - スライスを唯一比較できるのは、`nil`のみ
  - `nil`には型がない = どんな型にも代入できるし比較もできる
- スライスが大きくなると、新しい参照先の配列を作成するが、この時のコピーに時間がかかるようになる
  - そのため、スライスのサイズを増やす際は、事前にある程度の余裕を持ってメモリを確保するようになっている
    - Go1.17時点では、キャパシティが1024未満なら2倍、それ以降は1.25倍のキャパシティで確保される

## `make`関数でスライスを作成
- `make`関数を使ったスライスの作成方法
  - ex) スライスの中身を指定しつつ、キャパシティも指定する方法
    ```go
    s := make([]int, 0, 5)
    s = append(s, 1, 2, 3)
    ```
  - こうすることで、キャパシティは5で、中身は`[1, 2, 3]`のスライスが作成される
- `make`を使ってスライスを作る場面は「スライスのサイズが予測できない時」(予測できれば初期化時に指定指定すれば良いため)
  - スライスを作成する際は **「スライスを大きくする回数を少なくするには？」** を意識することが大事
  - 考えられるシチュエーション
    - バッファとして使うスライス
      - `make`に長さ(正の数)指定する
    - 別のスライスにデータを移す場合
      - 必要なサイズがわかっているので、`make`にそのサイズを指定する
      - ただし、サイズを間違えるとゼロ値が入ったり、パニックを起こしてしまうので注意
    - その他
      - 予測できない場合は、`make`に0を指定しておくのが良い
    - (個人的には、バグを起こさない方が重要だと思うから、困ったら0でいいんじゃないかな〜と思っている)
- **「フルスライス」** を使って、意図しないメモリの書き換えを防げる！！！
  - (前提) スライスは配列を参照しているだけなので、一つのスライスから別のスライスを作成する(サブスライスっていうらしい)と、元のスライスの値も変わってしまう
    - グローバル変数みたいだね〜
  - **フルスライスを使うと、作成するスライスのキャパシティを指定できて、誤って別のメモリを書き換えちゃった！がなくなる**
    ```go
    s := []int{1, 2, 3, 4, 5}
    full := s[:2:3] // [1, 2]のスライスを作成、キャパシティは3
    ```
- メモリを共有しないスライスを作成する方法
  - `copy`関数を使う
    ```go
    s := []int{1, 2, 3, 4, 5}
    c := make([]int, len(s))
    lastNum := copy(c, s) // copy(コピー先, コピー元) ← この例では、sの中身をcにコピーしている（返り値はコピーされた要素数）
    fmt.Println(c, lastNum) // [1, 2, 3, 4, 5] 5
    ```
  - この方法で作成したスライスは、元のスライスとはメモリを共有していないので、元のスライスの値が変わっても影響を受けない
