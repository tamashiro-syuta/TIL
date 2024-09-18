---
title: "スマホの実機でのデバッグする際のTips"
tags: ["デバッグ", "フロントエンド", "Tips"]
---

# スマホの実機でのデバッグする際のTips

## 個人的最適解
vscodeのポートフォワーディング機能 ✖️ vConsole

### vscodeのポートフォワーディング機能
- ローカルのポートを指定すると、vscode側でURLを発行してくれる機能
- これで、ローカルで動かしている開発中の画面をスマホで確認できる
- 最初の接続では、githubの認証が入る
- ※ URLはパブリックに公開されるので、検証後は解除すること

### vConsole
- READMEを翻訳すると
  > 軽量で拡張可能なモバイルWebページ用のフロントエンド開発ツール。
  > vConsole はフレームワーク不要で、Vue や React、その他のフレームワークのアプリケーションで使用できます。
  > vConsole は、WeChat ミニプログラムの公式デバッグツールです。
- 使い方
  - `npm i -D vconsole` でインストール
  - `const vConsole = new VConsole();` で初期化
    - この状態で、画面にログを確認できるボタンが出現
  - ログの確認後は、`vConsole.destroy();` で解除する必要がある
-  個人的な使い方としては、ログを確認したいコンポーネントで`useEffect`で初期化して、`return`で解除するのが良さそう
    ```tsx
    useEffect(() => {
      // NOTE: コンソールをスマホ上で表示するための設定
      const vConsole = new VConsole();

      return () => { vConsole.destroy();};
    }, []);
    ```
