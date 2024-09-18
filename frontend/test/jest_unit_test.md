---
title: "フロントエンド開発のためのテスト入門 ~ 単体テスト ~"
tags: ["フロントエンド", "テスト", "書籍"]
---
# 単体テスト

## 例外をテストする

- 例外をテストする際の expect の引数には、**例外発生が想定される関数を渡す**
  - ⭕️ 例外が発生する関数を渡す
  - ❌ 例外が発生しない関数を実行する処理を記述
    - テストする段階でもう例外が発生しちゃってるため、テストが失敗
    - 「この関数を実行したら例外が起きるよね？」を確かめたいから、例外が発生しない関数を実行する処理を記述してはいけない

```TypeScript
export class RangeError extends Error {}

function checkRange(value: number) {
    if (value < 0 || value > 100) {throw new RangeError("入力値は0〜100の間で入力してください");}
}

export function add(a: number, b: number) {
    checkRange(a);
    checkRange(b);
    const sum = a + b;
    if (sum > 100) { return 100; }
    return sum;
}

// Test.ts
describe("add", () => {
    // ⭕️ 例外が発生する関数を渡す
    test("引数が'0〜100'の範囲外だった場合、例外をスローする", () => {
        const message = "入力値は0〜100の間で入力してください";
        expect(() => add(-10, 10)).toThrow(message);
    });

    // ❌ 例外が発生しない関数を実行する処理を記述
    test("引数が'0〜100'の範囲外だった場合、例外をスローする", () => {
      	const message = "入力値は0〜100の間で入力してください";
        expect(add(-10, 10)).toThrow(message);
    });
});
```

- Error クラスを拡張する場合は、`instanceof`演算子を使えば、どのエラーをテストするかを指定できる
  ```typescript
    if (err instanceof RangeError) {
      /* 捉えた例外がRangeErrorインスタンスの場合 */
    }
  ```
  - ⚠️ 拡張もとのクラスを指定するとテストが成功してしまい、意図したエラーか判別できないので注意(例外の握りつぶし)

- [よく使われる matcher 一覧](https://jestjs.io/ja/docs/using-matchers)

## 非同期処理のテスト

非同期テストのよくあるパターン

- `Promise`を返す
  - `then`に渡す関数内にアサーションを書く
    ```typescript
    test("指定時間待つと、経過時間をもって resolve される", () => {
      return wait(50).then((duration) => {
        expect(duration).toBe(50);
      });
    });
    ```
  - `resolve`を使用してアサーションを書く
    ```typescript
    test("指定時間待つと、経過時間をもって resolve される", () => {
      return expect(wait(50)).resolves.toBe(50);
    });
    ```
- `async/await`を使う
  - テスト自体を`async/await`を使って非同期の関数にして、関数内で非同期処理が終わるのを待って空テストする
    ```typescript
    test("指定時間待つと、経過時間をもって resolve される", async () => {
      await expect(wait(50)).resolves.toBe(50);
    });
    ```
  - expect 節内で非同期処理が終わるのを待つ(これが一番シンプル)
    ```typescript
    test("指定時間待つと、経過時間をもって resolve される", async () => {
      expect(await wait(50)).toBe(50);
    });
    ```
- 非同期処理が`Reject`されたことを検証する
  - 以下の引数(`duration`)を`reject`して返す関数があるとする
    ```typescript
    export function timeout(duration: number) {
      return new Promise((_, reject) => {
        setTimeout(() => {
          reject(duration);
        }, duration);
      });
    }
    ```
  - `Promise`を返す
    - `promise`(timeout 関数)ごと返して、catch 内でアサーションを書く
    ```typescript
    test("指定時間待つと、経過時間をもって reject される", () => {
      return timeout(50).catch((duration) => {
        expect(duration).toBe(50);
      });
    });
    ```
  - `async/await`と`reject`の matcher を使用してアサーションを書く
    ```typescript
    test("指定時間待つと、経過時間をもって reject される", () => {
      return expect(timeout(50)).rejects.toBe(50);
    });
    // or
    test("指定時間待つと、経過時間をもって reject される", async () => {
      await expect(timeout(50)).rejects.toBe(50);
    });
    ```
  - try catch でテストを書く場合は、`expect assertions()`を使用して必ずアサーションが実行されることを検証できる
    - テストの実装ミスで、アサーションが実行されないことを防げる
    - ↑ 便利そう
    ```typescript
    test("指定時間待つと、経過時間をもって reject される", async () => {
      expect.assertions(1); // この記述がないと
      try {
        await timeout(50); // timeout関数のつもりが、wait関数にしてしまった場合、ここで終了してしまい、テストは成功する
      } catch (err) {
        // アサーションは実行されない
        expect(err).toBe(50);
      }
    });
    ```
