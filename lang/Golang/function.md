---
title: "関数"
tags: ["Go"]
---
# 関数 の基本
関数はこう書くらしい。
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
## 複数の値を返すことができるらしい！！！
- JSとかの配列を返して、分割代入で受け取るのとは異なり、ちゃんと「関数が複数の返り値を持つ」ようになっている！！！
- だいたい`error`は ①戻り値の最後の値 or ②唯一の戻り値 とするのが一般的
- 複数の戻り値が設定されている関数を一つの変数に代入しようとすると、返り値は複数やろがいって怒られる
  - Goでは、戻り値は全部受け取るか、`_`で無視するかのどちらか

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

## 名前付き戻り値
- 関数の戻り値に名前をつけることができる
- ただし、以下の理由から使用には注意が必要
  - " **宣言した値に代入しなくても返すことができる** "
    - 返り値として指定した`num`は、`Hoge`関数が呼び出しされたタイミングで生成される
    - このときはゼロ値で変数が生成されるので、Hoge関数は`0`を返す
    ```go
    func Hoge() (num int) {
      return
    }

    func main() {
      result := Hoge()
      fmt.Println(result) // NOTE: 0
    }
    ```
  - " **定義時に指定していない値も返せるので可読性が下がる** "
    - 以下の例のように途中で、指定していない値を返していたり、行数が長いコードになると追いづらくなるので、注意が必要
    ```go
    func Hoge() (num int) {
      // ~ 何かしらの処理 ~
      if hoge {
        someValue := 1
        return someValue
      }
      // ~ 何かしらの処理 ~
      num = 1000000
      return num
    }
    ```
  - " **ブランクリターンする際、返り値がどの値かがわかりづらい** "
    - 以下の例で、`return`までの間に、`num`がどのように書き換えられているかがわかりづらい
    - グローバル変数を使うときみたいに「あれ、これ今なにはいってるっけ？」みたいな感覚
    - **関数が値を返す場合は、ブランクリターンは使わない方が良い**
    ```go
    func Hoge() (num int) {
      // ~ 何かしらの処理 ~
      return
    }
    ```
- 名前付き戻り値に対する理解は以下
    - **❌ その変数を戻り値として返すことを「要求」するもの**
    - **⭕️ 戻り値を保存するための変数を使用するという「意図」を宣言するもの**
    - つまり「俺はこいつからすからな〜」ではなく、「俺はこいつを返したいと思ってるよ〜」くらい

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

## Goにない「名前付き引数」と「オプション引数」
- Goには、PythonやJavaScriptにある「名前付き引数」や「オプション引数」がない
- 同じようなことをしたい場合は、構造体ごと引数にする
- そもそも、引数が多かったり複雑だったりする場合は、関数の設計を見直すべき

## 可変長引数
- 引数を可変長にするには、`...`を使う
- ただし、可変長引数は、最後の引数にしか使えない
  ```go
  func addTo(base int, vals ...int) []int {
    out := make([]int, 0, len(vals))
    for _, v := range vals {
      out = append(out, base+v)
    }
    return out
  }

  // addTo(1,3,5,7,9)
  ```

## 無名関数
- Goにもあるの知らなかった
- 以下のように、無名関数を変数に代入して、その変数を関数として使うことができる
- `func`の後に名前を書かずにすぐ引数かけばいけるぽ
  ```go
  func main() {
    for i := 0; i < 5; i++ {
      func(j int) {
        fmt.Println("無名関数の中で", j, "を出力")
      }(i)
    }
  }
  ```
- こんなのどこで使うねん！！って思ったけど、クロージャー、`defer`、ゴルーチンの起動などで使えるらしい
  - クロージャーは、クロージャーにまつわるファイルがあるので、そっちをみてね

***

# 関数を値として扱う
関数も変数です。他の変数のように関数を渡すことができます。

関数値( function value )は、関数の引数に取ることもできますし、戻り値としても利用できます。

```go
package main

import (
	"fmt"
	"math"
)

func compute(fn func(float64, float64) float64) float64 {
	return fn(3, 4)
}

func main() {
	hypot := func(x, y float64) float64 {
		return math.Sqrt(x*x + y*y)
	}
	fmt.Println(hypot(5, 12))

	fmt.Println(compute(hypot))

	// NOTE: math.Powはべき乗を計算する関数 ex) math.Pow(3, 4) = 3の4条 = 81
	fmt.Println(compute(math.Pow))
}

// NOTE: 出力結果
// 13
// 5
// 81
```
## クロージャー
Goの関数は クロージャ( closure ) です。 クロージャは、それ自身の外部から変数を参照する関数値です。 この関数は、参照された変数へアクセスして変えることができ、その意味では、その関数は変数へ"バインド"( bind )されています。

例えば、 adder 関数はクロージャを返しています。 各クロージャは、それ自身の sum 変数へバインドされます。

### ポイント
1. クロージャの作成
	- adder関数は、内部でsumという変数を初期化し、匿名関数を返します。
	- 匿名関数は、引数xを受け取り、sumに加算し、その結果を返します。
2. クロージャのバインディング
	- posとnegはそれぞれadder関数を呼び出し、異なるクロージャを作成します。
	- **各クロージャは独自のsum変数にバインドされるため、独立して動作します。**
	  - 同じ`sum`という変数だけど、クロージャーが異なるから別の値として認識されるんだぜってこと
3. クロージャの使用
	- main関数内のループで、posは0から9までの値を加算し、negは0, -2, -4, ... と減算します。
	- 各クロージャは独自の状態を保持し、バインドされたsum変数を変更します。

### クロージャの活用
- クロージャは、状態を保持する関数を作成する際に便利です。例えば、カウンタや累積値を計算する関数を簡潔に作成できます。

```go
package main

import "fmt"

// NOTE: adder自体がクロージャーではなく
func adder() func(int) int {
	sum := 0

	// NOTE: 返り値のこいつがクロージャー(外部の変数sumを参照しているため)
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}
​
// NOTE: 出力結果
// 0 0
// 1 -2
// 3 -6
// 6 -12
// 10 -20
// 15 -30
// 21 -42
// 28 -56
// 36 -72
// 45 -90
```
