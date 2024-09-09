# 関数
- Goにおけるd`main`関数は、全てのGoプログラムの実行開始場所

## Goにない「名前付き引数」と「オプション引数」
- Goには、PythonやJavaScriptにある「名前付き引数」や「オプション引数」がない
- 同じようなことをしたい場合は、構造体ごと引数にする
- そもそも、引数が多かったり複雑だったりする場合は、関数の設計を見直すべき

## 可変長引数
- 引数を可変長にするには、`...`を使う
- ただし、可変長引数は、最後の引数にしか使えない
  ```go
  func addTo(base int, vals ...int) []int {
    out := make([]int, 0, len(vals))
    for _, v := range vals {
      out = append(out, base+v)
    }
    return out
  }

  // addTo(1,3,5,7,9)
  ```

## 複数の戻り値
- だいたい`error`は ①戻り値の最後の値 or ②唯一の戻り値 とするのが一般的
- 複数の戻り値が設定されている関数を一つの変数に代入しようとすると、返り値は複数やろがいって怒られる
  - Goでは、戻り値は全部受け取るか、`_`で無視するかのどちらか

## 名前付き戻り値
- 関数の戻り値に名前をつけることができる
- ただし、以下の理由から使用には注意が必要
  - " **宣言した値に代入しなくても返すことができる** "
    - 返り値として指定した`num`は、`Hoge`関数が呼び出しされたタイミングで生成される
    - このときはゼロ値で変数が生成されるので、Hoge関数は`0`を返す
    ```go
    func Hoge() (num int) {
      return
    }

    func main() {
      result := Hoge()
      fmt.Println(result) // NOTE: 0
    }
    ```
  - " **定義時に指定していない値も返せるので可読性が下がる** "
    - 以下の例のように途中で、指定していない値を返していたり、行数が長いコードになると追いづらくなるので、注意が必要
    ```go
    func Hoge() (num int) {
      // ~ 何かしらの処理 ~
      if hoge {
        someValue := 1
        return someValue
      }
      // ~ 何かしらの処理 ~
      num = 1000000
      return num
    }
    ```
  - " **ブランクリターンする際、返り値がどの値かがわかりづらい** "
    - 以下の例で、`return`までの間に、`num`がどのように書き換えられているかがわかりづらい
    - グローバル変数を使うときみたいに「あれ、これ今なにはいってるっけ？」みたいな感覚
    - **関数が値を返す場合は、ブランクリターンは使わない方が良い**
    ```go
    func Hoge() (num int) {
      // ~ 何かしらの処理 ~
      return
    }
    ```
- 名前付き戻り値に対する理解は以下
    - **❌ その変数を戻り値として返すことを「要求」するもの**
    - **⭕️ 戻り値を保存するための変数を使用するという「意図」を宣言するもの**
    - つまり「俺はこいつからすからな〜」ではなく、「俺はこいつを返したいと思ってるよ〜」くらい

## 無名関数
- Goにもあるの知らなかった
- 以下のように、無名関数を変数に代入して、その変数を関数として使うことができる
- `func`の後に名前を書かずにすぐ引数かけばいけるぽ
  ```go
  func main() {
    for i := 0; i < 5; i++ {
      func(j int) {
        fmt.Println("無名関数の中で", j, "を出力")
      }(i)
    }
  }
  ```
- こんなのどこで使うねん！！って思ったけど、`defer`とゴルーチンの起動で使えるらしい
  - ゴルーチンは10章だからまだ先っすね(楽しみ)
  - 次のクロージャでも使うで！！！

## クロージャ
- クロージャは、関数の中で定義された関数のこと
- クロージャは、外側の関数の変数を参照できる(この特性を使って以下の機能を実現できる)
  - **関数のスコープを制限できるので、名前の衝突が起きにくい**
    - 他の関数から参照されないから、その中で定義した変数は他と被っても大丈夫だよね〜ってことだと思う。
  - **関数の中で定義された変数をその環境ごと包みこんで持ち出して、関数の外で使えるようになる**
    - なんか難しく言っているけど、要するに **「普通の関数は外の変数使えないけど、クロージャなら使えるよ、すごいでしょ」** ってこと
    - 以下の例の`sort.Slice`に注目。
      - `sort.Slice`に渡しているのは、`people`というスライスと、`func`で定義された無名関数
      - この無名関数の中で、`people`というスライスを参照している(無名関数内で定義したわけじゃないのに参照できるのはこの無名関数がクロージャだから)
      - この参照できることを、peopleはクロージャによって捕捉された(英語では`captured`)と表現する
    ```go
    func main() {
      type Person struct { //liststart1
        FirstName string
        LastName  string
        Age       int
      }

      people := []Person{
        {"Pat", "Patterson", 37},
        {"Tracy", "Bobbert", 23},
        {"Fred", "Fredson", 18},
      }
      fmt.Println("●初期データ")
      fmt.Println(people) //listend1

      // 姓（LastName）でソート //liststart2
      sort.Slice(people, func(i int, j int) bool {
        return people[i].LastName < people[j].LastName
      })
      fmt.Println("●姓（LastName。2番目のフィールド）でソート")
      fmt.Println(people) //listend2

      // 年齢（Age）でソート //liststart3
      sort.Slice(people, func(i int, j int) bool {
        return people[i].Age < people[j].Age
      })
      fmt.Println("●年齢（Age）でソート")
      fmt.Println(people) //listend3

      fmt.Println("●ソート後のpeople") //liststart4
      fmt.Println(people) //listend4
    }
    ```

## defer
- `defer`は、関数の終了時に必ず実行される処理を指定する
- 一時的なリソースの解放や、`defer`により遅延実行を指定された関数が外側の関数の戻り値を検証したりするのに使われる
- `defer`の特徴
  - `return`の後に実行される
  - `LIFO`(後入れ先出し)の順番で実行されるので、イメージとしては`return`からスタートしてコードを登って実行されていく感じ
- 各ユースケース別のサンプルコード
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

- 玉城が`defer`さんに感じていた疑問
  - ❓どうせ`return`の後に実行されるのに、なんで`return`の近くに書かないの？読みにくくない？？
  - 👉 `defer`の書く前に以上を検知して処理が終わると`defer`でしたい後処理が実行されない
    - リソースが解放されずに、メモリリークが発生する可能性がある
    - 上のDBの例だと、エラー時にデータの不整合が起きちゃうかも(最悪の事態すぎる。。。)
  - 👉 あとシンプルに書き忘れる可能性もある

## なんか良いこと書いていたのでメモ
> エラーに弱いコードは書かないようにしましょう。
>
> 入力されるデータの検証を省きたい誘惑に駆られるかもしれませんが、省いてしまうと不安定で保守不能なコードになってしまいます。
>
> アマチュアとプロを分けるのがエラー処理です。
