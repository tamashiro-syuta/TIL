# A Tour Of Go の Basic のメモ
リンク : https://go-tour-jp.appspot.com/basics

## for 文
> 基本的に、 for ループはセミコロン ; で3つの部分に分かれています:
>
> 初期化ステートメント: 最初のイテレーション(繰り返し)の前に初期化が実行されます
> 条件式: イテレーション毎に評価されます
> 後処理ステートメント: イテレーション毎の最後に実行されます
> 初期化ステートメントは、短い変数宣言によく利用します。その変数は for ステートメントのスコープ内でのみ有効です。


- これが基本の形
- 初期化、後処理ステートメント、セミコロン(;)は省略できる
```go
package main

import "fmt"

func main() {
	sum := 0
	for i := 0; i < 10; i++ {
		fmt.Println(sum, i)
		sum += i
	}
	fmt.Println(sum)
}
```

- 初期化、後処理ステートメント、セミコロン(;)を省略したver (いわゆるwhile文っぽく書ける！)
```go
package main

import "fmt"

func main() {
	sum := 1
	for sum < 1000; {
		sum += sum
	}
	fmt.Println(sum)
}
```

## if 文
- 基本の形
```go
package main

import (
	"fmt"
	"math"
)

func sqrt(x float64) string {
	if x < 0 {
		return sqrt(-x) + "i"
	}
	return fmt.Sprint(math.Sqrt(x))
}

func main() {
	fmt.Println(sqrt(2), sqrt(-4))
}
```

- 条件文の中で変数を宣言できるショートステートメントが使える
```go
package main

import (
	"fmt"
	"math"
)

func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	}
	return lim
}

func main() {
	fmt.Println(
		pow(3, 2, 10),
		pow(3, 3, 20),
	)
}
```

## switch 文
-  goのswitchの特徴
	- 各caseの最後にbreakステートメントがGoでは自動的に提供される
	- case は定数である必要はなく、 関係する値は整数である必要はない

```go
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Print("Go runs on ")
	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Printf("%s.\n", os)
	}
}
```

- switch文のcaseは、上から下へ評価される
- caseの条件が一致すれば、それ以降のcaseは評価されない
- そのため、条件が一致するcaseがなければ、defaultが評価される
  - 以下のコードだと、`i === 0` の場合、`case 0:` が評価され、`case f():` は評価されない
	```go
	switch i {
		case 0:
		case f():
	}
	```

## Defer
- defer ステートメントは、 defer へ渡した関数の実行を、呼び出し元の関数の終わり(returnする)まで遅延させるもの
- defer へ渡した関数の引数は、すぐに評価されますが、その関数自体は呼び出し元の関数がreturnするまで実行されません

```go
package main

import "fmt"

func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}
```

- 以下のように `return fmt.Println("hoge")` とすると、返り値が多いとエラーになる
  ```shell
	./prog.go:11:9: too many return values
	have (int, error)
	want ()
	```

```go
package main

import "fmt"

func main() {
	defer fmt.Println("world")

	fmt.Println("hello")


	return fmt.Println("asdf")
}
```

- `defer`へ渡した関数が複数ある場合は、その呼び出しはスタックされます。
- 呼び出し元の関数がreturnする時、`defer`へ渡した関数は`LIFO(last-in-first-out)`の順番で実行されます
  - LIFO : 後入れ先出し

```go
package main

import "fmt"

func main() {
	fmt.Println("counting")

	for i := 0; i < 10; i++ {
		defer fmt.Println(i)
	}

	fmt.Println("done")
}

// NOTE: 出力結果
// counting
// done
// 9
// 8
// 7
// 6
// 5
// 4
// 3
// 2
// 1
// 0
```
