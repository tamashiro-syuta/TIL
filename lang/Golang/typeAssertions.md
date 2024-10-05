---
title: "型アサーション"
tags: ["Go"]
---
# 型アサーション の基本
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

# type switches
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
