---
title: "クロージャー"
tags: ["Go"]
---
# クロージャ の基本
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
