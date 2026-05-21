---
name: codebuddy-git-config
description: 在新设备上部署 CodeBuddy 的 Git 跨平台配置工作流。包含从零开始的 Git 安装、全局配置、GitHub 认证、仓库同步、自动化 daily sync 配置、全局 skill 部署，以及自动生成 Git 学习文档和使用手册。应在用户提到"新设备部署"、"跨平台同步"、"配置 Git"、"新电脑 setup"、"自动同步"、"全局 skill"等场景时触发。涉及凭证操作时引导用户交互完成，不将凭据写入文档。
---

# CodeBuddy Git 跨平台配置 Skill

## 概述

在新设备上自动化完成 CodeBuddy Git 配置的全流程。涵盖环境检测、全局 Git 配置（跨平台兼容）、GitHub 认证引导、**工作区项目初始化并推送至 GitHub**、配置仓库同步、**skill 全局部署**，以及生成完整的 Git 学习文档和使用手册。

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
                                    Phase 4: 克隆配置仓库（codebuddy-config）
                                    Phase 5: 工作区项目发布至 GitHub
                                    Phase 6: 配置自动化同步
                                    Phase 7: 生成文档（学习指南 + 使用手册）
                                    Phase 8: 验证清单
                                    Phase 9: 全局 skill 部署（可选）
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

**跨平台核心配置清单**（此处为默认示例值，执行时请询问用户的实际姓名和邮箱）：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `user.name` | `dxc` | GitHub 提交者姓名 |
| `user.email` | `1578330448@qq.com` | GitHub 关联邮箱 |
| `init.defaultBranch` | `main` | 默认分支名 |
| `core.autocrlf` | `input`（macOS/Linux）/ `true`（Windows） | 换行符自动转换 |
| `core.safecrlf` | `warn` | 换行符异常警告 |
| `core.filemode` | `false` | 忽略文件权限（跨平台关键） |
| `core.longpaths` | `true` | 支持超长路径 |
| `core.ignorecase` | `true` | 大小写不敏感 |
| `pull.rebase` | `false` | 默认 merge 策略 |

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
ssh-keygen -t ed25519 -C "user@example.com"

# 2. 查看公钥并告知用户复制
cat ~/.ssh/id_ed25519.pub
# Windows: Get-Content ~\.ssh\id_ed25519.pub

# 3. 引导用户打开浏览器添加公钥
#    → https://github.com/settings/keys
#    → 点击 "New SSH Key"，粘贴公钥并保存

# 4. 测试连接
ssh -T git@github.com
#   期望输出：Hi username! You've successfully authenticated...
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

### Phase 4: 克隆配置仓库（codebuddy-config）

> **目标**：将 `codebuddy-config` 配置仓库克隆到本地，该仓库包含跨设备共享的 skill、脚本和配置。

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

> 💡 此仓库后续用作自动化同步的目标（详见 Phase 6）。

### Phase 5: 工作区项目发布至 GitHub

> **目标**：将当前 CodeBuddy 工作区的项目（例如 `codebuddy环境配置`）初始化为 git 仓库，推送到 GitHub，并配置 AI 自动同步。
>
> **触发场景**：当 AI 检测到当前工作区是 git 仓库但无远程地址，或用户主动要求"将此项目同步到 GitHub"时，自动进入此阶段。
>
> **适用对象**：任意 CodeBuddy 工作区项目（不限于 codebuddy-config）。

#### 5.1 检测工作区 Git 状态

执行以下检测：

```bash
cd /path/to/workspace

# 检测是否已是 git 仓库
git rev-parse --git-dir 2>/dev/null && echo "已初始化" || echo "未初始化"

# 检测是否有远程仓库
git remote -v 2>/dev/null || echo "无远程仓库"

# 检测分支名
git branch --show-current

# 检测暂存/未暂存的变更
git status --short
```

#### 5.2 初始化 Git 仓库（如未初始化）

如果工作区尚未初始化，执行：

```bash
git init
git checkout -b main
```

#### 5.3 创建项目专属 .gitignore

根据项目类型生成 `.gitignore`，合并全局规则与项目特有规则：

**通用推荐（适用于任何工作区）：**

```
# 全局规则已在 ~/.config/git/ignore 中生效
# 此处只放本项目特有的忽略规则

# 操作系统文件
.DS_Store
Thumbs.db

# CodeBuddy 工作文件（AI 中间产物，不提交）
.codebuddy/plans/

# 环境变量/密钥
.env
.env.local
.env.*.local

# IDE 设置
.idea/
.vscode/
*.swp
*.swo
*~

# 编译/构建产物
node_modules/
target/
build/
dist/
__pycache__/
*.pyc
*.pyo
```

#### 5.4 创建 GitHub 仓库（引导用户操作）

> ⚠️ 此步骤需要用户交互，AI 不能自动创建 GitHub 仓库。

**引导用户在浏览器中创建仓库：**

```markdown
请按以下步骤在 GitHub 上创建一个新仓库：

1. 打开 https://github.com/new
2. Repository name 填写：`[项目名称]`（例如 `codebuddy环境配置`）
3. Description（可选）：添加简短描述
4. 选择 **Public** 或 **Private**
5. ⚠️ **不要**勾选 "Initialize this repository with" 中的任何选项（保持空仓库）
6. 点击 **"Create repository"**

创建完成后，复制 SSH 地址（格式：git@github.com:dxc-dxc/xxx.git）粘贴给我。
```

#### 5.5 关联远程仓库

用户提供 SSH 地址后，执行：

```bash
git remote add origin git@github.com:dxc-dxc/[项目名称].git
```

#### 5.6 首次提交并推送

```bash
# 暂存所有文件
git add -A

# 首次提交
git commit -m "init: 初始化项目"

# 推送到 GitHub
git push -u origin main
```

#### 5.7 验证推送结果

```bash
git log --oneline
git remote -v
# 检查远程分支
git branch -r
```

#### 5.8 配置工作区自动同步

执行 Phase 6 的第 6.2 节，为当前工作区创建独立的自动化同步任务。

### Phase 6: 配置自动化同步（CodeBuddy Automation）

> **目标**：创建 CodeBuddy Automation 任务，实现配置仓库和/或工作区项目的每日自动同步。
> **适用场景**：多设备跨平台使用时，无需手动执行 git pull/push，由 AI 自动完成。

#### 6.1 配置仓库（codebuddy-config）自动同步

通过 `automation_update` 工具创建以下自动化：

| 属性 | 值 |
|------|-----|
| **name** | `codebuddy-config-auto-sync` |
| **scheduleType** | `recurring` |
| **rrule** | `FREQ=DAILY;BYHOUR=9;BYMINUTE=0`（每日 9:00 执行） |
| **status** | `ACTIVE` |
| **cwds** | `~/CodeBuddy/codebuddy-config`（根据实际路径调整） |

自动化 prompt 内容：

```
执行 codebuddy-config 配置仓库的自动同步。步骤如下：
1. cd 到 codebuddy-config 目录
2. git pull origin main（拉取远程最新配置）
3. 检查是否有本地未提交变更（git status --porcelain）
4. 如果有变更，执行 git add -A、git commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M')"、git push origin main
5. 记录同步结果到日志文件 ~/.codebuddy/sync-config.log

如果遇到冲突或推送失败，在回复中报告错误信息。
```

#### 6.2 工作区项目自动同步

执行完 Phase 5 后，视需要为工作区项目创建自动化：

| 属性 | 值 |
|------|-----|
| **name** | `[项目名]-auto-sync` |
| **scheduleType** | `recurring` |
| **rrule** | `FREQ=DAILY;BYHOUR=9;BYMINUTE=30`（每日 9:30，与配置仓库错开） |
| **status** | `ACTIVE` |
| **cwds** | 工作区项目实际路径 |

自动化 prompt 示例：

```
执行 [项目名] 工作区的自动同步。步骤如下：
1. cd 到项目目录
2. git pull origin main（拉取远程更新）
3. 检查是否有本地未提交变更（git status --porcelain）
4. 如果有变更，执行 git add -A、git commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M')"、git push origin main

如果遇到冲突或推送失败，在回复中报告错误信息。
```

#### 6.3 同步脚本（备用）

`scripts/sync-config.sh` 提供了独立的 shell 同步脚本，可用于：

- **手动触发**：`bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh`
- **cron 定时**：在无法使用 CodeBuddy Automation 的环境下，通过系统 cron 调用
- **故障排查**：脚本会产生日志 `~/.codebuddy/sync-config.log`，供排查同步问题

#### 6.4 多设备同步策略

| 场景 | 操作 |
|------|------|
| **首次部署新设备** | 执行 Phase 0→Phase 4 完成基础配置 → Phase 6 创建自动化 |
| **工作区项目上线** | 执行 Phase 5 推送至 GitHub → Phase 6.2 创建项目自动化 |
| **日常使用** | 自动化每日 9:00/9:30 执行，AI 自动完成 syncing |
| **紧急同步** | 手动运行 `scripts/sync-config.sh` 或直接 git push |
| **迁移/重装** | 重新执行整套 skill 流程 |

#### 6.5 自动化验证

创建自动化后，输出以下验证信息：

```
✅ 自动同步已配置
   ┌─ 配置仓库（codebuddy-config）：每日 9:00
   ├─ [项目名]（工作区）：每日 9:30
   ├─ 日志：~/.codebuddy/sync-config.log
   └─ 下次执行时间：[下次执行时间]
```

### Phase 7: 生成文档

完成配置后，输出两份文档文件路径，供用户审阅后提交：

1. **Git 学习指南** — 生成到 `references/git-learning-guide.md`
   - 目标：帮助用户系统学习 Git
   - 内容结构参见 `references/git-learning-guide.md`
   - **新增内容**：工作区项目发布流程、自动化同步说明

2. **使用手册** — 生成到 `references/user-manual.md`
   - 目标：日常使用指引
   - 内容结构参见 `references/user-manual.md`
   - **新增内容**：如何让 AI 帮你推送项目到 GitHub

3. **部署工作流**（更新） — 更新 `CodeBuddy-Git-部署工作流.md`
   - 追加 Phase 5（工作区项目发布至 GitHub）和 Phase 6（自动化同步）的说明
   - 追加 Phase 9（全局 skill 部署）的说明

### Phase 8: 验证清单

输出以下验证清单供用户执行：

| # | 阶段 | 检查项 | 命令 | 期望结果 |
|---|------|--------|------|---------|
| 1 | 基础 | Git 安装 | `git --version` | 版本号 > 2.0 |
| 2 | 基础 | 全局配置 | `git config --global --list` | 所有配置项已包含 |
| 3 | 基础 | 全局 .gitignore | `git config --global core.excludesFile` | 输出文件路径 |
| 4 | 认证 | SSH 认证 | `ssh -T git@github.com` | Successfully authenticated |
| 5 | 配置仓库 | 仓库克隆 | `ls ~/CodeBuddy/codebuddy-config/` | 显示 .gitignore 等文件 |
| 6 | 工作区 | GitHub 远程 | `git remote -v`（工作区目录） | 显示 push/fetch 地址 |
| 7 | 工作区 | 推拉测试 | 修改文件后 `git push` | 推送成功 |
| 8 | 自动化 | 自动化创建 | 查看 CodeBuddy → Automations | 显示同步任务列表 |
| 9 | 自动化 | 首次执行 | 等待或手动触发 | 同步成功无错误 |
| 10 | 全局部署 | skill 全局安装 | `ls ~/.codebuddy/skills/codebuddy-git-config/` | 显示 SKILL.md 等文件 |

### Phase 9: 全局 skill 部署（可选）

> **目标**：将 `codebuddy-git-config` skill 从项目级别同步至 CodeBuddy **全局 skills 目录**，使其在所有项目中可用。
>
> **全局目录位置**：`~/.codebuddy/skills/`

#### 9.1 检测当前部署状态

```bash
# 检测全局目录是否存在
ls ~/.codebuddy/skills/codebuddy-git-config/SKILL.md 2>/dev/null && echo "已部署至全局" || echo "未部署至全局"
```

#### 9.2 同步至全局目录

```bash
# 确定 skill 源路径（项目级别）
SKILL_SRC=".codebuddy/skills/codebuddy-git-config"

# 如果当前工作区未找到，尝试从 codebuddy-config 仓库获取
if [ ! -d "$SKILL_SRC" ]; then
    SKILL_SRC="$HOME/CodeBuddy/codebuddy-config/.codebuddy/skills/codebuddy-git-config"
fi

# 复制到全局目录
cp -R "$SKILL_SRC" ~/.codebuddy/skills/codebuddy-git-config
```

**Windows PowerShell 版本：**
```powershell
# 源路径（项目级或配置仓库）
$SkillSrc = ".codebuddy\skills\codebuddy-git-config"
if (-not (Test-Path $SkillSrc)) {
    $SkillSrc = "$env:USERPROFILE\CodeBuddy\codebuddy-config\.codebuddy\skills\codebuddy-git-config"
}
$GlobalDir = "$env:USERPROFILE\.codebuddy\skills\codebuddy-git-config"
Copy-Item -Recurse -Force $SkillSrc $GlobalDir
```

#### 9.3 验证全局部署

```bash
ls ~/.codebuddy/skills/codebuddy-git-config/
# 应显示：SKILL.md  references/  scripts/
```

#### 9.4 全局部署的价值

将 skill 部署至全局后：

- **所有项目共享**：在任何 CodeBuddy 项目中输入"帮我配置 Git"即可使用
- **无需重复复制**：新项目无需再手动放置 skill 文件
- **与 GitHub 同步**：全局 skill 更新后，可通过 `codebuddy-config` 仓库拉取最新版本，再覆盖至全局目录
- **恢复便捷**：重装 IDE 后只需从 GitHub 克隆 + 部署全局即可

#### 9.5 全局部署后更新 skill

当 `codebuddy-config` 仓库中的 skill 有更新时：

```bash
# 1. 从 GitHub 拉取最新版本
cd ~/CodeBuddy/codebuddy-config
git pull origin main

# 2. 覆盖全局 skill
cp -R .codebuddy/skills/codebuddy-git-config ~/.codebuddy/skills/codebuddy-git-config

# 3. 重启 CodeBuddy
```

#### 9.6 全局部署在部署流程中的位置

```
部署完整流程（供参考）：

Phase 0→1→2→3→4→5→6→7→8  →  9 (可选：全局部署)
                                  ↓
                              skill 全局可用
                              ↓
                          新项目创建后，
                          无需配置即可使用
```

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

### scripts/

此 skill 包含以下脚本：

| 脚本 | 用途 |
|------|------|
| **`export-skill-package.ps1`** | 打包 skill 用于离线传输到新设备（Windows PowerShell） |
| **`export-skill-package.sh`** | 打包 skill 用于离线传输到新设备（macOS / Linux） |
| **`sync-config.sh`** | 配置仓库自动同步脚本（macOS/Linux），可手动触发或用于 crontab |

#### sync-config.sh 用法

```bash
# 手动触发同步（默认同步 codebuddy-config 仓库）
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh

# 手动触发同步（指定工作区项目）
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh /path/to/your/project

# 查看同步日志
cat ~/.codebuddy/sync-config.log
```
