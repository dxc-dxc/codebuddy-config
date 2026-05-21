<#
.SYNOPSIS
    CodeBuddy Git Config Skill - Export Package Tool
.DESCRIPTION
    Package the skill and related docs for offline transfer via USB/LAN/cloud.
    No credentials (tokens/SSH keys) are included in the export.
.EXAMPLE
    .\export-skill-package.ps1 -Destination "D:\USB_DRIVE\codebuddy-setup"
    .\export-skill-package.ps1
    .\export-skill-package.ps1 -Destination "D:\share" -CreateZip
.NOTES
    Version: 1.0
    Security: This script NEVER reads or writes tokens, passwords, or private keys.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Destination = "",

    [Parameter(Mandatory = $false)]
    [switch]$CreateZip
)

# -- Config: auto-detect paths --
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot = Split-Path -Parent $ScriptDir
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $SkillRoot))
$ScriptVersion = "1.0"

# Search for root doc in project directory tree (handles Chinese paths safely)
$docCandidates = @(
    (Join-Path $ProjectRoot "CodeBuddy-Git-Deployment-Workflow.md"),
    (Join-Path $ProjectRoot "CodeBuddy-Git-部署工作流.md"),
    (Join-Path (Split-Path -Parent $ProjectRoot) "CodeBuddy-Git-部署工作流.md")
)
$RootDoc = $null
foreach ($candidate in $docCandidates) {
    $resolved = Resolve-Path $candidate -ErrorAction SilentlyContinue
    if ($resolved) { $RootDoc = $resolved.Path; break }
}

# If still not found, search by wildcard
if (-not $RootDoc) {
    $found = Get-ChildItem -Path $ProjectRoot -Filter "CodeBuddy-Git*" -File -ErrorAction SilentlyContinue
    if (-not $found) {
        $found = Get-ChildItem -Path (Split-Path -Parent $ProjectRoot) -Filter "CodeBuddy-Git*" -File -ErrorAction SilentlyContinue
    }
    if ($found) { $RootDoc = $found[0].FullName }
}

# -- Helpers --
function Write-Info  { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Step { Write-Host "`n=== Step: $args ===" -ForegroundColor Yellow }
function Write-OK   { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Magenta }
function Write-Err  { Write-Host "[ERROR] $args" -ForegroundColor Red }

function Test-NoCredentials {
    param([string]$Path)

    # Skip the script itself (patterns defined here would match themselves)
    if ($Path -like '*.ps1') { return $true }

    # Patterns to detect (regex)
    $credPatterns = @(
        'ghp_[a-zA-Z0-9]{36}',
        'gho_[a-zA-Z0-9]{36}',
        'github_pat_[a-zA-Z0-9_]{22,}',
        '-----BEGIN.*PRIVATE KEY-----'
    )
    foreach ($pattern in $credPatterns) {
        $matches = Select-String -Path $Path -Pattern $pattern -SimpleMatch:$false -ErrorAction SilentlyContinue
        if ($matches) {
            Write-Err "Credential pattern detected in: $Path"
            Write-Err "Matched pattern: $pattern"
            return $false
        }
    }
    return $true
}

# -- Main --
Write-Step "Checking source files"
$sourceFiles = @()

if (Test-Path $SkillRoot) {
    $sourceFiles += @(Get-ChildItem -Path $SkillRoot -Recurse -File | Select-Object -ExpandProperty FullName)
    Write-OK "Skill dir found: $SkillRoot ($($sourceFiles.Count) files)"
} else {
    Write-Err "Skill dir not found: $SkillRoot"
    exit 1
}

if ($RootDoc -and (Test-Path $RootDoc)) {
    $sourceFiles += $RootDoc
    $docName = Split-Path -Leaf $RootDoc
    Write-OK "Root doc found: $RootDoc"
} else {
    Write-Warn "Root doc not found (optional) - searched as 'CodeBuddy-Git-*'"
}

# 2. Security check
Write-Step "Security check (scanning for credentials)"
$allClean = $true
foreach ($file in $sourceFiles) {
    if (-not (Test-NoCredentials $file)) {
        $allClean = $false
    }
}
if (-not $allClean) {
    Write-Err "[SECURITY] Credential detected! Remove them and re-run."
    exit 1
}
Write-OK "All files passed security check."

# 3. Determine destination
Write-Step "Setting destination path"
if ([string]::IsNullOrEmpty($Destination)) {
    $Destination = Join-Path $env:USERPROFILE "Desktop\codebuddy-skill-package"
    Write-Info "Default destination: $Destination"
}

if (Test-Path $Destination) {
    Remove-Item -Path $Destination -Recurse -Force
}
New-Item -ItemType Directory -Path $Destination -Force | Out-Null

# 4. Copy files
Write-Step "Copying files to destination"
$skillDest = Join-Path $Destination "codebuddy-git-config"
New-Item -ItemType Directory -Path $skillDest -Force | Out-Null
Copy-Item -Path "$SkillRoot\*" -Destination $skillDest -Recurse -Force
Write-OK "Skill files copied: $skillDest"

Copy-Item -Path $RootDoc -Destination $Destination -Force
$docName = Split-Path -Leaf $RootDoc
Write-OK "Root doc copied: $(Join-Path $Destination $docName)"

# 5. Generate install guides
Write-Step "Generating install guides"

# English README
$readmeEn = @"
# CodeBuddy Git Config Skill - Offline Package

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
Packaged by: export-skill-package.ps1

## How to Install on a New Device

### Method A: Direct Copy (Recommended)

1. Copy the entire folder to your project directory on the new device
2. Make sure codebuddy-git-config is placed under .codebuddy/skills/
3. Restart CodeBuddy

### Method B: Manual Placement

1. Copy codebuddy-git-config folder to: .codebuddy/skills/
2. Copy CodeBuddy-Git-Deployment-Workflow.md (or CodeBuddy-Git-部署工作流.md) to the project root
3. Restart CodeBuddy

### Method C: Automated (After CodeBuddy loads the skill)

After placing the files, open CodeBuddy and say:
- Help me configure Git on this new machine
- Set up cross-platform Git sync
- Load git-config skill for new device

AI will guide you through: Git install -> global config -> GitHub auth -> repo clone.

---

Security Notice: This package contains NO tokens, SSH keys, or passwords.
"@

$readmeEnPath = Join-Path $Destination "README.txt"
[System.IO.File]::WriteAllText($readmeEnPath, $readmeEn, [System.Text.UTF8Encoding]::new($true))
Write-OK "English install guide created: $readmeEnPath"

# Chinese README (read from template file to avoid encoding issues)
$cnTemplatePath = Join-Path $SkillRoot "references\README-CN.txt"
if (Test-Path $cnTemplatePath) {
    $readmeCnRaw = [System.IO.File]::ReadAllText($cnTemplatePath, [System.Text.UTF8Encoding]::new($true))
    $dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $readmeCn = $readmeCnRaw -replace '{DATE}', $dateStr
    $readmeCnPath = Join-Path $Destination "README-CN.txt"
    [System.IO.File]::WriteAllText($readmeCnPath, $readmeCn, [System.Text.UTF8Encoding]::new($true))
    Write-OK "Chinese install guide created: $readmeCnPath"
} else {
    Write-Warn "Chinese README template not found: $cnTemplatePath"
}

# 6. Optional ZIP
if ($CreateZip) {
    Write-Step "Creating ZIP archive"
    $zipPath = "$Destination.zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Destination, $zipPath)
    Write-OK "ZIP created: $zipPath"
}

# 7. Summary
Write-Step "Export complete"
Write-Host "`n=============================================" -ForegroundColor Cyan
Write-Host "  Export Successful" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Location: $Destination"
if ($CreateZip) {
    Write-Host "ZIP: $Destination.zip"
}
Write-Host ""
Write-Host "Files:" -ForegroundColor Yellow
Get-ChildItem -Path $Destination -Recurse -File | ForEach-Object {
    $sizeStr = '{0:N0}' -f $_.Length
    Write-Host "  +- $($_.FullName) ($sizeStr bytes)"
}
Write-Host ""
Write-Host "Recommended transfer methods:" -ForegroundColor Yellow
Write-Host "  +- USB drive"
Write-Host "  +- LAN share (SMB / SCP)" -NoNewline
if ($CreateZip) { Write-Host " / ZIP" } else { Write-Host "" }
Write-Host "  +- Cloud storage (upload ZIP)"
Write-Host ""
Write-Warn "Remember to delete temporary files from USB drive when done."
