#!/bin/bash
# ======================================
# CodeBuddy Git Config Skill - Export Package (macOS/Linux)
#
# Pack the skill and related docs for offline transfer.
# No credentials (tokens/SSH keys) are included in the export.
#
# Usage:
#   bash export-skill-package.sh                    # Export to default location
#   bash export-skill-package.sh /path/to/output    # Export to custom path
# ======================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$SKILL_ROOT/../../../.." && pwd)"
SCRIPT_VERSION="1.0"

# Output path
if [ -z "$1" ]; then
    OUTPUT_DIR="$HOME/Desktop/codebuddy-skill-package"
else
    OUTPUT_DIR="$1"
fi

echo "=============================="
echo "CodeBuddy Git Config Skill"
echo "Export Package v$SCRIPT_VERSION"
echo "=============================="
echo ""
echo "Skill root:    $SKILL_ROOT"
echo "Project root:  $PROJECT_ROOT"
echo "Output dir:    $OUTPUT_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR/codebuddy-git-config"

# Copy skill files (exclude .git, plans, tokens)
echo ""
echo "📦 Copying skill files..."
rsync -av --exclude='.git' --exclude='*.log' --exclude='*.token' \
    "$SKILL_ROOT/" "$OUTPUT_DIR/codebuddy-git-config/" 2>/dev/null || \
cp -R "$SKILL_ROOT"/* "$OUTPUT_DIR/codebuddy-git-config/"

# Find and copy deployment doc
DOC_SRC=""
SEARCH_PATHS=(
    "$PROJECT_ROOT"
    "$PROJECT_ROOT/.."
    "$HOME/CodeBuddy/codebuddy-config"
)

for p in "${SEARCH_PATHS[@]}"; do
    if [ -f "$p/CodeBuddy-Git-部署工作流.md" ]; then
        DOC_SRC="$p/CodeBuddy-Git-部署工作流.md"
        break
    fi
done

echo "🔍 Searching for deployment document..."
if [ -n "$DOC_SRC" ]; then
    cp "$DOC_SRC" "$OUTPUT_DIR/"
    echo "   ✅ Found: $DOC_SRC"
else
    echo "   ⚠️  CodeBuddy-Git-部署工作流.md not found"
    echo "   Will create a placeholder"
    cat > "$OUTPUT_DIR/CodeBuddy-Git-部署工作流.md" << 'EOF'
# CodeBuddy Git 跨平台配置部署工作流

详见 `.codebuddy/skills/codebuddy-git-config/SKILL.md`
EOF
fi

# Copy README files from references
cp "$SKILL_ROOT/references/README.md" "$OUTPUT_DIR/" 2>/dev/null || true
cp "$SKILL_ROOT/references/README-CN.txt" "$OUTPUT_DIR/" 2>/dev/null || true

# Create ZIP
echo ""
echo "🗜️ Creating ZIP archive..."
ZIP_NAME="codebuddy-skill-package.zip"
cd "$(dirname "$OUTPUT_DIR")"
zip -r "$ZIP_NAME" "$(basename "$OUTPUT_DIR")" -x "*.git*" "*.log" > /dev/null 2>&1
ZIP_PATH="$(pwd)/$ZIP_NAME"

echo ""
echo "=============================="
echo "✅  Export Complete!"
echo "=============================="
echo ""
echo "📁 Package folder: $OUTPUT_DIR"
echo "📦 ZIP archive:    $ZIP_PATH"
echo ""
echo "To install on a new device:"
echo "  1. Copy the folder or ZIP to the new device"
echo "  2. Place 'codebuddy-git-config' in .codebuddy/skills/"
echo "  3. Restart CodeBuddy"
echo "  4. Say '帮我配置 Git 跨平台环境'"
echo ""
echo "⚠️  No tokens or passwords are included in this package."
