#!/bin/bash

# 这个脚本基于原始逻辑重写，但使用了动态仓库地址
# 它会为 release 分支创建一个孤立提交并强制推送

set -e -o pipefail

# 创建一个临时的目录来操作，避免污染工作区根目录
TEMP_RELEASE_DIR="temp_release_dir"
mkdir -p "$TEMP_RELEASE_DIR"
cd "$TEMP_RELEASE_DIR"

git init
git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"

# 使用由工作流传入的 GH_REPO 变量
git remote add origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GH_REPO}.git"

git branch -M release

# 从上层目录复制构建好的文件
echo "Copying database and checksum files..."
cp ../*.db ../*.sha256sum .

git add .

if ! git diff --staged --quiet; then
    git commit -m "Update geosite databases"
    git push -f origin release
    echo "Successfully pushed updates to branch release."
else
    echo "No changes detected for database files, skipping push."
fi

# 返回上层目录并清理临时文件夹
cd ..
rm -rf "$TEMP_RELEASE_DIR"
