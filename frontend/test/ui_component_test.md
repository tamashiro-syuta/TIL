# テスト環境の構築
このファイルで利用するライブラリ
```bash
# Jest のUIコンポーネントの環境構築のためのライブラリ
jest-environment-jsdom
# testing libraryをReact用に拡張
@testing-library/react
# jestのマッチャーが使えるように拡張
@testing-library/jest-dom
# ユーザーの操作をシミュレートするためのライブラリ(testing libraryのAPIより、よりユーザーの挙動に近い操作がエミュレートできる)
@testing-library/user-event
```

※ Jestの実行環境のNode.jsには、DOMを操作するAPIが存在しないため、`jsdom`などのライブラリを使用して環境をセットアップする必要がある。

※ 最新版では、改善された`jest-environment-jsdom`を別途インストールして指定する必要がある。
  - Next.jsのようなサーバーサイドとクライアントサイドの両方で動作するアプリケーションでは、テストファイルの冒頭に以下のように宣言して、ファイルごとにテスト環境を切り替えることができる。
    ```typescript
    /**
     * @jest-environment jest-environment-jsdom
     */
    ```

# `Testing Library`の概要
- `Testing Library`は、UIコンポーネントのテストを行うためのライブラリ
- `Testing Library`でできる３つのこと
  1. UIコンポーネントのレンダリング
  2. 任意の子要素の取得
  3. 任意のイベントの発火
- `Testing Library`はReact以外にも拡張ライブラリを提供しており、内部では共通の`@testing-library/dom`を利用している。
- `jest`のマッチャーが使えるように拡張された`@testing-library/jest-dom`もある。

# テストの書き方
[フロントエンド開発のテスト入門の5-3のサンプルコード](https://github.com/frontend-testing-book/unittest/blob/main/src/05/03/Form.tsx) のテストコード(ファイル全体)

```ts
import { fireEvent, logRoles, render, screen } from "@testing-library/react";
import { Form } from "./Form";

test("名前の表示", () => {
  // NOTE: formコンポーネントをレンダリング
  render(<Form name="taro" />);
  // NOTE: テキスト「taro」を持つ要素を1つ取得し、その要素が存在することを確認
  expect(screen.getByText("taro")).toBeInTheDocument();
});

test("ボタンの表示", () => {
  render(<Form name="taro" />);
  // NOTE: 特定の要素をロールで取得
  expect(screen.getByRole("button")).toBeInTheDocument();
});

test("見出しの表示", () => {
  render(<Form name="taro" />);
  expect(screen.getByRole("heading")).toHaveTextContent("アカウント情報");
});

test("ボタンを押下すると、イベントハンドラーが呼ばれる", () => {
  const mockFn = jest.fn();
  render(<Form name="taro" onSubmit={mockFn} />);
  fireEvent.click(screen.getByRole("button"));
  expect(mockFn).toHaveBeenCalled();
});

test("Snapshot: アカウント名「taro」が表示される", () => {
  const { container } = render(<Form name="taro" />);
  expect(container).toMatchSnapshot();
});

test("logRoles: レンダリング結果からロール・アクセシブルネームを確認", () => {
  const { container } = render(<Form name="taro" />);
  logRoles(container);
});
```

## 基本的な書き方
```ts
test("名前の表示", () => {
  // NOTE: formコンポーネントをレンダリング
  render(<Form name="taro" />);
  // NOTE: テキスト「taro」を持つ要素を1つ取得し、その要素が存在することを確認
  expect(screen.getByText("taro")).toBeInTheDocument();
});
```

💡 `jest.setup.ts`で`@testing-library/jest-dom`をインポートしておくと、テストファイル全体で`jest`のマッチャーが使えるようになる。(上の例も`@testing-library/jest-dom`のカスタムマッチャー)
```ts
// jest.setup.ts
import "@testing-library/jest-dom";
```

## 暗黙的なロール
💡 Testing Libraryでは **「暗黙的なロール」** も含めたクエリーを優先して使うことも推奨されている。
  - 例えば、以下では`getByRole("heading")`とすることで、見出しであるh1~h6タグを持つ要素を取得している。
```ts
test("見出しの表示", () => {
  render(<Form name="taro" />);
  expect(screen.getByRole("heading")).toHaveTextContent("アカウント情報");
});
```

## イベントハンドラー呼び出し
`const mockFn = jest.fn();` でスパイ関数を作成し、`fireEvent.click(screen.getByRole("button"));` でボタンをクリックすると、スパイ関数が呼び出されることを確認している。

※ `jest.fn()`はモック関数を作成する関数だが、以下の例では、呼び出しの確認のために利用しており、スパイの目的である「呼び出しの記録」の用途で利用している。
```ts
test("ボタンを押下すると、イベントハンドラーが呼ばれる", () => {
  const mockFn = jest.fn();
  render(<Form name="taro" onSubmit={mockFn} />);
  // ボタン要素をクリックした時に
  fireEvent.click(screen.getByRole("button"));
  // スパイ関数が呼び出されることを確認
  expect(mockFn).toHaveBeenCalled();
});
```
