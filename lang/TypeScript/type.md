---
title: "意外と知らない TypeScript の型"
tags: ["TypeScript"]
---

# 意外と知らない TypeScript の型

## タプル型

- Array の厳密 ver
- 「どの要素はどの型にするか？」「要素数はいくつにするか？」などのカスタマイズをできる

```typescript
type Foo = [first: number, second?: string, ...rest: any[]];

let a: Foo = [1];
let b: Foo = [1, "hoge"];
let c: Foo = [1, "hoge", true, 10, "world"];

console.log(...c);
// 結果 : 1, hoge, true, 10, world

c[6] = "five";
console.log(...c);
// 結果 : 1, hoge, true, 10, world, undefined, five
```

## unknown 型

- 型安全を維持しながら未知の方を扱うことができる
- どんな型でも代入できるが、使う際には型チェックが必要
- 算術演算子を使うことができない
- 比較演算子は使える
- **型チェック後は、その型に変換される**
- 外部 API とのやり取りなどで使うと便利そう

```typescript
let value1: unknown = 1; // unknown型なので、どんな値でも代入可能

let value2: number = value1; // Type 'unknown' is not assignable to type 'number'.

value1 + 1; // Operator '+' cannot be applied to types 'unknown' and '1'.
if (typeof value1 === "number") {
  value1 + 1; // ここではエラーはでない
}

value1 = "this is unknown";
```

## never 型

- 関数が戻り値を返さず、かつ呼び出し元に制御が戻らないことを表す型
- 戻り値を返さないことを明示的にしますことで、堅安全性を向上させて保守性を高める
- 正常に終了しないことを示す型
  - 関数が例外を投げる
  - 無限ループ
- `void`との違い
  - `void` : 何も返さない
  - `never` : 関数が正常に戻る「終了点」を持たない
- `never`型の使用できるケース
  - 無限ループや再帰処理のように終了しない関数
    ```typescript
    function loop(message: string): never {
      while (true) console.log(message);
    }
    ```
  - 例外を投げて以上終了する関数
    ```typescript
    function error(message: string): never {
      throw new Error(message);
    }
    ```
  - 到達不可能なコードのパスを示す場合
    - 引数の型から、default 節に到達しないことは明白なので、`never`型を使っている
    ```typescript
    type Hoge = "hoge" | "fuga";
    function loop(message: Hoge): never {
      switch (message) {
        case "hoge":
          return "hoge";
        case "fuga":
          return "fuga";
        default:
          const unreachable: never = message;
          throw new Error(unreachable);
      }
    }
    ```

## 関数オーバーロード

- 「この型を引数に取った場合は、この型を返すよ〜」を宣言できる
- 柔軟な方の処理を実装可能になるが、処理が複雑になるため、ご利用は計画的に！！！

```typescript
function add(a: number, b: number): number; // NOTE: number型とnumber型を引数に取り、number型を返す関数
function add(a: string, b: string): string; // NOTE: string型とstring型を引数に取り、string型を返す関数
function add(a: any, b: any): any {
  return a + b;
}

// NOTE: result1は、引数がnumber型とnumber型なので、戻り値がnumber型と解釈される
const result1 = add(1, 2); // 3
// NOTE: result2は、引数がstring型とstring型なので、戻り値がstring型と解釈される
const result2 = add("hello", "world"); // helloworld
```

## トップ型(unknown)とボトム型(never)

- TypeScript において、すべての型を抽象化すると (言い換えるとすべての型のスーパータイプになるのは) unknown 型になる
- 逆に、すべての型のサブタイプとなるのは never 型
  ![TypeScriptにおける型システムの階層構造](https://knmts.com/images/2021-12-13_1.png)
- unknown 型は、どの型でも代入できる = すべての型のスーパータイプ
- never 型には実際の値が存在せず、どの型でもない = どの型のサブタイプでもない

---

# 知らなかった型の絞り込み方法

## in による絞り込み

- オブジェクトが特定のプロパティを持っているかどうかをチェックする

  ```typescript
  interface Foo {
    a: number;
    b: string;
  }
  interface Bar {
    c: number;
  }
  function isFoo(obj: Foo | Bar) {
    // NOTE: objがaというプロパティを持つかで判別
    if ("a" in obj) {
      console.log(obj.a);
    } else {
      console.log(obj.c);
    }
  }

  isFoo({ a: 123, b: "123" }); // 123
  ```

## タグ付きユニオンによる絞り込み

- in より 複雑な条件で絞り込みを行う
- タグは TypeScript 側であらかじめ用意されている予約語ではなく、開発者が定義するプロパティをタグとして使用するもの

  ```typescript
  interface Foo {
    type: "foo";
    a: number;
    b: string;
  }
  interface Bar {
    type: "bar";
    c: number;
  }
  interface Buz {
    type: "buz";
    a: number;
  }

  function isFoo(obj: Foo | Bar | Buz) {
    switch (obj.type) {
      case "foo":
        console.log(obj.a, obj.b);
        break;
      case "bar":
        console.log(obj.c);
        break;
      case "buz":
        console.log(obj.a);
        break;
    }
  }

  isFoo({ type: "foo", a: 123, b: "123" }); // 123
  ```

## satisfies による絞り込み

- satisfiesを使うと、定義時の型類推を維持したまま、オブジェクトが特定の型を満たしているかどうかをチェックできる
- ex: RGB 形式 or カラーコード で色を表現する型を定義したい場合

  ```typescript
  type RGB = [red: number, green: number, blue: number]; // ラベル付きタプル
  interface Color {
    red: RGB | string;
    green: RGB | string;
    blue: RGB | string;
  }

  // NOTE: NG!!!
  const color: Color = {
    red: [255, 0, 0],
    green: "00ff00",
    blue: [0, 0, 255],
  };
  const greenNormalized = color.green.toUpperCase(); // RGB型にはtoUpperCaseメソッドが存在しない(タプル型なので)

  // NOTE: OK!!!
  const color = {
    red: [255, 0, 0],
    green: "00ff00",
    blue: [0, 0, 255],
  } satisfies Color; // NOTE: 定義時の型類推(ここでいうgreenがstring型であること)を維持したまま、Color型を満たしているかどうかをチェック
  const greenNormalized = color.green.toUpperCase(); // "00FF00"
  ```

## 型述語による絞り込み(ユーザー定義の関数のみ)
- 自作の型ガードの場合、返り値の型を型述語によって指定しないとTypeScript側が型を絞り込んでくれない
  - **!! TypeScriptのv5.5からは、型述語を使わなくてもTypeScript側が型を絞り込んでくれるようになった**
  - https://zenn.dev/ubie_dev/articles/ts-infer-type-predicates
  ```typescript
  function isString(value: unknown): boolean {
    return typeof value === "string";
  }

  function hoge(value: string | number) {
    if (isString(value)) {
      // NOTE: valueはまだstring型として扱われない(型述語がないため)
      // NOTE: isStringの処理的にはvalueがstringなのは確定しているが、TypeScriptはそれを理解できない
      console.log(value.toUpperCase());
    } else {
      console.log(value.toFixed(2));
    }
  }
  ```
- 型述語を使うことで、TypeScript側が型を絞り込んでくれる
  ```typescript
  function isString(value: unknown): value is string {
    return typeof value === "string";
  }

  function hoge(value: string | number) {
    if (isString(value)) {
      // NOTE: valueはstring型として扱われる
      console.log(value.toUpperCase());
    } else {
      console.log(value.toFixed(2));
    }
  }
  ```
