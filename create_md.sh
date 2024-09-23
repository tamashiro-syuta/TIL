#!/bin/bash

# 対話形式でユーザー入力を取得
echo "どの階層にファイルを作成しますか？ \nファイルを作成する1つ上の相対パスを入力してください（例: infrastructure/aws） : "
read file_path

echo "作成するファイル名を入力してください（例: learn_lambda）: "
read file_name

echo "TIL-Viewerで表示するタイトルを入力してください: "
read title

echo "TIL-Viewerで表示するタグをカンマ区切りで入力してください（例: aws, terraform）: "
read tags

mkdir -p $file_path image/$file_path

create_file_path="$file_path/$file_name.md"
touch $create_file_path

# 入力された情報を基にMarkdownファイルを生成
cat <<EOF > $create_file_path
---
title: "$title"
tags: [$tags]
---

EOF

# 成功メッセージを表示
echo "以下のリソースを作成しました。"
echo "  - Markdownファイル: $create_file_path"
echo "  - 画像ディレクトリ: image/$file_path"
