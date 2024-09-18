---
title: "MUI の Stepper で Server Actions を実行する際の注意点"
tags: ["MUI", "Nextjs", "Tips"]
---

# 🚨 MUI の Stepper で Server Actions を実行する際の注意点

mui の stepper では、active ではない step のコンポーネントはレンダリングされないため、`FormData`の値として判別できない。

❌ `display: 'none'` は判別できる。けど、送信したい値を`display: 'none'` で隠すのは不要にレンダリングすることになって良くない。

⭕️ 送信時に、`formData.append("attribute", value);`のようにすれば、できる。

🚨 ※ 破壊的変更にはなるので、注意。

```tsx
'use client';

const Page = () => {
  // NOTE: formData に値を追加
  const addAttributesToFormData = (formData: FormData) => {
    formData.append("attribute1", value1);
    formData.append("attribute2", value2);
  };

  const onSubmit = async (formData: FormData) => {
    // NOTE: formData に値を追加
    addAttributesToFormData(formData);

    // NOTE: server actions を実行
    serverAction(formData);
  };

  return (
    <Stepper
      component="form"
      action={onSubmit}
      // その他の props
    >
      <Step>
        <StepContent>
          ... // その他のコンポーネント
        </StepContent>
      </Step>

      ... // その他の Step

    </Stepper>
  )
};
```
