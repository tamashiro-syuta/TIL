---
title: "switch文"
tags: ["Go"]
---
# switch の基本
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

## 比較対象を指定しない"ブランクswitch"
- 要は、`switch`と`{`の間に何も書かなくても動くよってこと
- ※ ただし、case節には必ず条件式が必要(比較対象がないんだから当たり前っちゃ当たり前だけど)
  ```go
  words := []string{"hi", "salutations", "hello"} //liststart
  for _, word := range words {
    var wordLen = len(word)
    switch { // 比較対象の変数の指定なし
    case wordLen == 5:
      fmt.Println(word, "は短い単語です")
    case wordLen == 10:
      fmt.Println(word, "は長すぎる単語です")
    default:
      fmt.Println(word, "はちょうどよい長さの単語です")
    }
  }
  ```

## `fallthrough`を使って、次のcase節に処理を移す
- case節の最後の行にこの設定がある場合、次のcase節に処理が移る
- **※`fallthrough`は使わない方が良い！！！**
  - これを使うってことは、ケース分けがうまくいっていないケースが多いため、注意して使った方が良い
  ```go
  switch {
  case 1 > 0:
    fmt.Println("1 > 0")
    fallthrough
  case 1 < 0:
    fmt.Println("1 < 0")
  }
  ```
## `break`で処理から抜け出す際の注意点
- そもそも、`fallthrough`と同様の理由で、**`break`を使う場合も気をつけた方が良い**
- `break`は、`switch`文の中で使うと、`switch`文から抜け出す
- `for`文の繰り返し処理ごと抜け出したい場合はラベルを使うと良い
  - `break`だけだと、`switch`文から抜け出してしまうのみで、繰り返し処理は続くので注意
  ```go
  func main() {
  loop:  // NOTE: loopというラベルを設定
    for i := 0; i < 10; i++ {
      switch {
      case i%2 == 0:
        fmt.Println(i, "：偶数")
      case i%3 == 0:
        fmt.Println(i, "：3で割り切れるが2では割り切れない")
      case i%7 == 0:
        fmt.Println(i, "：ループ終了！")
        break loop // NOTE: loopラベルを指定して抜け出す
      default:
        fmt.Println(i, "：退屈な数")
      }
    }
  }
  ```
