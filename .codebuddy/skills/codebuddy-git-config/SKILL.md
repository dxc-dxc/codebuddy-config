---
name: codebuddy-git-config
description: 在新设备上部署 CodeBuddy 的 Git 跨平台配置工作流。包含从零开始的 Git 安装、全局配置、GitHub 认证、仓库同步，以及自动生成 Git 学习文档和使用手册。应在用户提到"新设备部署"、"跨平台同步"、"配置 Git"、"新电脑 setup"等场景时触发。涉及凭证操作时引导用户交互完成，不将凭据写入文档。
---

# CodeBuddy Git 跨平台配置 Skill

## 概述

在新设备上自动化完成 CodeBuddy Git 配置的全流程。涵盖环境检测、全局 Git 配置（跨平台兼容）、GitHub 认证引导、配置仓库同步，以及生成完整的 Git 学习文档和使用手册。

## 关键前提：先解决「鸡和蛋」问题

> **问题**：新设备没有 Git → 无法克隆仓库 → 无法获得 skill → 无法配置 Git，形成死循环。
>
> **解决方案**：在已配置的设备上运行 `scripts/export-skill-package.ps1` 打包 skill，
> 通过 **U 盘 / 局域网 / 云盘** 等离线方式传输到新设备，无需依赖 GitHub。

## 工作流决策树

```
用户请求 → 判断是否有 skill → 没有 → Phase 0: 离线导入 skill
                              │          └── 引导用户在旧设备打包，传输到新设备
                              │          └── 引导手动放置 skill 文件
                              ▼
                         有 skill → 判断设备类型 → 分步骤执行
                                                  │
                                   ┌──────────────┼──────────────┐
                                   ▼              ▼              ▼
                              Windows        macOS           Linux
                                   │              │              │
                                   └──────┬───────┘              │
                                          ▼                      ▼
                                    Phase 1: 环境检测与安装
                                    Phase 2: 全局 Git 配置
                                    Phase 3: GitHub 认证（交互引导）
                                    Phase 4: 仓库同步
                                    Phase 5: 生成文档（学习指南 + 使用手册）
                                    Phase 6: 验证清单
```

## 安全约束

1. **绝对不可**在生成的文件中写入任何 Token、密码、私钥内容
2. 涉及凭证的操作必须引导**用户主动交互完成**（提供浏览器链接、命令模板，用户自行填入敏感信息）
3. 生成的文档中所有占位符使用 `<YOUR_TOKEN>` 或 `[YOUR_USERNAME]` 格式
4. 任何需要用户手动复制粘贴的内容，需明确标注 **⚠️ 安全提示**

## 工作流步骤

### Phase 0: Skill 离线导入（无 Git 环境时的入口）

> **适用于**：新设备尚未配置 Git，无法通过 GitHub 克隆仓库获取 skill。

**场景识别**：当用户提出"新设备部署"、"配置 Git"、"新电脑 setup"，且当前项目目录下没有
`.codebuddy/skills/codebuddy-git-config/` 目录时，AI 应判定为"无 skill 环境"，自动进入此阶段。

**AI 输出以下指引**：

#### Step 0.1 在已配置的设备上打包

引导用户在已有 Git 环境的旧设备上执行打包：

```powershell
# 方法 A：运行打包脚本（推荐）
# 该脚本位于 skill 的 scripts/ 目录下
# ⚠️ 使用 Windows PowerShell (powershell.exe)，非 pwsh
powershell -NoProfile -ExecutionPolicy Bypass -File ".codebuddy\skills\codebuddy-git-config\scripts\export-skill-package.ps1" -Destination "D:\USB_DRIVE\codebuddy-setup" -CreateZip

# 方法 B：手动打包（无脚本时）
# 将以下文件夹和文件复制到 U 盘或共享文件夹：
#   .codebuddy/skills/codebuddy-git-config/    ← 整个文件夹
#   CodeBuddy-Git-部署工作流.md                   ← 根文档
```

输出明确指令告诉用户：
1. 打开已配置的电脑，找到项目目录
2. 找到 `scripts/export-skill-package.ps1` 并运行
3. 将生成的包通过 U 盘 / 局域网 / 云盘传回新设备

#### Step 0.2 在新设备上安装 skill

引导用户在新设备上执行：

```
1. 将 codebuddy-git-config 文件夹放入项目根目录的 .codebuddy/skills/ 下
   （如果 .codebuddy/skills/ 不存在，先创建该目录）
2. 将 CodeBuddy-Git-部署工作流.md 放入项目根目录
3. 重启 CodeBuddy（重新加载技能）
4. 输入："帮我配置 Git 跨平台环境" 触发自动部署
```

> ⚠️ **安全说明**：打包脚本已内置安全检查，自动过滤 Token/密钥模式。
> 传输过程中也不涉及任何凭证信息。后续 GitHub 认证将在新设备上交互完成。

**检查确认**：引导用户确认文件放置正确后，继续进入 Phase 1。

---

### Phase 1: 环境检测与 Git 安装

检测当前系统类型和 Git 安装状态：

```powershell
# Windows - 检测 Git
git --version 2>$null
if ($LASTEXITCODE -ne 0) { Write-Output "Git 未安装" }

# macOS/Linux
git --version 2>/dev/null || echo "Git 未安装"
```

**引导用户安装 Git**（根据系统类型提供对应命令）：

| 系统 | 命令 / 方法 |
|------|------------|
| **Windows** | `winget install --id Git.Git --source winget` 或下载 https://git-scm.com/download/win |
| **macOS** | `brew install git` 或下载 https://git-scm.com/download/mac |
| **Linux (Debian)** | `sudo apt install git` |
| **Linux (RHEL)** | `sudo yum install git` |

安装后验证：`git --version`（期望输出 `git version 2.x.x`）

### Phase 2: 全局 Git 配置（跨平台核心）

执行以下命令设置跨平台兼容的全局 Git 配置。

根据检测到的系统类型，输出对应 shell 的命令（Windows 用 PowerShell，其他用 Bash）：

**跨平台核心配置清单**：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `user.name` | `dxc` | GitHub 提交者姓名 |
| `user.email` | `1578330448@qq.com` | GitHub 关联邮箱 |
| `init.defaultBranch` | `main` | 默认分支名 |
| `core.autocrlf` | `true` | 换行符自动转换（Windows 核心） |
| `core.safecrlf` | `warn` | 换行符异常警告 |
| `core.filemode` | `false` | 忽略文件权限（跨平台关键） |
| `core.longpaths` | `true` | 支持超长路径 |
| `core.ignorecase` | `true` | 大小写不敏感 |
| `pull.rebase` | `false` | 默认 merge 策略 |

输出可一键复制的命令块。分 **PowerShell** 和 **Bash** 两种版本。

**全局 .gitignore 配置**：

1. 在 `~/.config/git/ignore` 创建全局忽略文件
2. 内容包含：Windows 系统文件、macOS 系统文件、Linux 系统文件、编辑器临时文件、编译产物
3. 注册全局规则：`git config --global core.excludesFile <path>`

参考 `references/git-deployment-guide.md` 中的完整规则内容。

### Phase 3: GitHub 认证配置（⚠️ 交互引导）

**不要**在文档或命令中直接写入 Token。按以下流程引导用户：

**方式 A：SSH（推荐）** — 引导用户执行：

```bash
# 1. 生成 SSH 密钥（用户自行决定密码）
ssh-keygen -t ed25519 -C "1578330448@qq.com"

# 2. 查看公钥并告知用户复制
cat ~/.ssh/id_ed25519.pub
# Windows: Get-Content ~\.ssh\id_ed25519.pub

# 3. 引导用户打开浏览器添加公钥
#    → https://github.com/settings/keys
#    → 点击 "New SSH Key"，粘贴公钥并保存

# 4. 测试连接
ssh -T git@github.com
#   期望输出：Hi dxc-dxc! You've successfully authenticated...
```

**方式 B：HTTPS + Token** — 引导用户：

1. 打开 https://github.com/settings/tokens → Generate new token (classic)
2. 勾选 `repo` 权限，生成后复制 Token
3. 系统会自动弹出 Git Credential Manager 窗口，粘贴 Token 即可
4. Token 由 GCM 安全存储，下次无需重复输入

**必须包含的安全提示**：
- ⚠️ Token 等同于密码，切勿分享或提交到仓库
- ⚠️ 建议设置 Token 过期时间
- ⚠️ 完成后在浏览器中关闭 Token 页面

### Phase 4: 仓库同步

克隆 `codebuddy-config` 配置仓库：

```bash
# SSH（推荐，配置密钥后可免密码）
git clone git@github.com:dxc-dxc/codebuddy-config.git

# HTTPS
git clone https://github.com/dxc-dxc/codebuddy-config.git
```

验证：
```bash
cd codebuddy-config
git log --oneline          # 应有提交历史
git remote -v              # 显示远程仓库地址
```

### Phase 5: 生成文档

完成配置后，输出两份文档文件路径，供用户审阅后提交：

1. **Git 学习指南** — 生成到 `references/git-learning-guide.md`
   - 目标：帮助用户系统学习 Git
   - 内容结构参见 `references/git-learning-guide.md`

2. **使用手册** — 生成到 `references/user-manual.md`
   - 目标：日常使用指引
   - 内容结构参见 `references/user-manual.md`

3. **部署工作流**（更新） — 更新 `CodeBuddy-Git-部署工作流.md`
   - 已存在于项目根目录，更新内容

### Phase 6: 验证清单

输出以下验证清单供用户执行：

| # | 检查项 | 命令 | 期望结果 |
|---|--------|------|---------|
| 1 | Git 安装 | `git --version` | 版本号 > 2.0 |
| 2 | 全局配置 | `git config --global --list` | 所有配置项已包含 |
| 3 | 全局 .gitignore | `git config --global core.excludesFile` | 输出文件路径 |
| 4 | SSH 认证 | `ssh -T git@github.com` | Successfully authenticated |
| 5 | 仓库克隆 | `ls codebuddy-config/` | 显示 .gitignore 等文件 |
| 6 | 推拉测试 | 修改文件后 `git push` | 推送成功 |

## 资源说明

### references/

此 skill 包含以下参考文档：

- **`git-deployment-guide.md`** — 完整部署操作的参考手册，内含所有命令、配置项和故障排查
- **`git-learning-guide.md`** — Git 学习指南，从基础到进阶的系统教程
- **`user-manual.md`** — 日常使用手册，涵盖提交、同步、回滚等常见场景

修改 `CodeBuddy-Git-部署工作流.md` 时直接引用这些参考文档中的内容。

### 文档输出位置

- skill 参考文档：`.codebuddy/skills/codebuddy-git-config/references/`
- 用户可见文档：项目根目录 `CodeBuddy-Git-部署工作流.md`
