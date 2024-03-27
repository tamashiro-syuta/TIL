# MUIでメールリンクを作成する方法

## 実装方法
```tsx
import React from 'react';
import { Link } from '@mui/material';

<Link href="mailto:ここにメールアドレスを記載">Send Email</Link>
```

## 生成されるHTML
```html
<a class="muiのclassたち(長いので省略)" href="mailto:ここにメールアドレスを記載">
  Send Email
</a>
```

[MDN](https://developer.mozilla.org/ja/docs/Web/HTML/Element/a#href) による`href`属性の説明

> ハイパーリンクが指す先の URL です。リンクは HTTP ベースの URL に限定されません。ブラウザーが対応するあらゆるプロトコルを使用することができます。

> ページの節を示すフラグメント URL
> - テキストフラグメントで指定されたテキストの部分
> - メディアファイルの一部を示すメディアフラグメント
> - 電話番号を示す tel: URL
> - メールアドレスを示す mailto: URL
> - SMS テキストメッセージを示す sms: URL
> - ウェブブラウザーがその他の URL スキームに対応していない可能性がある場合、ウェブサイトは > registerProtocolHandler() を使用することができます。

MUIの`Link`コンポーネントは`aタグ`をラップしたものだから、aタグに使えるhrefが使えて、hrefは電話番号とかSMSとかのリンクにするprefixがあって便利だねって話だった。
