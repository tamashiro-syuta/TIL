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
