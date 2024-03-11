# 結合テスト

## 複数画面で横断的に使用するコンポーネントの結合テスト
- muiの`<Snackbar />`的なやつ

### テスト観点
1. `Provider`が保持する状態に応じて、表示が切り替わる
2. `Provider`が保持する更新関数を経由して、状態が更新できる

### 方法1: テスト用のコンポーネントを用意して、インタラクションを実行
```ts
const user = userEvent.setup();

const TestComponent = ({ message }: { message: string }) => {
  const { showToast } = useToastAction(); // <Toast> を表示するためのフック
  return <button onClick={() => showToast({ message })}>show</button>;
};

test("showToast を呼び出すと Toast コンポーネントが表示される", async () => {
  const message = "test";
  render(
    <ToastProvider>
      <TestComponent message={message} />
    </ToastProvider>
  );
  // NOTE: 初めは表示されていない
  expect(screen.queryByRole("alert")).not.toBeInTheDocument();
  await user.click(screen.getByRole("button"));
  // NOTE: 表示されていることを確認
  expect(screen.getByRole("alert")).toHaveTextContent(message);
});
```
### 方法2: 初期値を注入し、表示を確認

```ts
test("Succeed", () => {
  const state: ToastState = {
    isShown: true,
    message: "成功しました",
    style: "succeed",
  };

  // NOTE: 初期値を注入
  render(<ToastProvider defaultState={state}>{null}</ToastProvider>);
  // NOTE: 表示されていることを確認
  expect(screen.getByRole("alert")).toHaveTextContent(state.message);
});
```

## Next.js Router の表示結合テスト
