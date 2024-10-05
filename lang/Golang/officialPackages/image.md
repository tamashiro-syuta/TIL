---
title: "Imageパッケージ"
tags: ["Go"]
---
# Images
image パッケージは、以下の Image インタフェースを定義しています：

```go
package image

type Image interface {
    ColorModel() color.Model
    Bounds() Rectangle
    At(x, y int) color.Color
}
```

Note: Bounds メソッドの戻り値である Rectangle は、 image パッケージの image.Rectangle に定義があります。
(詳細は、 [このドキュメント](https://golang.org/pkg/image/#Image) を参照してください。)

color.Color と color.Model は共にインタフェースですが、定義済みの color.RGBA と color.RGBAModel を使うことで、このインタフェースを無視できます。 これらのインタフェースは、image/color パッケージで定義されています。

```go
package main

import (
	"fmt"
	"image"
)

func main() {
	m := image.NewRGBA(image.Rect(0, 0, 100, 100))
	fmt.Println(m.Bounds())
	fmt.Println(m.At(0, 0).RGBA())
}

// NOTE: 出力結果
// (0,0)-(100,100)
// 0 0 0 0
```
