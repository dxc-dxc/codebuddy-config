# Git 学习指南

> 从基础到进阶的 Git 系统教程。
> 本指南面向 CodeBuddy 用户，聚焦实际使用场景。

---

## 目录

- [一、Git 基础概念](#一git-基础概念)
- [二、日常操作](#二日常操作)
- [三、分支管理](#三分支管理)
- [四、远程协作](#四远程协作)
- [五、进阶技巧](#五进阶技巧)
- [六、常见误区](#六常见误区)

---

## 一、Git 基础概念

### 1.1 Git 是什么

Git 是一个**分布式版本控制系统**，记录文件的每次变更，支持多人协作、版本回溯。

### 1.2 三个区域

```
工作目录 (Working Directory)   →   暂存区 (Staging Area)   →   仓库 (Repository)
      ↓                              ↓                            ↓
  你正在编辑的文件              git add 后的文件              git commit 后的文件
```

### 1.3 四种状态

| 状态 | 说明 | 常见命令 |
|------|------|---------|
| **Untracked** | 新文件，未被 Git 追踪 | `git add` |
| **Modified** | 已追踪的文件被修改 | `git add` 或 `git diff` |
| **Staged** | 已暂存，等待提交 | `git commit` |
| **Committed** | 已提交到仓库 | `git log` 查看 |

### 1.4 跨平台关键概念：换行符

```
Windows: CRLF (\r\n)  ←编辑时→  Git 存储为 LF (\n)
macOS/Linux: LF (\n)  ←编辑时→  Git 保持 LF (\n)
```

- `core.autocrlf true`：Git 自动处理这个转换
- **为什么重要**：不配置的话，Windows 和 Mac 之间同步的文件会显示大量"假修改"

---

## 二、日常操作

### 2.1 查看状态

```bash
git status           # 查看当前仓库状态（最常用）
git status -s        # 精简模式，一行一个文件
```

### 2.2 查看变更内容

```bash
git diff             # 查看工作区和暂存区的差异
git diff --staged    # 查看暂存区和仓库的差异
git diff HEAD        # 查看所有未提交的差异
```

### 2.3 暂存与提交

```bash
# 暂存指定文件
git add filename.md

# 暂存所有变更
git add .

# 提交（务必写清晰的说明）
git commit -m "feat: 添加用户登录功能"

# 跳过暂存直接提交（仅已追踪的文件）
git commit -a -m "fix: 修复登录 bug"
```

### 2.4 提交信息规范

推荐使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>: <简短描述>

<可选详细说明>
```

| Type | 含义 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加用户注册` |
| `fix` | 修复 | `fix: 修复登录超时问题` |
| `docs` | 文档 | `docs: 更新 README` |
| `refactor` | 重构 | `refactor: 拆分用户模块` |
| `chore` | 杂项 | `chore: 更新依赖版本` |

### 2.5 查看历史

```bash
git log              # 完整提交历史
git log --oneline    # 简洁显示
git log --graph      # 图形化显示分支
git log -p           # 显示每次提交的具体改动
git log --oneline --author="dxc"  # 查看某人提交
```

### 2.6 版本回退

```bash
# 软回退（保留工作区和暂存区改动）
git reset --soft HEAD~1

# 混合回退（保留工作区，清空暂存区）⭐ 最常用
git reset --mixed HEAD~1

# 硬回退（⚠️ 危险！彻底丢弃提交）
git reset --hard HEAD~1
```

---

## 三、分支管理

### 3.1 分支概念

```
main ────●────●────●────●
              \         /
feature-1      ●───●───●
```

- `main`：主分支，保持稳定
- `feature-*`：功能分支，开发完成后合并回 main

### 3.2 分支操作

```bash
# 查看分支
git branch                 # 本地分支
git branch -r             # 远程分支
git branch -a             # 所有分支

# 创建分支
git branch feature-login  # 创建
git switch feature-login  # 切换（Git 2.23+）
# 或一步到位
git switch -c feature-login

# 合并分支
git switch main           # 先切回 main
git merge feature-login   # 合并功能分支

# 删除分支
git branch -d feature-login         # 本地
git push origin --delete feature-login  # 远程
```

### 3.3 解决合并冲突

当两人修改同一文件时，Git 无法自动合并：

```bash
# 冲突文件会包含以下标记：
<<<<<<< HEAD
当前分支的内容
=======
合并进来的内容
>>>>>>> feature-login

# 手动编辑 → 删除标记 → 保存
git add .          # 标记冲突已解决
git commit         # 完成合并提交
```

---

## 四、远程协作

### 4.1 远程仓库操作

```bash
# 查看远程
git remote -v

# 添加远程
git remote add origin <URL>

# 推送
git push -u origin main   # 首次需 -u 建立关联
git push                  # 之后直接 push

# 拉取
git pull                  # fetch + merge
git fetch                 # 仅获取，不合并
```

### 4.2 同步工作流

```
新设备上开始工作前：
git pull          # 拉取最新代码

完成修改后：
git add .
git commit -m "说明"
git push          # 推送到 GitHub
```

### 4.3 跨平台同步注意事项

1. **先 pull 再干活** — 避免冲突
2. **只传源码，不传依赖** — `node_modules/`、`venv/` 各平台独立安装
3. **敏感信息不提交** — 用 `.env.example` 模板，不提交 `.env`

---

## 五、进阶技巧

### 5.1 修改最近提交

```bash
# 修改提交信息
git commit --amend -m "新的提交信息"

# 添加遗漏文件到最近提交
git add forgotten-file.md
git commit --amend --no-edit
```

### 5.2 暂存工作现场

```bash
# 保存当前未完成的工作（切分支前）
git stash
git stash save "WIP: 登录功能开发中"

# 恢复
git stash pop        # 恢复并删除
git stash apply      # 恢复但保留
git stash list       # 查看所有 stash
```

### 5.3 选择性地合并（cherry-pick）

```bash
# 只取另一个分支的某个提交
git cherry-pick <commit-hash>
```

### 5.4 查看文件是谁改的

```bash
git blame filename.md
# 每行显示：提交哈希 · 作者 · 日期 · 内容
```

---

## 六、常见误区

### ❌ 误区 1：`git add .` 后再用 `git add` 会覆盖

不会。`git add` 是**累加**操作，每次暂存的都是当前文件的最新版本。

### ❌ 误区 2：`git pull` 会覆盖本地修改

会尝试自动合并。如果本地有未提交的修改，Git 会报错拒绝。先提交或 stash 再 pull。

### ❌ 误区 3：`git reset --hard` 后还能找回

可以，只要提交还在 reflog 中：
```bash
git reflog           # 查看所有操作历史
git reset --hard HEAD@{1}  # 恢复到上一步
```

### ❌ 误区 4：换行符问题只影响 Windows

错。配置不当的话，Windows 提交的 CRLF 文件在 macOS/Linux 上会显示 `^M`；反之 Windows 会看到全部文件已修改。

### ✅ 最佳实践清单

1. 每个提交只做一件事，保持原子性
2. 提交信息用英文，格式一致
3. 不在 main 分支直接开发
4. 公共分支禁用 `git push --force`
5. 使用 `.gitignore` 排除无用文件
6. 敏感信息永远不提交
7. 跨平台项目配置 `core.autocrlf`
