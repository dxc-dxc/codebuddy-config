# CodeBuddy Git 跨平台配置部署工作流

> **用途**：在新设备上部署 CodeBuddy 的 Git 配置，实现跨平台项目管理同步。
> **AI 自动部署**：在 CodeBuddy 中加载 `codebuddy-git-config` skill 即可自动执行以下流程。
> **适用场景**：Windows / macOS / Linux 多设备共用同一套 Git 配置。
>
> ⚠️ **先决条件提醒**：新设备可能尚未配置 Git，无法通过 GitHub 拉取此文档。
> **请跳转 → [〇、离线安装（无 Git 环境）](#〇离线安装无-git-环境)** 作为入口。

---

## 目录

- [〇、离线安装（无 Git 环境）](#〇离线安装无-git-环境)
- [一、Skill 使用方式](#一skill-使用方式)
- [二、前置准备](#二前置准备)
- [三、全局 Git 配置（跨平台核心）](#三全局-git-配置跨平台核心)
- [四、全局 .gitignore（所有项目通用）](#四全局-gitignore所有项目通用)
- [五、GitHub 认证配置](#五github-认证配置)
- [六、克隆配置仓库](#六克隆配置仓库)
- [七、验证清单](#七验证清单)
- [八、日常使用流程](#八日常使用流程)
- [九、故障排查](#九故障排查)
- [十、参考文档](#十参考文档)

---

## 〇、离线安装（无 Git 环境）

> **适用场景**：新设备尚未安装/配置 Git，无法通过 GitHub 克隆仓库。
> **解决「鸡和蛋」问题**：通过 U 盘 / 局域网 / 云盘传输 skill 文件，绕过 GitHub 依赖。

### 〇.1 在已配置的设备上打包

在有 Git 环境的旧设备上，进入项目目录运行打包脚本：

```powershell
# 推荐：执行打包脚本（自动检查凭证安全）
# ⚠️ 使用 Windows PowerShell (powershell.exe)，非 PowerShell Core (pwsh)
powershell -NoProfile -ExecutionPolicy Bypass -File ".codebuddy\skills\codebuddy-git-config\scripts\export-skill-package.ps1" -CreateZip

# 脚本会在桌面生成 codebuddy-skill-package 文件夹 + ZIP 包
```

**也可手动复制以下内容到 U 盘：**

| 来源路径 | 说明 |
|---------|------|
| `.codebuddy/skills/codebuddy-git-config/` | **必选** — AI 工作流定义 + 参考文档 |
| `CodeBuddy-Git-部署工作流.md` | **推荐** — 本部署文档（你正在看的就是） |

### 〇.2 传输方式

| 方式 | 操作 |
|------|------|
| **U 盘** | 复制文件夹到 U 盘，插入新设备 |
| **局域网共享** | SMB 共享 / `python -m http.server` 临时 HTTP 服务器 |
| **云盘** | 上传 ZIP 包到百度网盘 / OneDrive / 阿里云盘等，在新设备下载 |
| **IM 传输** | 通过微信/QQ 文件助手发送 ZIP 包（适合小包） |

### 〇.3 在新设备上安装

**Step 1**：将 skill 目录放入正确位置

```
项目目录/
├── .codebuddy/                    ← 如不存在则手动创建
│   └── skills/
│       └── codebuddy-git-config/  ← 将整个文件夹复制到此
│           ├── SKILL.md
│           ├── scripts/
│           ├── references/
├── CodeBuddy-Git-部署工作流.md     ← 复制到项目根目录
```

> 📁 如果 `.codebuddy/skills/` 目录不存在，请手动逐级创建。

**Step 2**：重启 CodeBuddy

- 关闭并重新打开 VS Code / CodeBuddy IDE
- 或执行命令面板（`Ctrl+Shift+P`）→ `Developer: Reload Window`

**Step 3**：触发自动部署

在 CodeBuddy 聊天框中输入：

> "帮我在新设备上配置 Git 跨平台环境"

AI 将自动加载此 skill，按以下章节顺序执行全流程部署。

### 〇.4 打包脚本说明

项目中已包含自动打包脚本：`.codebuddy/skills/codebuddy-git-config/scripts/export-skill-package.ps1`

该脚本功能：
- ✅ 自动收集 skill 全部文件
- ✅ **内置安全检查** — 扫描并阻止 Token、SSH 私钥等凭证泄露
- ✅ 可选生成 ZIP 压缩包 — 方便云盘/IM 传输
- ✅ 自动生成安装说明（README.txt）

> ⚠️ **安全承诺**：所有 GitHub 认证操作（SSH 密钥生成、Token 创建）均在新设备上交互完成，
> 打包脚本和传输过程**不涉及任何凭证信息**。

---

## 一、Skill 使用方式

### 1.1 在新设备上运行

在 CodeBuddy 中输入以下任一指令，即可触发自动部署：

> "在新电脑上部署 CodeBuddy Git 配置"
> "帮我配置跨平台 Git 同步"
> "加载 git-config skill 部署新设备"

AI 将自动执行：
1. 检测当前系统类型
2. 引导安装 Git（如未安装）
3. 一键配置全局 Git 设置
4. 引导 GitHub 认证（交互式，不泄露凭据）
5. 克隆 `codebuddy-config` 仓库
6. 生成 Git 学习指南和使用手册

### 1.2 Skill 文件位置

```
.codebuddy/skills/codebuddy-git-config/
├── SKILL.md                              # AI 工作流定义
├── scripts/
│   └── export-skill-package.ps1          # 离线打包脚本 ⭐
└── references/
    ├── git-deployment-guide.md           # 完整部署参考
    ├── git-learning-guide.md             # Git 系统学习指南
    └── user-manual.md                    # 日常使用手册
```

---

## 二、前置准备

### 2.1 安装 Git

| 系统 | 安装方式 |
|------|---------|
| **Windows** | `winget install --id Git.Git --source winget` 或 https://git-scm.com/download/win |
| **macOS** | `brew install git` 或 https://git-scm.com/download/mac |
| **Linux** | `sudo apt install git` 或 `sudo yum install git` |

验证：`git --version`（期望 `git version 2.x.x`）

---

## 三、全局 Git 配置（跨平台核心）

### PowerShell 版

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

### Bash 版

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

### 配置项说明

| 配置 | 值 | 跨平台原因 |
|------|-----|-----------|
| `core.autocrlf true` | CRLF → LF 存储 → CRLF 检出 | Windows/Unix 换行符差异 |
| `core.safecrlf warn` | 换行符异常警告 | 防止二进制文件损坏 |
| `core.filemode false` | 忽略文件权限 | Windows 无 chmod |
| `core.longpaths true` | 支持超长路径 | Windows 260 字符限制 |
| `core.ignorecase true` | 大小写不敏感 | Win/Mac 文件系统特性 |

### 验证

```bash
git config --global --list
```

---

## 四、全局 .gitignore（所有项目通用）

### 创建文件

**PowerShell：**
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.config\git" | Out-Null
Set-Content -Path "$env:USERPROFILE\.config\git\ignore" -Encoding UTF8 -Value @"
# Windows
Thumbs.db
Desktop.ini
ehthumbs.db

# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.Spotlight-V100
.Trashes

# Linux
*~
.fuse_hidden*

# Editor / IDE
.idea/
*.swp
*.swo
*~
.vscode/settings.json
.vscode/workspace.xml

# Compiled
*.pyc
*.pyo
*.o
*.obj
*.exe
*.dll
*.so
*.class
*.jar

# Dependencies
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
# Windows
Thumbs.db
Desktop.ini
ehthumbs.db

# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.Spotlight-V100
.Trashes

# Linux
*~
.fuse_hidden*

# Editor / IDE
.idea/
*.swp
*.swo
*~
.vscode/settings.json
.vscode/workspace.xml

# Compiled
*.pyc
*.pyo
*.o
*.obj
*.exe
*.dll
*.so
*.class
*.jar

# Dependencies
node_modules/
venv/
.venv/
.venv*/
__pycache__/
EOF
```

### 注册

```bash
# PowerShell
git config --global core.excludesFile "$env:USERPROFILE\.config\git\ignore"

# Bash
git config --global core.excludesFile ~/.config/git/ignore
```

---

## 五、GitHub 认证配置

> ⚠️ **安全提示**：以下步骤涉及敏感凭据，请**亲自操作**，不要在文档中留存 Token。

### 方式 A：SSH（推荐）

```bash
# 1. 生成密钥
ssh-keygen -t ed25519 -C "1578330448@qq.com"

# 2. 查看公钥并复制
# macOS/Linux: cat ~/.ssh/id_ed25519.pub
# Windows PowerShell: Get-Content ~\.ssh\id_ed25519.pub

# 3. 浏览器打开 https://github.com/settings/keys
#    → "New SSH Key" → 粘贴公钥 → 保存

# 4. 测试连接
ssh -T git@github.com
# 期望输出：Hi dxc-dxc! You've successfully authenticated...
```

### 方式 B：HTTPS + Token

1. 浏览器打开 https://github.com/settings/tokens
2. **Generate new token (classic)** → Note: `codebuddy-config`
3. 勾选 `repo` → 生成 → ⚠️ **立即复制**
4. 首次 `git push` 时 GCM 弹出窗口，粘贴 Token

> ⚠️ Token 等同于密码，切勿分享。建议设置过期时间。

---

## 六、克隆配置仓库

```bash
# SSH（推荐）
git clone git@github.com:dxc-dxc/codebuddy-config.git

# HTTPS（备用）
git clone https://github.com/dxc-dxc/codebuddy-config.git
```

---

## 七、验证清单

| # | 检查项 | 命令 | 期望结果 |
|---|--------|------|---------|
| 1 | Git 安装 | `git --version` | 版本号 > 2.0 |
| 2 | 全局配置 | `git config --global --list` | 全部配置项 |
| 3 | 全局 .gitignore | `git config --global core.excludesFile` | 输出路径 |
| 4 | SSH 认证 | `ssh -T git@github.com` | Successfully authenticated |
| 5 | 仓库克隆 | `ls codebuddy-config/` | 显示 .gitignore |
| 6 | 推拉测试 | 修改文件后 `git push` | 推送成功 |

---

## 八、日常使用流程

### 8.1 提交推送

```bash
git pull           # 先拉取
# 修改文件...
git status         # 查看变更
git add .          # 暂存
git commit -m "说明"  # 提交
git push           # 推送
```

### 8.2 换设备同步

```bash
cd codebuddy-config && git pull
```

### 8.3 黄金法则

1. **先 pull 再干活** — 避免冲突
2. **干完活就 push** — 防止丢失
3. **只传源码，不传依赖** — 环境各平台独立安装
4. **配置模板化** — 敏感信息用 `.env.example`

---

## 九、故障排查

### 9.1 网络问题

```bash
ping github.com
git config --global --get http.proxy
git config --global --unset http.proxy   # 取消代理
```

### 9.2 SSH 问题

```bash
ssh -vT git@github.com           # 详细调试
ssh-add -l                       # 检查密钥
ssh-add ~/.ssh/id_ed25519        # 手动添加
```

### 9.3 换行符异常

```bash
git config core.autocrlf
git add --renormalize .
git commit -m "规范化换行符"
```

### 9.4 误提交文件

```bash
git rm --cached <file>
echo "<file>" >> .gitignore
git commit -m "移除 <file> 加入忽略"
```

---

## 十、参考文档

本仓库还包含以下文档（位于 `.codebuddy/skills/codebuddy-git-config/references/`）：

| 文档 | 说明 |
|------|------|
| `git-deployment-guide.md` | 完整部署参考手册（含所有命令和故障排查） |
| `git-learning-guide.md` | Git 系统学习指南（基础→进阶） |
| `user-manual.md` | 日常使用手册（含速查表和安全指南） |

> **文档版本**：v2.0 · 更新于 2026-05-21
> **仓库地址**：https://github.com/dxc-dxc/codebuddy-config
> **AI 自动部署**：在 CodeBuddy 中触发 `codebuddy-git-config` skill 即可
