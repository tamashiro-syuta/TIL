---
title: "string"
tags: ["Go"]
---
# string の基本
- 文字列を表現するのにバイト列が使われている
- 1バイトより大きい文字を含む場合は、スライスやインデックスは使わない方が良い
  - 1バイトより大きい文字は複数のバイトで表現されるため、スライスやインデックスでアクセスすると、文字が壊れてしまう可能性がある
  - ex) `fmt.Println(s2)`で文字化けが起きる
    ```go
    var s string = "Hello ☀"
		var s2 string = s[4:7]
		var s3 string = s[:5]
		var s4 string = s[6:]
		fmt.Println(s)  // Hello ☀
		fmt.Println(s2) // o ?（文字化け）
		fmt.Println(s3) // Hello
		fmt.Println(s4) // ☀
		fmt.Println("len(s):", len(s))
    ```
- 初学者がやりがちなミス
  - Int型を文字列に変換する際、stringでキャストしてしまう
    - `strconv`というライブラリの`Itoa`関数を使うと、正しく変換できる
    - `strconv.Itoa(42)` ← これで`"42"`という文字列に変換できる
    - `go vet`コマンドを実行すると、整数型から文字列型への変換は警告の対象になっている
    - 文字列の型変換はバイトのスライスとの間で行われることが多く、runeのスライスとの間で行われることは一般的ではない
