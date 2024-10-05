---
title: "ioパッケージ"
tags: ["Go"]
---
# Readers
io パッケージは、データストリームを読むことを表現する io.Reader インタフェースを規定しています。

Goの標準ライブラリには、ファイル、ネットワーク接続、圧縮、暗号化などで、このインタフェースの 多くの実装 があります。

io.Reader インタフェースは Read メソッドを持ちます

```go
func (T) Read(b []byte) (n int, err error)
```

Read は、データを与えられたバイトスライスへ入れ、入れたバイトのサイズとエラーの値を返します。 ストリームの終端は、 io.EOF のエラーで返します。

例のコードは、 strings.Reader を作成し、 8 byte毎に読み出しています。

```go
package main

import (
	"fmt"
	"io"
	"strings"
)

func main() {
	r := strings.NewReader("Hello, Reader!")

	b := make([]byte, 8)
	for {
		n, err := r.Read(b)
		fmt.Printf("n = %v err = %v b = %v\n", n, err, b)
		fmt.Printf("b[:n] = %q\n", b[:n])
		if err == io.EOF {
			break
		}
	}
}

// NOTE: 出力結果
// n = 8 err = <nil> b = [72 101 108 108 111 44 32 82]
// b[:n] = "Hello, R"
// n = 6 err = <nil> b = [101 97 100 101 114 33 32 82]
// b[:n] = "eader!"
// n = 0 err = EOF b = [101 97 100 101 114 33 32 82]
// b[:n] = ""
```
