---
title: "A Tour Of Go の  Methods and Interfaces"
tags: ["Go"]
---
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

***

## Type assertions
型アサーション は、インターフェースの値の基になる具体的な値を利用する手段を提供します。

この文は、インターフェースの値 i が具体的な型 T を保持し、基になる T の値を変数 t に代入することを主張します。

i が T を保持していない場合、この文は panic(例外) を引き起こします。

インターフェースの値が特定の型を保持しているかどうかを テスト するために、型アサーションは2つの値(基になる値とアサーションが成功したかどうかを報告するブール値)を返すことができます。

i が T を保持していれば、 t は基になる値になり、 ok は真(true)になります。

そうでなければ、 ok は偽(false)になり、 t は型 T のゼロ値になり panic は起きません。

```go
package main

import "fmt"

func main() {
	var i interface{} = "hello"

	s := i.(string)
	fmt.Println(s)

	s, ok := i.(string)
	fmt.Println(s, ok)

	f, ok := i.(float64)
	fmt.Println(f, ok)

	f = i.(float64) // panic
	fmt.Println(f)
}


package main

import "fmt"

func main() {
	var i interface{} = "hello"

	s := i.(string)
	fmt.Println(s)

	s, ok := i.(string)
	fmt.Println(s, ok)

	f, ok := i.(float64) // NOTE: アサーションに失敗するが、okで結果(false)を受け取っているので、panic(例外)は起きない
	fmt.Println(f, ok)

	f = i.(float64) // NOTE: アサーションに失敗したので、panic(例外)が起きる
	fmt.Println(f)
}
​
// NOTE: 出力結果
// hello
// hello true
// 0 false
// panic: interface conversion: interface {} is string, not float64 (エラー)
```

***

## Type switches
型switch はいくつかの型アサーションを直列に使用できる構造です。

型switchは通常のswitch文と似ていますが、型switchのcaseは型(値ではない)を指定し、それらの値は指定されたインターフェースの値が保持する値の型と比較されます。

```go
package main

import "fmt"

func do(i interface{}) {
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
	case string:
		fmt.Printf("%q is %v bytes long\n", v, len(v))
	default:
		fmt.Printf("I don't know about type %T!\n", v)
	}
}

func main() {
	do(21)
	do("hello")
	do(true)
}

// NOTE: 出力結果
// Twice 21 is 42
// "hello" is 5 bytes long
// I don't know about type bool!
```

***

## Stringers
もっともよく使われているinterfaceの一つに fmt パッケージ に定義されている Stringer があります

```go
type Stringer interface {
    String() string
}
```

Stringer インタフェースは、stringとして表現することができる型です。 fmt パッケージ(と、多くのパッケージ)では、変数を文字列で出力するためにこのインタフェースがあることを確認します。

```go
package main

import "fmt"

type Person struct {
	Name string
	Age  int
}

// NOTE: Person型はStringerインターフェイスを実装している = fmt.Println()を実行できる。
func (p Person) String() string {
	return fmt.Sprintf("%v (%v years)", p.Name, p.Age)
}

func main() {
	a := Person{"Arthur Dent", 42}
	z := Person{"Zaphod Beeblebrox", 9001}

	// NOTE: fmt.Println関数は、インターフェースfmtに実装されているが、
	// NOTE: その中身では、対象のオブジェクトがインターフェースStringerを実装しているかを検証している
	fmt.Println(a, z)
}

// NOTE: 出力結果
// Arthur Dent (42 years) Zaphod Beeblebrox (9001 years)
```

***

## Errors
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

***

## Readers
io パッケージは、データストリームを読むことを表現する io.Reader インタフェースを規定しています。

Goの標準ライブラリには、ファイル、ネットワーク接続、圧縮、暗号化などで、このインタフェースの 多くの実装 があります。

io.Reader インタフェースは Read メソッドを持ちます

```go
func (T) Read(b []byte) (n int, err error)
```

Read は、データを与えられたバイトスライスへ入れ、入れたバイトのサイズとエラーの値を返します。 ストリームの終端は、 io.EOF のエラーで返します。

例のコードは、 strings.Reader を作成し、 8 byte毎に読み出しています。

```go
package main

import (
	"fmt"
	"io"
	"strings"
)

func main() {
	r := strings.NewReader("Hello, Reader!")

	b := make([]byte, 8)
	for {
		n, err := r.Read(b)
		fmt.Printf("n = %v err = %v b = %v\n", n, err, b)
		fmt.Printf("b[:n] = %q\n", b[:n])
		if err == io.EOF {
			break
		}
	}
}

// NOTE: 出力結果
// n = 8 err = <nil> b = [72 101 108 108 111 44 32 82]
// b[:n] = "Hello, R"
// n = 6 err = <nil> b = [101 97 100 101 114 33 32 82]
// b[:n] = "eader!"
// n = 0 err = EOF b = [101 97 100 101 114 33 32 82]
// b[:n] = ""
```

***

## Images
image パッケージは、以下の Image インタフェースを定義しています：

```go
package image

type Image interface {
    ColorModel() color.Model
    Bounds() Rectangle
    At(x, y int) color.Color
}
```

Note: Bounds メソッドの戻り値である Rectangle は、 image パッケージの image.Rectangle に定義があります。
(詳細は、 [このドキュメント](https://golang.org/pkg/image/#Image) を参照してください。)

color.Color と color.Model は共にインタフェースですが、定義済みの color.RGBA と color.RGBAModel を使うことで、このインタフェースを無視できます。 これらのインタフェースは、image/color パッケージで定義されています。

```go
package main

import (
	"fmt"
	"image"
)

func main() {
	m := image.NewRGBA(image.Rect(0, 0, 100, 100))
	fmt.Println(m.Bounds())
	fmt.Println(m.At(0, 0).RGBA())
}

// NOTE: 出力結果
// (0,0)-(100,100)
// 0 0 0 0
```
