# `TextFeild`に`useRef`を使う際の注意点

## `ref`ではなく、`inputRef`属性に useRef を設定

`TestField`に対して、useRef を使いたい時は、input タグの情報(入力内容など)を取得したいことがほとんどだと思う。

そのため、`ref`ではなく、`inputRef`属性に useRef を設定する必要がある。

|   props    |               対象               |
| :--------: | :------------------------------: |
|   `ref`    | `TextField`全体(つまり div タグ) |
| `inputRef` | `TextField`の中にある`input`タグ |

```tsx
const ConfirmationToPersonInCharge = () => {
  const dummyRef = useRef<HTMLInputElement>(null);
  const textFieldRef = useRef<HTMLInputElement>(null);

  const onClick = () => {
    console.log(dummyRef.current);
    console.log(textFieldRef.current);
  };

  return (
    <>
      <TextField ref={dummyRef} inputRef={textFieldRef} />
      <Button onClick={onClick}>Click</Button>
    </>
  );
};
```

上のコンポーネントで、`onClick`が発火すると以下の結果が得られる。

```html
# console.log(dummyRef.current);
<div class="MuiFormControl-root MuiTextField-root css-1u3bzj6-MuiFormControl-root-MuiTextField-root">
  <div class="MuiInputBase-root MuiOutlinedInput-root MuiInputBase-colorPrimary MuiInputBase-formControl css-1hgf8cx-MuiInputBase-root-MuiOutlinedInput-root">
    <input aria-invalid="false" id=":r3:" type="text" class="MuiInputBase-input MuiOutlinedInput-input css-1t8l2tu-MuiInputBase-input-MuiOutlinedInput-input" value="">
    <fieldset aria-hidden="true" class="MuiOutlinedInput-notchedOutline css-1d3z3hw-MuiOutlinedInput-notchedOutline">
      <legend class="css-ihdtdm"><span class="notranslate">​</span></legend>
    </fieldset>
  </div>
</div>

# console.log(textFieldRef.current);
<input aria-invalid="false" id=":r3:" type="text" class="MuiInputBase-input MuiOutlinedInput-input css-1t8l2tu-MuiInputBase-input-MuiOutlinedInput-input" value="">
```
