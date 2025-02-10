---
title: "directory"
tags: ["Go"]
---
# 前提
- ディレクトリ構成に正式なものはない
- **「理解しやすく保守しやすいもの」** が原則

# よくあるディレクトリ構成

```
module-root/
├── README.md
├── cmd/  # アプリケーション（コマンド）
│   ├── cmd-tools/
│   │   ├── ...
│   │   ├── main.go
│   ├── web-apps/
│   │   ├── ...
│   │   ├── main.go
│   ├── show.go
├── go.mod
├── go.sum
├── pkg/  # パッケージ
│   ├── customer/
│   │   ├── customer1.go
│   │   ├── customer2.go
│   ├── inventory/
│   │   ├── inventory1.go
│   │   ├── inventory2.go
│   │   ├── inventory3.go
│   ├── package3/
│   │   ├── package3.go
└── main.go
```