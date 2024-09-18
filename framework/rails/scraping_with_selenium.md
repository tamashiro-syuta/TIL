---
title: "Seleniumを使ったスクレイピング"
tags: ["Selenium", "Rails"]
---

# Seleniumを使ったスクレイピング

## gem
- [selenium-webdriver](https://rubygems.org/gems/selenium-webdriver)
- [webdrivers](https://rubygems.org/gems/webdrivers)

## `bundle install`後に実行すると以下のエラー
- なんかchromeがなくて開けないぞって言われてるっぽい
  - コンテナからブラウザにアクセスできる必要がありそう

```bash
Webdrivers::BrowserNotFound: Failed to determine Chrome binary location.
from /usr/local/bundle/gems/webdrivers-5.2.0/lib/webdrivers/chrome_finder.rb:21:in `location'
```

## gem `webdrivers` を削除
```bash
`webrdrivers` が読み込まれると、Docker環境ではなくローカル（＝ホスト）側にドライバーを探しにいってしまうらしく、ローカル側ではドライバーが見つからないため、Webdrivers::BrowserNotFoundが発生していたようです。
```

> selenium-webdriverの主な役割は、WebDriverと通信するためのAPIを提供することです。WebDriverが含まれているわけではないので、操作したいブラウザとそのブラウザ用のWebDriverを別途インストールする必要があります。

## どうやってコンテナにブラウザをインストールするの???
https://qiita.com/kawamou/items/43cf670e19b2a29b674e によると
> arm64向けのChromeバイナリは現在提供されていないため、AppleシリコンMacにてChromeを動かすためにはx86向けのイメージ上で、x86向けのChromeを動かす必要があります。
らしい。

ほうほう。なるほど。
ん？？

> ところが（Docker Desktop for Macにおける）QEMU(CPU等をエミュレートできる仕組み)は飽くまでベストエフォート動作であるため時に不具合が発生します。
> 今回もQEMU起因でChromeがうまく立ち上がらないことがエラー原因になっているようです。

ほうほう。なるほど。なるほど。

> 解決策
> 4.16以降のDocker Desktop for MacにはQEMUの代わりにRosettaでエミュレートする機能が追加されています。
> こちらをONにすることで正常に実行できました！

https://dev.to/docker/unable-to-locate-package-google-chrome-stable-b62
によると、armが対応していないので、amd64用のイメージでビルドすれば動くよ〜ってことらしい。

## 参考資料
https://osusublog.net/?p=1432
