# CodeBuddy Git 配置 — 使用手册

> 日常使用 Git 同步 CodeBuddy 配置的操作指引。

---

## 一、快速入门

### 1.1 每日三件事

```bash
# 1. 开始工作前 → 拉取最新
cd codebuddy-config && git pull

# 2. 修改配置后 → 提交推送
git add .
git commit -m "更新内容说明"
git push

# 3. 换设备 → 只需拉取
cd codebuddy-config && git pull
```

### 1.2 配置文件结构

```
codebuddy-config/
├── .gitignore                              # 项目忽略规则
├── CodeBuddy-Git-部署工作流.md              # 部署文档
└── .codebuddy/skills/codebuddy-git-config/ # Git 配置 skill
    ├── SKILL.md                            # AI 工作流定义
    ├── scripts/
    │   ├── export-skill-package.ps1        # 打包脚本（Windows）
    │   └── sync-config.sh                  # 同步脚本（macOS/Linux）
    └── references/
        ├── README.md                       # 英文安装说明
        ├── README-CN.txt                   # 中文安装说明
        ├── git-deployment-guide.md         # 部署指南
        ├── git-learning-guide.md           # 学习文档
        └── user-manual.md                  # 本手册
```

---

## 二、日常操作流程

### 2.1 修改并推送

```bash
cd codebuddy-config
git pull             # 1. 先拉取最新
# 用编辑器修改文件
git status           # 2. 查看变更
git diff             # 3. 查看具体改动
git add .            # 4. 暂存
git commit -m "docs: 更新配置说明"  # 5. 提交
git push             # 6. 推送
```

### 2.2 工作区项目发布到 GitHub

如果有一个新的工作区项目需要同步到 GitHub：

```bash
# 1. 进入项目目录
cd ~/CodeBuddy/项目名

# 2. 初始化并首次提交
git init
git checkout -b main
git add .
git commit -m "init: 初始化项目"

# 3. 在 https://github.com/new 创建空仓库
# 4. 关联远程并推送
git remote add origin git@github.com:dxc-dxc/项目名.git
git push -u origin main
```

或者直接告诉 CodeBuddy："帮我把这个项目推送到 GitHub"，AI 会引导你完成。

### 2.3 解决冲突

```bash
# 拉取时提示冲突
git status          # 查看冲突文件
# 手动编辑文件，删除冲突标记 <<< === >>>
git add .           # 标记已解决
git commit -m "解决合并冲突"
git push
```

### 2.4 紧急回退

```bash
git reset --soft HEAD~1   # 撤回提交，保留修改
git reset --hard HEAD~1   # ⚠️ 彻底丢弃最近提交
```

---

## 三、自动化同步

### 3.1 CodeBuddy Automation

完成配置后，skill 会创建每日自动同步任务：

- **codebuddy-config 仓库**：每日 9:00 自动拉取 + 推送
- **工作区项目**：每日 9:30 自动同步

无需手动操作，AI 会自动完成。

### 3.2 手动触发同步

```bash
# 同步 codebuddy-config
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh

# 同步指定项目
bash .codebuddy/skills/codebuddy-git-config/scripts/sync-config.sh ~/CodeBuddy/项目名

# 查看同步日志
cat ~/.codebuddy/sync-config.log
```

### 3.3 检查自动化状态

在 CodeBuddy 中：
1. 打开 Automation 面板
2. 查看 `codebuddy-config-auto-sync` 任务状态
3. 可手动触发或暂停

---

## 四、跨设备同步策略

### 4.1 多设备工作流

```
Windows PC  ←push/pull→  GitHub  ←push/pull→  MacBook / Linux
```

**黄金法则**：
- 修改后**立即推送**，换设备前**先拉取**
- 同一时间只在一台设备上修改
- 利用自动化同步避免手动遗漏

### 4.2 在新设备上运行 skill

1. 打开 CodeBuddy，加载 `codebuddy-git-config` skill
2. AI 自动执行：环境检测 → Git 配置 → 认证引导 → 克隆仓库
3. 认证环节**交互式引导**，凭据不会写入文档
4. 完成后自动创建同步自动化

### 4.3 离线传输 skill

在新设备无网络/无 Git 环境时：
1. 在已配置的设备上运行 `scripts/export-skill-package.ps1` 打包
2. 通过 U 盘/云盘传输
3. 解压到 `.codebuddy/skills/` 目录
4. 重启 CodeBuddy，输入"配置 Git 环境"

---

## 五、安全指南

### 5.1 严禁提交

- ❌ GitHub Token / Personal Access Token
- ❌ SSH 私钥
- ❌ 密码、API Key、数据库连接串
- ❌ `.env` 文件

### 5.2 正向做法

- ✅ 敏感信息用 `.env.example` 作为模板
- ✅ Token 使用 Git Credential Manager 安全存储
- ✅ SSH 密钥使用密码短语保护
- ✅ 定期轮换 Token

### 5.3 意外提交了敏感信息

1. 立即在 https://github.com/settings/tokens 撤销 Token
2. 从 Git 历史中彻底清除：
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch <FILE>" \
     --prune-empty -- --all
   ```
3. `git push --force --all`

---

## 六、命令行速查表

| 操作 | 命令 |
|------|------|
| 查看状态 | `git status` |
| 查看差异 | `git diff` |
| 暂存所有 | `git add .` |
| 提交 | `git commit -m "信息"` |
| 推送 | `git push` |
| 拉取 | `git pull` |
| 查看历史 | `git log --oneline` |
| 创建分支 | `git switch -c 分支名` |
| 查看远程 | `git remote -v` |
| 暂存现场 | `git stash` |
| 恢复现场 | `git stash pop` |
| 手动同步 | `bash scripts/sync-config.sh` |
| 查看同步日志 | `cat ~/.codebuddy/sync-config.log` |
