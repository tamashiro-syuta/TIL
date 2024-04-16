# アロー関数とその他の関数の違い
| | コード | ホイスティング | `this`を持つか |
|:-----------|:------------|:------------|:------------|
| 通常の関数宣言     | `function add(x, y) {}`  | ⭕️ される    | ⭕️ 持つ |
| 関数式            | `const add = function(x,y) {}`  | ❌ されない  | ⭕️ 持つ |
| 関数式(アロー関数)  | `const add = () => {}`  | ❌ されない  | ❌ 持たない(外の階層の`this`を探す) |

## ホイステイングの例
### ホイスティングとは？
- 【超要約】 **宣言前に参照できるかどうか？**
- 任意の変数や関数などを、スコープの最上位に持ち上げられた(`hoisting`された)ように動作する挙動
  - ex) `var`で宣言された変数は、宣言前に参照できる => これは、変数がホイスティングされて、スコープのトップで宣言されたように動作するため
  - 本来の宣言箇所で代入され、それ以降では意図した挙動(定義した挙動や値)になる。
  - 宣言前は、`undefined`として扱われる

### コード例
```javascript
funcA(); // NOTE: 関数宣言のため、ホイスティングされていて、エラーが発生しない
funcB(); // NOTE: エラーが発生する
funcC(); // NOTE: エラーが発生する

function funcA() {
  console.log(this)
}

const funcB = function () {
  console.log(this)
}

const funcC = () => {
  console.log(this)
}
```

## `this`を持つか？
- アロー関数自身は、`this`を持たないため、外部スコープ(レキシカルスコープ)の`this`を参照していく。
- 無ければからオブジェクトを返す

### コード例
```javascript
function funcA() {
  console.log(this)
}

const funcB = function () {
  console.log(this)
}

const funcC = () => {
  console.log(this)
}

funcA(); // NOTE: Window {window: Window {...}, self: Window ...} ...etc
funcB(); // NOTE: indow {window: Window {...}, self: Window ...} ...etc
funcC(); // NOTE: {} ← thisを持たない(外部スコープも含め)ため、空オブジェクトが返る
```
