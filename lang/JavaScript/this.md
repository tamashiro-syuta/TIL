# JavaScriptにおける`this`
## 超要約すると、、、
- JavaScriptにおける`this`は、関数が呼び出された際に、その関数を呼び出したオブジェクトを指す。
- `this`の対象がない場合は、グローバルオブジェクトを指す。
  - ブラウザだと`window`オブジェクト
  - Node.jsだと`global`オブジェクト

# `this`周りでよく使われる `bind`, `call`, `apply`
## `bind`メソッド
- `this`の値を固定するために使われる

### 実装例の解説
- `sayName`内では、`this`がコンテキストを失っているため、`this === undefined`となり、`undefined`が出力される。
  - `this`なんて、俺は知らないぜ？ってなってる状態
- `bindSayName`内では、`this`を`obj2`に固定しているため、`Hanako`が出力される。

```javascript
const obj = {
  name: 'Taro',
  sayName() { console.log(this.name); }
}

const obj2 = { name: 'Hanako' }

const sayName = obj.sayName;
sayName(); // NOTE: undefined or windowオブジェクト

const bindSayName = obj.sayName.bind(obj2);
bindSayName(); // NOTE: Hanako
```

***

## `call`メソッド
- `this`の値を固定するために使われる + 引数を渡すことができる
- "`bind` + 引数" のイメージ

### 実装例の解説
- `sayName`に、obj2を`this`として渡している + 引数として`Hello`を渡している
```javascript
function sayName(greeting) {
  console.log(`${greeting}, ${this.name}`);
}

const obj2 = { name: 'Hanako' }
sayName.call(obj2, 'Hello'); // NOTE: Hello, Hanako
```

***

## `apply`メソッド
- `this`の値を固定するために使われる + 引数を配列として渡すことができる
- "`bind` + 引数(配列)" のイメージ
- `call`の配列ver

### 実装例の解説
- `sayName`に、obj2を`this`として渡している + 引数として`['Hello', 'hoge']`を渡している
```javascript
function sayName(greeting, message) {
  console.log(`${greeting}, ${this.name}, ${message}`);
}

const obj2 = { name: 'Hanako' }
sayName.apply(obj2, ['Hello', 'hoge']); // NOTE: Hello, Hanako, hoge
```
