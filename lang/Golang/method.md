---
title: "メソッド"
tags: ["Go"]
---
# メソッド の基本
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
