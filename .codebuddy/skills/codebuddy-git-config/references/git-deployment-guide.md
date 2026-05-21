# Git 跨平台部署指南

> 在新设备上从零开始部署 Git 配置的完整参考手册。
> 本文件是 skill 的内部参考文档，用于指导 AI 生成正确的命令和内容。

---

## 1. 前置准备

### 1.1 Git 安装

| 系统 | 安装方式 |
|------|---------|
| **Windows** | `winget install --id Git.Git --source winget` 或 https://git-scm.com/download/win |
| **macOS** | `brew install git` 或 https://git-scm.com/download/mac |
| **Linux (Debian/Ubuntu)** | `sudo apt update && sudo apt install git` |
| **Linux (RHEL/CentOS)** | `sudo yum install git` |

验证：`git --version`（期望 `git version 2.x.x`）

### 1.2 检测 Shell 类型

为输出正确格式的命令，需检测当前 Shell：

```powershell
# Windows: 检测是否是 PowerShell
$PSVersionTable.PSVersion  # 有输出 = PowerShell

# 或检测 cmd
$null -eq $PSVersionTable  # $true = cmd.exe

# macOS/Linux: 检测 shell
echo $SHELL
# /bin/bash, /bin/zsh 等
```

### 1.3 用户信息

**CodeBuddy 配置仓库的用户信息**：
- 用户名：`dxc`
- 邮箱：`1578330448@qq.com`
- GitHub ID：`dxc-dxc`
- 配置仓库：`https://github.com/dxc-dxc/codebuddy-config.git`

---

## 2. 全局 Git 配置

### 2.1 PowerShell 版

```powershell
git config --global user.name "dxc"
git config --global user.email "1578330448@qq.com"
git config --global init.defaultBranch main
git config --global core.autocrlf true
git config --global core.safecrlf warn
git config --global core.filemode false
git config --global core.longpaths true
git config --global core.ignorecase true
git config --global pull.rebase false
```

### 2.2 Bash 版

```bash
git config --global user.name "dxc" && \
git config --global user.email "1578330448@qq.com" && \
git config --global init.defaultBranch main && \
git config --global core.autocrlf true && \
git config --global core.safecrlf warn && \
git config --global core.filemode false && \
git config --global core.longpaths true && \
git config --global core.ignorecase true && \
git config --global pull.rebase false
```

### 2.3 配置项说明

| 配置项 | 值 | 跨平台原因 |
|--------|-----|-----------|
| `core.autocrlf true` | CRLF → LF（存储）→ CRLF（检出） | Windows 用 CRLF，Unix 用 LF |
| `core.safecrlf warn` | 换行符异常时警告 | 防止二进制文件被破坏 |
| `core.filemode false` | 忽略文件权限变化 | Windows 无 chmod 概念 |
| `core.longpaths true` | 支持超过 260 字符路径 | Windows API 限制 |
| `core.ignorecase true` | 大小写不敏感 | Windows/Mac 文件系统大小写不敏感 |

---

## 3. 全局 .gitignore

### 3.1 创建文件

**PowerShell：**
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.config\git" | Out-Null
Set-Content -Path "$env:USERPROFILE\.config\git\ignore" -Encoding UTF8 -Value @"
# Windows 系统文件
Thumbs.db
Desktop.ini
ehthumbs.db

# macOS 系统文件
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.Spotlight-V100
.Trashes

# Linux 系统文件
*~
.fuse_hidden*

# 编辑器 / IDE
.idea/
*.swp
*.swo
*~
.vscode/settings.json
.vscode/workspace.xml

# 编译产物
*.pyc
*.pyo
*.o
*.obj
*.exe
*.dll
*.so
*.class
*.jar

# 依赖（各平台独立安装）
node_modules/
venv/
.venv/
.venv*/
__pycache__/
"@
```

**Bash：**
```bash
mkdir -p ~/.config/git
cat > ~/.config/git/ignore << 'EOF'
# Windows 系统文件
Thumbs.db
Desktop.ini
ehthumbs.db

# macOS 系统文件
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.Spotlight-V100
.Trashes

# Linux 系统文件
*~
.fuse_hidden*

# 编辑器 / IDE
.idea/
*.swp
*.swo
*~
.vscode/settings.json
.vscode/workspace.xml

# 编译产物
*.pyc
*.pyo
*.o
*.obj
*.exe
*.dll
*.so
*.class
*.jar

# 依赖（各平台独立安装）
node_modules/
venv/
.venv/
.venv*/
__pycache__/
EOF
```

### 3.2 注册全局排除文件

```powershell
# PowerShell
git config --global core.excludesFile "$env:USERPROFILE\.config\git\ignore"
```

```bash
# Bash
git config --global core.excludesFile ~/.config/git/ignore
```

### 3.3 验证

```bash
git config --global core.excludesFile
# 期望输出：文件路径
```

---

## 4. SSH 密钥配置（⚠️ 交互操作）

### 4.1 生成密钥

```bash
# 一路回车，密码可选
ssh-keygen -t ed25519 -C "1578330448@qq.com"
```

### 4.2 查看公钥

```bash
# macOS/Linux
cat ~/.ssh/id_ed25519.pub

# Windows PowerShell
Get-Content ~\.ssh\id_ed25519.pub
```

### 4.3 添加至 GitHub

1. 浏览器打开 https://github.com/settings/keys
2. 点击 **New SSH Key**
3. Title: 填写设备名称（如 "Work Laptop"）
4. Key: 粘贴公钥内容（以 `ssh-ed25519` 开头）
5. 点击 **Add SSH Key**

### 4.4 测试连接

```bash
ssh -T git@github.com
# 期望输出：Hi dxc-dxc! You've successfully authenticated...
```

---

## 5. HTTPS + Token 认证（备用方案）

### 5.1 创建 Token

1. 浏览器打开 https://github.com/settings/tokens
2. 点击 **Generate new token (classic)**
3. Note: `codebuddy-config`
4. Expiration: 选择合适期限（建议 90 天或 No expiration）
5. Scopes: 勾选 **`repo`**（完整仓库控制）
6. 点击 **Generate token**
7. ⚠️ **立即复制 Token**（关闭页面后无法再次查看）

### 5.2 使用 Token

Windows 用户，Git for Windows 自带 **Git Credential Manager (GCM)**，首次推送时自动弹出登录窗口：

```bash
git push -u origin main
# GCM 弹出窗口 → 粘贴 Token 作为密码
# 之后自动记住，无需重复输入
```

非 Windows 用户，配置凭据缓存：
```bash
# 缓存 1 小时
git config --global credential.helper "cache --timeout=3600"
```

---

## 6. 仓库操作

### 6.1 克隆配置仓库

```bash
# SSH（推荐）
git clone git@github.com:dxc-dxc/codebuddy-config.git

# HTTPS（备用）
git clone https://github.com/dxc-dxc/codebuddy-config.git
```

### 6.2 工作区项目发布至 GitHub（Phase 5）

当需要在新的工作区项目（如 `codebuddy环境配置`、`股票分析` 等）上配置 GitHub 同步时，执行以下流程：

#### 6.2.1 检测状态

```bash
cd /path/to/workspace
git rev-parse --git-dir 2>/dev/null && echo "已初始化" || echo "未初始化"
git remote -v 2>/dev/null || echo "无远程仓库"
```

#### 6.2.2 初始化（如未初始化）

```bash
git init
git checkout -b main
```

#### 6.2.3 创建项目 .gitignore

示例（参考 `.codebuddy/skills/codebuddy-git-config/SKILL.md` 的 Phase 5）：

```gitignore
# 操作系统文件
.DS_Store
Thumbs.db

# CodeBuddy 工作文件
.codebuddy/plans/

# 环境变量
.env
.env.local

# IDE
.idea/
.vscode/
*.swp

# 编译
node_modules/
target/
build/
dist/
__pycache__/
```

#### 6.2.4 关联远程仓库

```bash
git remote add origin git@github.com:dxc-dxc/[项目名称].git
```

#### 6.2.5 首次提交并推送

```bash
git add -A
git commit -m "init: 初始化项目"
git push -u origin main
```

#### 6.2.6 验证

```bash
git log --oneline
git remote -v
git branch -r
```

### 6.3 日常推送

```bash
cd codebuddy-config
git status       # 查看变更
git add .        # 暂存
git commit -m "描述改动"  # 提交
git push         # 推送
```

### 6.4 拉取更新

```bash
cd codebuddy-config
git pull         # 拉取最新
```

---

## 7. 自动化同步配置

### 7.1 创建 CodeBuddy Automation

执行完基础配置后，使用 `automation_update` 工具创建每日同步任务：

```bash
# CodeBuddy Automation 会在 Phase 6 中由 AI 自动创建
# 如需手动创建，在 CodeBuddy 中启用 Automations 功能
# 并添加自动化任务，rrule 设为 FREQ=DAILY;BYHOUR=9;BYMINUTE=0
```

### 7.2 手动同步脚本

同步脚本位置：`scripts/sync-config.sh`

```bash
# 同步 codebuddy-config 仓库
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh

# 同步指定工作区项目
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh ~/CodeBuddy/我的项目

# 查看同步日志
cat ~/.codebuddy/sync-config.log
```

### 7.3 多设备同步策略

| 场景 | 操作 |
|------|------|
| 首次部署新设备 | 执行 Phase 0→Phase 4 → 创建自动化 |
| 工作区项目上线 | 执行 Phase 5 → 创建项目自动化 |
| 日常使用 | 自动化每日执行 |
| 紧急同步 | 手动运行 sync-config.sh |
| 迁移/重装 | 重新执行 skill 流程 |

---

## 8. 故障排查

### 8.1 网络问题

```bash
# 检查 GitHub 连通性
ping github.com
curl -I https://github.com

# 检查代理设置
git config --global --get http.proxy
git config --global --get https.proxy

# 取消代理（如果不需要）
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### 8.2 SSH 问题

```bash
# 详细调试
ssh -vT git@github.com

# 检查密钥是否加载
ssh-add -l

# 手动添加密钥
ssh-add ~/.ssh/id_ed25519
```

### 8.3 换行符问题

```bash
# 检查设置
git config core.autocrlf

# 重置换行符
git add --renormalize .
git commit -m "规范化换行符"
```

### 8.4 文件取消追踪

```bash
# 移除已追踪但应忽略的文件（保留本地副本）
git rm --cached <file>
echo "<file>" >> .gitignore
git commit -m "移除 <file> 并加入忽略"
```

### 8.5 全局 skill 部署

将 skill 从项目级安装到全局目录，使其在所有项目中可用：

```bash
# 检测全局目录是否存在
ls ~/.codebuddy/skills/codebuddy-git-config/SKILL.md 2>/dev/null && echo "已部署" || echo "未部署"

# 从项目级复制到全局
cp -R .codebuddy/skills/codebuddy-git-config ~/.codebuddy/skills/codebuddy-git-config

# 验证
ls ~/.codebuddy/skills/codebuddy-git-config/
# 输出：SKILL.md  references/  scripts/

# 更新全局 skill（当仓库有更新时）
cd ~/CodeBuddy/codebuddy-config
git pull origin main
cp -R .codebuddy/skills/codebuddy-git-config ~/.codebuddy/skills/codebuddy-git-config
```

### 8.6 自动化同步失败

```bash
# 查看日志
cat ~/.codebuddy/sync-config.log

# 手动触发查看详细错误
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh 2>&1

# 常见原因及解决方法
# - SSH 密钥过期 → 重新 ssh-keygen + 添加到 GitHub
# - 冲突未解决 → git status 查看冲突文件，手动解决
# - 分支不匹配 → git branch --show-current 确认分支正确
