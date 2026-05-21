# CodeBuddy Git Config Skill — Offline Installation Package

Generated: {DATE}
Packaged by: export-skill-package.ps1

## Installation on a New Device

### Method A: Copy Folder (Recommended)

1. Copy the entire `codebuddy-skill-package` folder to the project directory on the new device
2. Ensure `codebuddy-git-config` is placed under `.codebuddy/skills/`
3. Restart CodeBuddy

### Method B: Manual Placement

1. Copy `codebuddy-git-config` folder to `.codebuddy/skills/` in your project
2. Copy `CodeBuddy-Git-部署工作流.md` to the project root
3. Restart CodeBuddy

### Method C: AI-Guided Auto-Configuration

After placing the files, ask CodeBuddy with one of these commands:

- "Set up Git cross-platform environment on a new device"
- "Configure cross-platform Git sync for me"
- "Setup Git environment for a new computer"

The AI will guide you through:
1. Git installation
2. Global configuration
3. GitHub authentication
4. Clone config repository
5. **Publish workspace project to GitHub**
6. **Configure auto-sync automation**

---

## File Description

| File/Directory | Description |
|---------------|-------------|
| `codebuddy-git-config/` | CodeBuddy Skill definition (required) |
| `CodeBuddy-Git-部署工作流.md` | Complete deployment workflow document |
| `README.md` | This file (English installation guide) |
| `README-CN.txt` | Chinese installation guide |

---

## Safety Statement

This package **contains NO tokens, SSH keys, or passwords**.
GitHub authentication will be completed interactively on the new device.
