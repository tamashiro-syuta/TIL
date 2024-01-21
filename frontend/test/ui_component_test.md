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

※ Jest の実行環境の Node.js には、DOM を操作する API が存在しないため、`jsdom`などのライブラリを使用して環境をセットアップする必要がある。

※ 最新版では、改善された`jest-environment-jsdom`を別途インストールして指定する必要がある。

- Next.js のようなサーバーサイドとクライアントサイドの両方で動作するアプリケーションでは、テストファイルの冒頭に以下のように宣言して、ファイルごとにテスト環境を切り替えることができる。
  ```typescript
  /**
   * @jest-environment jest-environment-jsdom
   */
  ```

# `Testing Library`の概要

- `Testing Library`は、UI コンポーネントのテストを行うためのライブラリ
- `Testing Library`でできる３つのこと
  1. UI コンポーネントのレンダリング
  2. 任意の子要素の取得
  3. 任意のイベントの発火
- `Testing Library`は React 以外にも拡張ライブラリを提供しており、内部では共通の`@testing-library/dom`を利用している。
- `jest`のマッチャーが使えるように拡張された`@testing-library/jest-dom`もある。

# テストの書き方

[フロントエンド開発のテスト入門の 5-3 のサンプルコード](https://github.com/frontend-testing-book/unittest/blob/main/src/05/03/Form.tsx) のテストコード(ファイル全体)

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

※ import を共通化して、各ファイルごとの宣言を省略している。(コメントアウトするとエラーになる)

```ts
// jest.setup.ts
import "@testing-library/jest-dom";
```

## 暗黙的なロール

💡 Testing Library では **「暗黙的なロール」** も含めたクエリーを優先して使うことも推奨されている。

- 例えば、以下では`getByRole("heading")`とすることで、見出しである h1~h6 タグを持つ要素を取得している。

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

## `within`関数で絞り込む

`within`関数を使うと、特定の要素の中から要素を取得できる。

`within`関数の返り値には、`screen`と同じ要素取得 API が含まれているため、`getAllByRole`などの API を使って要素を取得できる。

```ts
test("items の数だけ一覧表示される", () => {
  render(<ArticleList items={items} />);
  const list = screen.getByRole("list");
  expect(list).toBeInTheDocument();

  // NOTE: listの中に存在するli要素を取得
  expect(within(list).getAllByRole("listitem")).toHaveLength(3);
});
```

## `queryBy`接頭辞でエラーを回避する

`getBy`接頭辞は、要素が見つからない場合にエラーを発生させるが、`queryBy`接頭辞は、要素が見つからない場合に`null`を返す。

- `queryBy`接頭辞を使うと、`if`文で要素の存在を確認することができる。

```ts
test("一覧アイテムが空のとき「投稿記事がありません」が表示される", () => {
  render(<ArticleList items={[]} />);
  // NOTE: listがない場合は、null が返る
  const list = screen.queryByRole("list");

  // NOTE: listは存在しない
  expect(list).not.toBeInTheDocument();
  // NOTE: listはnull
  expect(list).toBeNull();
  expect(screen.getByText("投稿記事がありません")).toBeInTheDocument();
});
```

## `toHaveAttribute`で属性を検証する

`toHaveAttribute`を使うと、要素の属性を検証できる。

```ts
test("ID に紐づいたリンクが表示される", () => {
  render(<ArticleListItem {...item} />);
  // link かつ もっと見る というテキストを持つ要素を取得
  expect(screen.getByRole("link", { name: "もっと見る" }))
    // href属性が指定した値を持つことを確認
    .toHaveAttribute("href", "/articles/howto-testing-with-typescript");
});
```

## `@testing-library/user-event`でユーザーイベントを発火

`@testing-library/user-event`を使うと、ユーザーの操作をシミュレートできる。
ファイルのトップレベルで、`userEvent.setup()`でインスタンスを作成し、それを使って、イベントを発火させる。

※ ユーザーの操作は非同期処理なので、`await`をつける必要がある。

```ts
import userEvent from "@testing-library/user-event";

// instanceを作成
const user = userEvent.setup();

test("メールアドレス入力欄", async () => {
  render(<InputAccount />);
  const textbox = screen.getByRole("textbox", { name: "メールアドレス" });
  const value = "taro.tanaka@example.com";

  // ユーザーの操作(非同期)を待つため、awaitをつける
  await user.type(textbox, value);
  expect(screen.getByDisplayValue(value)).toBeInTheDocument();
});
```

※ `<input type='password' />`は暗黙のロールを持たないので、別の手段で要素を特定する必要がある

- ex) `placeholder`で特定する
  ```ts
  test("パスワード入力欄", async () => {
    render(<InputAccount />);
    // NOTE: placeholder でパスワード入力欄を取得(エラーはthrowされない)
    expect(() => screen.getByPlaceholderText("8文字以上で入力")).not.toThrow();
    // NOTE: ロール でパスワード入力欄を取得（パスワード用のinputタグは暗黙なロールを持たないので、textboxで取得しようとするとエラーをthrow）
    expect(() => screen.getByRole("textbox", { name: "パスワード" })).toThrow();
  });
  ```

## ユーザーイベントを発火させ、インタラクティブな UI をテストする例

ex) チェックボックスにチャックを入れると、ボタンが活性化することをテストする

```ts
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Form } from "./Form";

const user = userEvent.setup();

test("「利用規約の同意」チェックボックスを押下すると「サインアップ」ボタンは活性化", async () => {
  render(<Form />);

  // NOTE: ユーザーがチェックボックスをクリックする
  await user.click(screen.getByRole("checkbox"));

  // NOTE: ボタンが活性化していることを確認
  expect(screen.getByRole("button", { name: "サインアップ" })).toBeEnabled();
});
```

## 繰り返し起こる操作を関数にまとめる

以下のような関数を作成することで、テストをより DRY に書くことができる。

特にユーザーの操作が多いフォームでは、関数化の効果が高い。

```ts
import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

const user = userEvent.setup();

async function inputContactNumber(
  inputValues = {
    name: "田中 太郎",
    phoneNumber: "000-0000-0000",
  }
) {
  await user.type(
    screen.getByRole("textbox", { name: "電話番号" }),
    inputValues.phoneNumber
  );
  await user.type(
    screen.getByRole("textbox", { name: "お名前" }),
    inputValues.name
  );
  return inputValues;
}
```

## 引数の内容を記録するスパイを返すカスタム Hook (便利そうなのでコードを拝借 🙏)

```ts
// NOTE: 引数の内容を記録するスパイを返すカスタムHook
function mockHandleSubmit() {
  const mockFn = jest.fn();
  const onSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const data: { [k: string]: unknown } = {};
    formData.forEach((value, key) => (data[key] = value));

    // NOTE: mockFn に入力内容を渡して実行 = mockFnはスパイなので、引数を記録できる
    mockFn(data);
  };
  return [mockFn, onSubmit] as const;
}
```

### 使用例
```ts
test("入力・送信すると、入力内容が送信される", async () => {
  const [mockFn, onSubmit] = mockHandleSubmit();
  render(<Form onSubmit={onSubmit} />);
  const contactNumber = await inputContactNumber();
  const deliveryAddress = await inputDeliveryAddress();

  // NOTE: フォームを送信する処理と仮定
  await clickSubmit();

  // NOTE: mockFnがどの引数で実行されたかを確認する
  expect(mockFn).toHaveBeenCalledWith(
    expect.objectContaining({ ...contactNumber, ...deliveryAddress })
  );
});
```

# 実務でも使えそうなテスト例
- [非同期処理を含むUIコンポーネントテストのテスト例](https://github.com/frontend-testing-book/unittest/tree/main/src/05/07)
