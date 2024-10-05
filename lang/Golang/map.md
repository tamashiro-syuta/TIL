---
title: "map"
tags: ["Go"]
---
# map の基本
- keyとobjectをマッピングする辞書型みたいなやつ
- マップのゼロ値は nil
	- nil マップはキーは持ってなく、キーを追加することもできない

```go
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m map[string]Vertex

func main() {
	m = make(map[string]Vertex)
	m["Bell Labs"] = Vertex{
		40.68433, -74.39967,
	}
	fmt.Println(m)
	fmt.Println(m["Bell Labs"])
}

// NOTE: 出力結果
// map[Bell Labs:{40.68433 -74.39967}]
// {40.68433 -74.39967}
```

- 渡す型が単純な型名である場合は、リテラルの要素から推定できるので、その型名を省略できる

```go
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}

func main() {
	fmt.Println(m)
}
```

## 注意点
- nilマップに対して書き込みを行うとpanicになる(読み込みはOK)
  - nilマップ = `var m map[int]string`のように宣言しただけのマップのこと
  - 通常、このような宣言の仕方はしない
- `:=`を使った"マップリテラル"という宣言方法だと、nilマップにならない
  - `m := map[int]string{}`のように宣言すると、空のマップが作成される
  - マップのサイズも0だが、読み書きの両方が可能(panicにならない！！)
- マップのサイズが予想できる際は、サイズを指定してmake関数で作成
- 値が設定されていないキーにアクセスすると、ゼロ値が返る

## アクセスした値が存在するかどうかを判定する方法
- "カンマokイディオム"を使って判定することができる
  - `v, ok := m[key]`
  - `ok`には、キーが存在するかどうかが格納される
  - `v === ゼロ値` かつ `ok === true` → 存在する(意図的にゼロ値を設定している)
  - `v === ゼロ値` かつ `ok === false` → 存在しない(ただゼロ値が返ってきただけ)

## mapに関する操作
- 取得 : `elem = m[key]`
	- キーに対応する要素があるかどうかは、2つ目の返り値で確認できる(以下のokで確認できる)
	- `ok`はbooleanで、`true`の場合は要素が存在し、`false`の場合は要素が存在しない(ゼロ値を返す
	- ex) `elem, ok = m[key]`
- 更新 : `m[key] = elem`
- 削除 : `delete(m, key)`
