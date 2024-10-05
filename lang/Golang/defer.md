---
title: "Defer"
tags: ["Go"]
---
# Defer の基本
- `defer`は、関数の終了時に必ず実行される処理を指定する
- 一時的なリソースの解放や、`defer`により遅延実行を指定された関数が外側の関数の戻り値を検証したりするのに使われる
- `defer` へ渡した関数の引数は、すぐに評価されますが、その関数自体は呼び出し元の関数がreturnするまで実行されません
- `defer`の特徴
  - `return`の後に実行される
  - `LIFO`(後入れ先出し)の順番で実行されるので、イメージとしては`return`からスタートしてコードを登って実行されていく感じ
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
- こういうのもできる
	```go
	package main

	import "fmt"

	// 関数を返す関数を定義
	func createFunctions() (func(), func()) {
		defer fmt.Println("world")

		// LIFO順に呼び出される関数を定義
		firstFunc := func() {
			fmt.Println("first")
		}
		secondFunc := func() {
			fmt.Println("second")
		}

		fmt.Println("hello")

		return firstFunc, secondFunc
	}

	func main() {
		first, second := createFunctions()

		defer second()
		defer first()
	}

	// NOTE: 出力結果
	// hello
	// world
	// first
	// second
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

## 各ユースケース別のサンプルコード
- 一時的に使用したリソースを解放したい！
  ```go
  func main() {
    f, err := os.Open("filename.ext")
    if err != nil {
      log.Fatal(err)
    }
    defer f.Close() // NOTE: return後に実行される
    // ~ 何かしらの処理 ~
    hoge := make([]byte, 1024)
    return hoge
  }
  ```
- 戻り値に応じた後処理がしたい！！
  - **名前付き戻り値** を使うことで、エラーに応じた処理ができる！
  - 以下は、DBのトランザクション処理の例
    - トランザクション内でエラーが発生した場合、ロールバック、エラーがない場合はコミットが実行される
  ```go
  func doSomeInserts(ctx context.Context, db *sql.DB, value1 string) (err error) {
    tx, err := db.BeginTx()
    if err != nil {
      return err
    }
    defer func() {
      // NOTE: エラーがなければコミット、エラーがあればロールバック
      if err == nil {
        tx.Commit()
      }
      if err != nil {
        tx.Rollback()
      }

    }()

    _, err = tx.ExecContext(ctx, "INSERT INTO table1 (val) values $1", value1)
    // ~ 何かしらの処理 ~
    return nil
  }
  ```
- クロージャーを返して、`defer`での後始末を忘れさせない
  - 以下の例では、`defer`で`Close`を実行している
  - 利用側が返り値としてクリーンアップする関数を受け取りことで、リソースの解放を忘れさせない
    ```go
    func getFile(name string) (*os.File, func(), error) {
      file, err := os.Open(name)
      if err != nil {
        return nil, nil, err
      }

      cleanup := func() {
        file.Close()
      }
      return file, cleanup, err
    }

    // NOTE: 利用側が返り値としてクリーンアップする関数を受け取りことで、リソースの解放を忘れさせない
    f, cleanup, err := getFile("filename.ext")
    if err != nil {
      log.Fatal(err)
    }
    defer cleanup()
    ```

***

# 玉城が`defer`さんに感じていた疑問
  - ❓どうせ`return`の後に実行されるのに、なんで`return`の近くに書かないの？読みにくくない？？
  - 👉 `defer`の書く前に以上を検知して処理が終わると`defer`でしたい後処理が実行されない
    - リソースが解放されずに、メモリリークが発生する可能性がある
    - 上のDBの例だと、エラー時にデータの不整合が起きちゃうかも(最悪の事態すぎる。。。)
  - 👉 あとシンプルに書き忘れる可能性もある

***

# なんか良いこと書いていたのでメモ
> エラーに弱いコードは書かないようにしましょう。
>
> 入力されるデータの検証を省きたい誘惑に駆られるかもしれませんが、省いてしまうと不安定で保守不能なコードになってしまいます。
>
> アマチュアとプロを分けるのがエラー処理です。
