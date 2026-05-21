#!/bin/bash
# ======================================
# CodeBuddy Git 自动同步脚本
# 用途：自动拉取远程更新 + 推送本地修改
# 支持：macOS / Linux
# 用法：
#   bash sync-config.sh                          # 同步 codebuddy-config 仓库
#   bash sync-config.sh /path/to/project         # 同步指定工作区项目
#   bash sync-config.sh ~/CodeBuddy/我的项目     # 示例：同步任意工作区
# ======================================

set -e

# 参数：如果不传参，默认同步 codebuddy-config 仓库
TARGET_DIR="${1:-$HOME/CodeBuddy/codebuddy-config}"
LOG_FILE="$HOME/.codebuddy/sync-config.log"
PROJECT_NAME=$(basename "$TARGET_DIR")

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ====== 开始同步: $PROJECT_NAME =====" >> "$LOG_FILE"

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 目录不存在: $TARGET_DIR" >> "$LOG_FILE"
    exit 1
fi

cd "$TARGET_DIR"

# 检查是否是 git 仓库
if [ ! -d ".git" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 不是 Git 仓库: $TARGET_DIR" >> "$LOG_FILE"
    exit 1
fi

# 检查是否有远程仓库
REMOTE=$(git remote 2>/dev/null)
if [ -z "$REMOTE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ 无远程仓库，跳过同步: $TARGET_DIR" >> "$LOG_FILE"
    echo "请先设置远程仓库: git remote add origin <url>" >> "$LOG_FILE"
    exit 1
fi

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔄 分支: $CURRENT_BRANCH，拉取远程更新..." >> "$LOG_FILE"

# Step 1: 拉取远程最新代码
git pull origin "$CURRENT_BRANCH" 2>&1 >> "$LOG_FILE"
PULL_EXIT=$?

if [ $PULL_EXIT -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ 拉取失败，可能存在冲突，跳过推送" >> "$LOG_FILE"
    exit 1
fi

# Step 2: 检查是否有本地未提交的变更
if git status --porcelain | grep -q .; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📦 检测到本地变更，准备提交..." >> "$LOG_FILE"

    # 暂存所有变更
    git add -A

    # 用日期生成提交信息
    COMMIT_MSG="auto-sync $PROJECT_NAME: $(date '+%Y-%m-%d %H:%M')"

    git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

    # Step 3: 推送
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📤 推送到远程 ($CURRENT_BRANCH)..." >> "$LOG_FILE"
    git push origin "$CURRENT_BRANCH" 2>&1 >> "$LOG_FILE"
    PUSH_EXIT=$?

    if [ $PUSH_EXIT -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 同步成功: $COMMIT_MSG" >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ 推送失败" >> "$LOG_FILE"
        exit 1
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 无本地变更，同步完成" >> "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ====== 同步结束: $PROJECT_NAME ======\n" >> "$LOG_FILE"
