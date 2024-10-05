---
title: "fmtパッケージ"
tags: ["Go"]
---
# Stringers
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
