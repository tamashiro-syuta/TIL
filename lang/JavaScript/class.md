# プライベートクラスメンバー
- クラス内で `#`(ハッシュ) を接頭辞としてつけることで、プライベートメンバーを定義できる。

- 以下の例だと、`#privateField` はプライベートフィールドになって、外部からアクセスできなくなる。
- メソッドも同様に`#`(ハッシュ) を接頭辞としてつけることで、プライベートメソッドにすることができる。(`#hoge`メソッド)

```js
class MyClass {
  #privateField = 42;

  getPrivateField() {
    return this.#privateField;
  }

  #hoge() {
    return this.#privateField;
  }
}
```

## Typescriptのprivate修飾子との違い
- Typescriptの`private`修飾子は、あくまでも "コンパイル時" にアクセスしていないかチェックするだけで、コンパイル後にプライベートな値にアクセスできる。
- 一方、JavaScriptのプライベートメンバーは、実行時にアクセスできないようになるため、Typescriptでも実行時にアクセスできないようにするためには、`#`(ハッシュ)を使う必要がある。
