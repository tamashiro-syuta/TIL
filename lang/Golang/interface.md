---
title: "インターフェース"
tags: ["Go"]
---
# インターフェースの基本
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

- インターフェースも型の一種
- 慣習的に「er」で終わる
  - ex: `Reader`, `Stringer`, `Closer`
- 他の言語との大きな違いは、**「暗黙的に」** インターフェースを実装すること

***

# インターフェースにおける nil のハンドリング
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
	// NOTE: iは*T型で、値がnilなので、*Tのメソッド M がnilレシーバーで呼び出されます。
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

# interface が 値や型を持たない場合に起きる処理
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

# インターフェースが空の場合
ゼロ個のメソッドを指定されたインターフェース型は、 空のインターフェース と呼ばれます

```go
interface{}
```

空のインターフェースは、任意の型の値を保持できます。 (全ての型は、少なくともゼロ個のメソッドを実装しています。)

空のインターフェースは、未知の型の値を扱うコードで使用されます。 例えば、 fmt.Print は interface{} 型の任意の数の引数を受け取ります。

~~TypeScriptでいう `unknown` 型みたいなイメージ~~

Go 1.18からはanyが使えるようになったよ（それまでは空のインターフェース `interface{}` を使ってた）

空インターフェースの近いどころは、以下
1. JSONファイルのような外部ソースから読み込まれた、形式が不明なデータを保存する場合
2. ユーザーが生成したデータ構造の中に値を保存する場合

ただし、なるべく空インターフェースやanyは使わないようにしよう！

使う場合は型アサーションや型スイッチを使って型を明確にしてあげよう！

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

# 型宣言とインターフェースの違い
- Goである型をベースに新しい型を宣言してもそれは継承した親子関係ではなく、両方の方が同じ型をベースにしている(同じ型を基底型にしている)というだけのこと
  - 型の間に階層関係はない！
```go
var i int = 300
var s Score = 100
var hs HighScore = 200
// hs = s // コンパイルエラー(型が違うんだぜ！)
// s = i // コンパイルエラー(型が違うんだぜ！)

s = Score(i) // 型変換すればOK
hs = HighScore(s) // 型変換すればOK

hhs := hs + 20 // 基底型(int)に対して使える演算子は使える
s := Score(hs).Double() // これはOK、基底型がintなので使える
```

# 埋め込み型による合成
- 埋め込みフィールドで宣言されているフィールドやメソッドは、埋め込み先の構造体から直接呼び出せる
	```go
	type Employee struct {
		Name string
		ID string
	}

	type Manager struct {
		Employee // 埋め込み型
		Reports []Employee
	}

	m := Manager{
		Employee: Employee{Name: "John", ID: "123"},
		Reports: []Employee{Employee{Name: "Jane", ID: "456"}},
	}

	fmt.Println(m.Name) // NOTE: 埋め込み先の構造体から直接呼び出せる
	```
- 埋め込み先がダブっている時は、埋め込み先の構造体のフィールド名を明示的にを指定して呼び出す
	```go
	type Inner struct {
		Name string
	}

	type Outer struct {
		Inner
		Name string
	}

	o := Outer{
		Inner: Inner{Name: "John"},
		Name: "Doe",
	}
	fmt.Println(o.Name) // NOTE: OuterのNameが出力される
	fmt.Println(o.Inner.Name) // NOTE: InnerのNameが出力される
	```
	- << PJであった埋め込みの問題 >>
	  - 親のstructと同名のメソッドを持っていたが、子のstructでメソッド名をtypoしており、意図していないメソッドを呼び出されていた & そのことに気づけなかった
	  - **共通化の目的がない場合は埋め込みはしない方が良さそう**
- 埋め込まれたフィールドのメソッドは上位の構造体のメソッドセットに含まれるので、**上位の構造体は下位の構造体を使ってインターフェースを実装できる**

# 「インターフェースを受け取り構造体を返す」
- 関数ないで起動されるビジネスロジックはインターフェースによって起動されるべきであるのに対し、関数の出力は具体的な型であるべき
- 逆に、インターフェースを返すのを「デカップリング」という
  - 基本的にはアンチパターンだが、唯一`error`型は例外
  - (あんまり理解できていないが) インターフェースを返すと、依存の方向を制御しにくいらしい
  - (あんまり理解できていないが) インターフェースを引数に取ることで、依存を制御できるらしい
  - メリットは「インターフェースではなく構造体を引数に取ることで、ヒープへの割り当てが少なくなることでパフォーマンスが良くなる」
    - **🚨 だがそのメリットを選ぶのは「プログラムが遅すぎることに気づき、かつプロファイルで確認し、かつその原因がインターフェースを引数に取っていることだと分かった場合のみ」**