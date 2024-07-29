# A Tour Of Go の Methods and Interfaces のメモ
リンク : https://go-tour-jp.appspot.com/methods

## Methods
**Goにはクラスの概念がない！！**

**Goにおけるメソッドは、型に紐づくもの！！**

メソッドは、特別なレシーバ( receiver )引数を関数に取ります。


レシーバは、 func キーワードとメソッド名の間に自身の引数リストで表現します。

この例では、 Abs メソッドは v という名前の Vertex 型のレシーバを持つことを意味しています。

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

// NOTE: Vertex型には、Absメソッドが紐づく
// NOTE: v が レシーバ
// NOTE: v Vertex が レシーバ引数
func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}

// NOTE: 出力結果
// 5
```

メソッドはstructの型だけではなく、任意の型(type)にもメソッドを宣言できます！

**レシーバを伴うメソッドの宣言は、レシーバ型が同じパッケージにある必要があります。**

**他のパッケージに定義している型に対して、レシーバを伴うメソッドを宣言できません (組み込みの int などの型も同様です)。**

```go
package main

import (
	"fmt"
	"math"
)

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

func main() {
	f := MyFloat(-math.Sqrt2)
	fmt.Println(f.Abs())
}
​
// NOTE: 出力結果
// 1.4142135623730951
```

***

## Pointer Receivers
ポインタレシーバでメソッドを宣言できます。

これはレシーバの型が、ある型 T への構文 *T があることを意味します。 （なお、 T は *int のようなポインタ自身を取ることはできません）

例では *Vertex に Scale メソッドが定義されています。

ポインタレシーバを持つメソッド(ここでは Scale )は、レシーバが指す変数を変更できます。 レシーバ自身を更新することが多いため、変数レシーバよりもポインタレシーバの方が一般的です。

Scale の宣言(line 16)から * を消し、プログラムの振る舞いがどう変わるのかを確認してみましょう。

変数レシーバでは、 Scale メソッドの操作は元の Vertex 変数のコピーを操作します。 （これは関数の引数としての振るまいと同じです）。 つまり main 関数で宣言した Vertex 変数を変更するためには、Scale メソッドはポインタレシーバにする必要があるのです。

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

// NOTE: Absメソッドは値レシーバを使用
func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

// NOTE: Scaleメソッドはポインタレシーバを使用
// NOTE: 返り値はなく、レシーバの値(ポインタが指す値)を直接更新している
func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(10) // NOTE: vのXとYを10倍にスケーリング
	fmt.Println(v.Abs()) // NOTE: スケーリング後のvの長さを計算して表示（50.0）
}
```

下のコードで、Scale関数を以下のように `*`を削除すると、Scale関数内での変更が反映されない。

**理由は、Scale関数内での変更が、main関数で宣言したVertex変数のコピーを操作しているため。(ポインタを渡すことで、元の変数を操作することができる)**
```go
func (v Vertex) Scale(f float64) {
	// NOTE: この場合はScaleに渡したvそのものではなく、コピーされたvを操作している = 元のvは変更されない()
	v.X = v.X * f
	v.Y = v.Y * f
}
```


### ポインタレシーバがよく使われる理由
1. パフォーマンス
    - 大きな構造体を値レシーバで渡すとコピーが発生し、パフォーマンスが低下する可能性がある。
		- ポインタレシーバは、ポインタを渡すだけなので効率的。
		  ```go
			type Vertex struct {
				X, Y float64
			}

			func (v Vertex) Move() {
					v.X += 10
					v.Y += 10
			}

			func main() {
					v := Vertex{3, 4}
					v.Move()
					// NOTE: {3, 4} と表示される => 値の参照ではなく、コピーされている = その分メモリを消費している
					fmt.Println(v)
			}
			```
2. 変更を許可する
    - ポインタレシーバを使うと、メソッド内でレシーバのフィールドを変更できる。
		- 例えば、Scaleメソッドのようにオブジェクトの状態を変更する必要がある場合に便利。

### 値レシーバが使われる場合
1. 構造体が小さい
    - 構造体が小さく、コピーのコストが低い場合。
		- 値レシーバは変更しない意図を明示的に示すことができる。
2. 変更しないメソッド
    - レシーバのフィールドを変更しないメソッドでは値レシーバを使うことが多い。

***

## Methods and pointer indirection

下の2つの呼び出しを比べると、ポインタを引数に取る ScaleFunc 関数は、ポインタを渡す必要があることに気がつくでしょう。

```go
var v Vertex
ScaleFunc(v, 5)  // Compile error!
ScaleFunc(&v, 5) // OK
```
メソッドがポインタレシーバである場合、呼び出し時に、変数、または、ポインタのいずれかのレシーバとして取ることができます。

```go
var v Vertex
v.Scale(5)  // OK
p := &v
p.Scale(10) // OK
v.Scale(5)
```

のステートメントでは、 v は変数であり、ポインタではありません。 メソッドでポインタレシーバが自動的に呼びだされます。 Scale メソッドはポインタレシーバを持つ場合、Goは利便性のため、 v.Scale(5) のステートメントを (&v).Scale(5) として解釈します。

| 呼び出しの種類                  | レシーバ/引数    | 呼び出し方                      | 例                              |
|-------------------------------|----------------|----------------------------|-------------------------------|
| 関数の引数としての呼び出し        | ポインタ         | 明示的にポインタを渡す必要がある         | `ScaleFunc(&v, 10)`            |
| 値レシーバのメソッド呼び出し       | 値              | 値で呼び出し可能                | `v.Abs()`                     |
| ポインタレシーバのメソッド呼び出し  | ポインタまたは値 | ポインタまたは値で呼び出し可能（自動変換） | `v.Scale(2)` または `p.Scale(3)` |


```go
package main

import "fmt"

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func ScaleFunc(v *Vertex, f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	// NOTE: ポインタレシーバなので、よしなに解釈してくれる
	v.Scale(2)
	// NOTE: 関数なので、明示的にポインタを渡す必要がある
	ScaleFunc(&v, 10)

	p := &Vertex{4, 3}
	// NOTE: ポインタレシーバなので、よしなに解釈してくれる
	p.Scale(3)
	ScaleFunc(p, 8)

	fmt.Println(v, p)
}
```

引数の場合も同様なんだぜ！

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func AbsFunc(v Vertex) float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
	fmt.Println(AbsFunc(v))

	p := &Vertex{4, 3}
	fmt.Println(p.Abs())
	// NOTE: `*` を削除して、`AbsFunc(p)` のようにするとコンパイルエラー
	fmt.Println(AbsFunc(*p))
}
```

***

## Interfaces
interface(インタフェース)型は、メソッドのシグニチャの集まりで定義します。

そのメソッドの集まりを実装した値を、interface型の変数へ持たせることができます。

**型にメソッドを実装していくことによって、インタフェースを実装(満た)します。 インタフェースを実装することを明示的に宣言する必要はありません( "implements" キーワードは必要ありません)。**

**暗黙のインターフェースは、インターフェースの定義をその実装から切り離します。 インターフェースの実装は、事前の取り決めなしにパッケージに現れることがあります。**

```go
package main

import "fmt"

type I interface {
	M()
}

type T struct {
	S string
	F float64
}

// NOTE: このメソッドは、T型がインターフェイスIを実装していることを意味するが、それを明示的に宣言する必要はない。
// NOTE: T型のメソッドとしてMを定義(実装)している = T型はIインターフェイスIを(暗黙に)実装している
func (t T) M() {
	fmt.Println(t.S)
	fmt.Println(t.F)
}

func main() {
	// NOTE: T型は、インターフェースIを(暗黙に)実装している
	var i I = T{"hello", 1.23}
	fmt.Println(i)
	i.M()
}

// NOTE: 出力結果
// {hello 1.23}
// hello
// 1.23
```

***

## Interface values with nil underlying values
インターフェース自体の中にある具体的な値が nil の場合、メソッドは nil をレシーバーとして呼び出されます。

いくつかの言語ではこれは null ポインター例外を引き起こしますが、 **Go では nil をレシーバーとして呼び出されても適切に処理するメソッドを記述するのが一般的です(この例では M メソッドのように)。**

**具体的な値として nil を保持するインターフェイスの値それ自体は非 nil であることに注意してください。**

```go
package main

import "fmt"

type I interface {
	M()
}

type T struct {
	S string
}

// NOTE: T型のメソッドとしてMを定義(実装)している = T型はIインターフェイスIを(暗黙に)実装している
// NOTE: 値の変更をしてないのにポインタレシーバを使っているのは、nilの場合にも対応するため
// NOTE: 値レシーバを使うと、nilチェックができない → `if t == nil` みたいにすると、「tはT型ちゃうんかい！nilなわけないやろ！」って怒られる」
// NOTE: なので、ポインターレシーバを使って、Tが持つ値がnilかどうかをチェックしている
func (t *T) M() {
	if t == nil {
		fmt.Println("<nil>")
		return
	}
	fmt.Println(t.S)
}

func main() {
	var i I
	var t *T

	// NOTE: この時点で、iは型情報として*Tを持っているが、値としてはnilを持つ
	i = t
	describe(i)
	// NOTE: iは*T型で、値がnilなので、*TのメソッドMがnilレシーバーで呼び出されます。
	// NOTE: この場合、メソッド内でレシーバーがnilであることをチェックし、<nil>と出力します。
	i.M()

	// NOTE: この代入で、型が*T型、値が"hello"になる
	i = &T{"hello"}
	describe(i)
	// NOTE: 値はnilではなく、"hello"なので、"hello"が出力される
	i.M()
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}

// NOTE: 出力結果
// (<nil>, *main.T) ← 🚨 i自体がnilではなく、中身がnilであることに注意
// <nil>
// (&{hello}, *main.T)
// hello
```

***

## Nil interface values
nil インターフェースの値は、値も具体的な型も保持しません。

呼び出す 具体的な メソッドを示す型がインターフェースのタプル内に存在しないため、 nil インターフェースのメソッドを呼び出すと、ランタイムエラーになります。

```go
package main

import "fmt"

type I interface {
	M()
}

func main() {
	var i I
	describe(i)
	i.M()
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}

// NOTE: 出力結果
// 🚨 ランタイムエラーになる
// describeメソッドのみだと、`(<nil>, <nil>)`を出力する
```

***

## The empty interface
ゼロ個のメソッドを指定されたインターフェース型は、 空のインターフェース と呼ばれます

```go
interface{}
```

空のインターフェースは、任意の型の値を保持できます。 (全ての型は、少なくともゼロ個のメソッドを実装しています。)

空のインターフェースは、未知の型の値を扱うコードで使用されます。 例えば、 fmt.Print は interface{} 型の任意の数の引数を受け取ります。

TypeScriptでいう `unknown` 型みたいなイメージ


```go
package main

import "fmt"

func main() {
	var i interface{}
	describe(i)

	i = 42
	describe(i)

	i = "hello"
	describe(i)
}

func describe(i interface{}) {
	fmt.Printf("(%v, %T)\n", i, i)
}

// NOTE: 出力結果
// (<nil>, <nil>)
// (42, int)
// (hello, string)
```
