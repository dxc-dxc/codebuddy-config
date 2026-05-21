# CodeBuddy Git 配置 Skill —— 离线安装包

生成时间：{DATE}
打包工具：export-skill-package.ps1

## 在新设备上安装方法

### 方法 A：直接复制文件夹（推荐）

1. 将整个 codebuddy-skill-package 文件夹拷贝到新设备的项目目录下
2. 确保 codebuddy-git-config 文件夹位于 .codebuddy/skills/ 目录下
3. 重启 CodeBuddy

### 方法 B：手动放置

1. 将 codebuddy-git-config 文件夹复制到项目目录的 .codebuddy/skills/ 下
2. 将 CodeBuddy-Git-部署工作流.md 复制到项目根目录
3. 重启 CodeBuddy

### 方法 C：安装后自动配置（AI 引导）

完成文件放置后，在 CodeBuddy 中输入以下任一指令：

- "帮我在新设备上配置 Git 跨平台环境"
- "帮我配置跨平台 Git 同步"
- "为新电脑配置 Git 环境"

AI 将自动引导你完成：

1. Git 安装
2. 全局配置
3. GitHub 认证
4. 克隆配置仓库
5. **工作区项目发布至 GitHub**（初始化 / 推送）
6. **配置自动同步**（每日定时拉取推送）

---

## 文件说明

| 文件/目录 | 说明 |
|-----------|------|
| codebuddy-git-config/ | CodeBuddy Skill 定义（核心，必须放置） |
| CodeBuddy-Git-部署工作流.md | 完整部署工作流文档 |
| README.md | 英文安装说明 |
| README-CN.txt | 本文件（中文安装说明） |

---

## 安全声明

本安装包**不含任何 Token、SSH 密钥或密码**。
GitHub 认证过程将在新设备上交互完成，请放心使用。
