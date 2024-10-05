---
title: "構造体"
tags: ["Go"]
---
# 構造体 の基本
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

- 構造体の定義は、関数の外側でも内側でも可能
  - ただし、内側で定義した場合は、そのパッケージ内でのみアクセス可能
- 構造体リテラルでは、全てのフィールドがゼロ値で初期化される
  ```go
  type Person struct {
    Name string
    Age  int
  }

  p := Person{}
  fmt.Println(p.Name) // ""
  fmt.Println(p.Age)  // 0
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

## 構造体の比較
- 構造体は、中身が完全に同じでも異なる構造体のインスタンスは比較できない
  - 比較したい場合は自作で比較関数を作成する必要がある
  ```go
  type FirstPerson struct {
		name string
		age  int
	}
	type SecondPerson struct {
		name string
		age  int
	}

	p1 := FirstPerson{
		name: "1",
		age:  1,
	}

	p2 := SecondPerson{
		name: "1",
		age:  1,
	}

	fmt.Println(p1 == p2) // エラー
  ```
- "無名構造体"を使って、一時的な構造体を作成することができる
  ```go
  p := struct {
    Name string
    Age  int
  }{
    Name: "Taro",
    Age:  20,
  }
  fmt.Println(p) // {Taro 20}
  ```
  - JavaScriptのアロー関数に似てるけど、以下のように無名構造体に名前をつけることはできない
    ```go
    func main() {
      // NOTE: ここで、そんなことはできんぞって怒られる
      p := struct {
        Name string
        Age  int
      }

      q := p{
        Name: "Taro",
        Age:  20,
      }
      fmt.Println(p)
      fmt.Println(q)
    }
    ```
  - 無名構造体が利用されるケース
    - 外部データの変換(特にJSON周り)
    - テストコード
- 無名構造の場合、中身が同じであれば比較が可能
  ```go
  type FirstPerson struct {
		name string
		age  int
	}
	type SecondPerson struct {
		name string
		age  int
	}
	type ThirdPerson struct {
		name string
		age  int
	}

	p1 := FirstPerson{
		name: "1",
		age:  1,
	}

	var p2 struct {
		name string
		age  int
	}

	p2 = p1
	fmt.Println(p1 == p2) // true
  ```
