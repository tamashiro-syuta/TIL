# モック関連の用語の整理

- スタブ
  - 目的は「代わりになる」こと
    - 依存コンポーネントの代用
    - 定数を返す
  - `jest.mock()`は、ファイルのトップレベルでしか宣言できない かつ モジュール全体をmockする(特定のメソッドのみmockしたい場合は記述が増える)
- スパイ
  - 目的は「記録する」こと
    - 関数やメソッドの呼び出し(引数や実行回数など)を記録
    - 関数や引数のコールバックに関数の検証に使わることが多い
    - だいたいのテスト FW で、必要に応じてメソッドをスタブもできる
      - `jest.spyOn().mockRejectedValueOnce()`

# jestでのモック実装例

`greet.ts`に`greet`関数と`sayGoodBye`関数があるとする。
下のコードでは、`greet`関数の中で`sayGoodBye`関数の両方がモックされている。

```typescript
import { greet, sayGoodBye } from "./greet";

jest.mock("./greet", () => ({
  sayGoodBye: (name: string) => `Good bye, ${name}.`,
}));
```

呼び出したファイルの一部のみをモックするには以下。

```typescript
import { greet, sayGoodBye } from "./greet";

jest.mock("./greet", () => ({
  // NOTE: `/greet.ts` の関数をでファオルトではモックしない
  ...jest.requireActual("./greet"),
  // NOTE: ここで`sayGoodBye`関数のみモック
  sayGoodBye: (name: string) => `Good bye, ${name}.`,
}));
```

## WebAPI クライアントのスタブ実装例

### `jest.spyOn`を使うケース
- 特定のメソッドについて検証したい → `jest.spyOn()`
- mockしたい かつ 検証もしたい → `jest.spyOn().mockReturnValue()`

```typescript
test("データ取得失敗時、エラー相当のデータが例外としてスローされる", async () => {
  expect.assertions(2);
  const spy = jest
    .spyOn(Fetchers, "getMyProfile") // NOTE: spy化して検証できるようにしている
    .mockRejectedValueOnce(httpError); // NOTE: メソッドをスタブ化
  try {
    await getGreet();
  } catch (err) {
    expect(err).toMatchObject(httpError);
  }

  // NOTE: スパイ化したので、呼ばれたかの検証ができる
  expect(spy).toHaveBeenCalled();
});
```

# モック生成関数
※ レスポンスを再現するテストデータ = フィクスチャー

最小限のパラメータで返すmockを切り替えるモック生成関数を使えば、テストごとにモックを作成する必要がなくなる。



```typescript
function mockGetMyArticles(status = 200) {
  if (status > 299) {
    return jest
      .spyOn(Fetchers, "getMyArticles")
      .mockRejectedValueOnce(httpError);
  }
  return jest
    .spyOn(Fetchers, "getMyArticles")
    .mockResolvedValueOnce(getMyArticlesData);
}
```

# モック関数を使ったスパイ
<details>
<summary><code>jest.fn()</code>を使ったスパイで、色々できることのまとめ(便利そうだからコピペした)</summary>

```typescript
import { greet } from "./greet";

test("モック関数は実行された", () => {
  const mockFn = jest.fn();
  mockFn();
  expect(mockFn).toBeCalled();
});

test("モック関数は実行されていない", () => {
  const mockFn = jest.fn();
  expect(mockFn).not.toBeCalled();
});

test("モック関数は実行された回数を記録している", () => {
  const mockFn = jest.fn();
  mockFn();
  expect(mockFn).toHaveBeenCalledTimes(1);
  mockFn();
  expect(mockFn).toHaveBeenCalledTimes(2);
});

test("モック関数は関数の中でも実行できる", () => {
  const mockFn = jest.fn();
  function greet() {
    mockFn();
  }
  greet();
  expect(mockFn).toHaveBeenCalledTimes(1);
});

test("モック関数は実行時の引数を記録している", () => {
  const mockFn = jest.fn();
  function greet(message: string) {
    mockFn(message);
  }
  greet("hello");
  expect(mockFn).toHaveBeenCalledWith("hello");
});

test("モック関数はテスト対象の引数として使用できる", () => {
  const mockFn = jest.fn();
  greet("Jiro", mockFn);
  expect(mockFn).toHaveBeenCalledWith("Hello! Jiro");
});

test("モック関数は実行時引数のオブジェクト検証ができる", () => {
  const mockFn = jest.fn();
  checkConfig(mockFn);
  // mockFnの実行時の引数は 〇〇 だよね？ の検証
  expect(mockFn).toHaveBeenCalledWith({
    mock: true,
    feature: { spy: true },
  });
});

test("expect.objectContaining による部分検証", () => {
  const mockFn = jest.fn();
  checkConfig(mockFn);
  // mockFnの実行時の引数には 〇〇 が含まれているよね？ の検証
  expect(mockFn).toHaveBeenCalledWith(
    expect.objectContaining({
      feature: { spy: true },
    })
  );
});
```
</details>

# 現在時刻に依存したテスト
## 時刻を固定するメソッド
- `jest.useFakeTimers`
  - Jestに偽のタイマーを使用するように指示
- `jest.setSystemTime`
  - 偽のタイマーで使用される現在システム時刻を設定
- `jest.useRealTimers`
  - 真のタイマーを使用する(元の設定に戻す)ように指示

## 実装例
```typescript
// テスト対象の関数
function greetByTime() {
  const hour = new Date().getHours();
  if (hour < 12) {
    return "おはよう";
  } else if (hour < 18) {
    return "こんにちは";
  }
  return "こんばんは";
}

// テストコード
describe("greetByTime(", () => {
  beforeEach(() => {
    // NOTE: 各テストで偽のタイマーを使用するように設定
    jest.useFakeTimers();
  });

  afterEach(() => {
    // NOTE: 各テストの後に真のタイマーを使用するように設定
    jest.useRealTimers();
  });

  test("朝は「おはよう」を返す", () => {
    // NOTE: 偽のタイマーで使用される現在システム時刻を設定
    jest.setSystemTime(new Date(2023, 4, 23, 8, 0, 0));
    expect(greetByTime()).toBe("おはよう");
  });

  test("昼は「こんにちは」を返す", () => {
    // NOTE: 偽のタイマーで使用される現在システム時刻を設定
    jest.setSystemTime(new Date(2023, 4, 23, 14, 0, 0));
    expect(greetByTime()).toBe("こんにちは");
  });

  test("夜は「こんばんは」を返す", () => {
    // NOTE: 偽のタイマーで使用される現在システム時刻を設定
    jest.setSystemTime(new Date(2023, 4, 23, 21, 0, 0));
    expect(greetByTime()).toBe("こんばんは");
  });
});
```
