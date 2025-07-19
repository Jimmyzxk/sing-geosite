#!/bin/bash

# 这个脚本基于原始逻辑重写，但使用了动态仓库地址
# 它会为 rule-set 和 rule-set-unstable 分支创建孤立提交并强制推送

set -e -o pipefail

function releaseRuleSet() {
    local dirName=$1
    echo "--- Processing branch: ${dirName} ---"
    
    # 检查目录是否存在
    if [ ! -d "$dirName" ]; then
        echo "Directory ${dirName} not found, skipping."
        return
    fi
    
    # 使用 pushd/popd 安全地进入和离开目录
    pushd "$dirName" > /dev/null
    
    git init
    git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git config --local user.name "github-actions[bot]"
    
    # 使用由工作流传入的 GH_REPO 变量，而不是硬编码的地址
    # GH_REPO 的值会是 "Jimmyzxk/sing-geosite"
    git remote add origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GH_REPO}.git"
    
    git branch -M "${dirName}"
    git add .
    
    # 只有在有文件变动时才提交和推送
    if ! git diff --staged --quiet; then
        git commit -m "Update ${dirName}"
        git push -f origin "${dirName}"
        echo "Successfully pushed updates to branch ${dirName}."
    else
        echo "No changes detected in ${dirName}, skipping push."
    fi
    
    popd > /dev/null
}

releaseRuleSet rule-set
releaseRuleSet rule-set-unstable
