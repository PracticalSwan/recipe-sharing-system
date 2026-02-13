---
name: devops-tooling
description: Comprehensive DevOps and automation toolkit combining Git workflow management, shell scripting for automation, CI/CD pipeline configuration, and terminal operations. Covers conventional commits, Git operations, PowerShell/Bash scripting with error handling, and automation patterns for development workflows. Use when working with Git, writing automation scripts, configuring CI/CD pipelines, or managing development tooling.
license: Complete terms in LICENSE.txt
---

# DevOps & Automation Tooling

Comprehensive toolkit for Git workflows, shell scripting, and development automation.

## When to Use This Skill

- Creating conventional commits and managing Git workflows
- Writing Bash, Zsh, or PowerShell automation scripts
- Configuring CI/CD pipelines (GitHub Actions, Azure DevOps)
- Automating development, testing, or deployment tasks
- Troubleshooting Git conflicts and repository hygiene issues

## No-Activation Conditions

**Do NOT activate this skill when:**
- User asks basic git questions without automation needs
- Request is for simple scripts without DevOps context
- Task doesn't involve CI/CD, deployment, or infrastructure
- User wants to write application code, not automation
- Manual operations without tooling considerations

---

## Part 1: Git Workflows

### Conventional Commits

The conventional commit specification provides an easy-to-extend set of rules for creating an explicit commit history.

#### Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types

| Type | Purpose | Example |
|-------|---------|---------|
| `feat` | New feature | `feat(auth): add OAuth2 support` |
| `fix` | Bug fix | `fix(api): resolve null reference` |
| `docs` | Documentation only | `docs(readme): update setup guide` |
| `style` | Formatting/style (no logic) | `style(ui): fix indentation` |
| `refactor` | Refactor production code | `refactor(svc): extract helpers` |
| `perf` | Performance improvement | `perf(db): add index on email` |
| `test` | Adding tests | `test(auth): add unit tests` |
| `build` | Build system or deps | `build(ci): upgrade Node to v20` |
| `ci` | CI configuration changes | `ci(github): add workflow for PRs` |
| `chore` | Maintenance tasks | `chore(deps): update packages` |
| `revert` | Revert previous commit | `revert: feat(login)` |

#### Breaking Changes

Breaking changes must be indicated by `!` after the type/scope, or via `BREAKING CHANGE` in footer:

```bash
# With !
feat(api)!: remove deprecated v1 endpoint

# With footer
feat(api): remove deprecated v1 endpoint

BREAKING CHANGE: v1 endpoints are no longer supported. Use v2.
```

#### Good Examples

```bash
# Feature
feat(auth): implement JWT refresh tokens

# Bug fix
fix(ui): resolve mobile navigation overlap issue

# Documentation
docs(api): add authentication examples

# Refactor
refactor(user): extract validation logic to separate module

# Performance
perf(images): implement lazy loading

# Breaking change
feat(core)!: change data structure from array to object
```

### Git Operations

#### Branch Management

```bash
# Create new feature branch
git checkout -b feature/PROJ-123/user-auth

# Switch to branch
git checkout develop

# Delete local branch
git branch -d feature/PROJ-123/user-auth

# Delete remote branch
git push origin --delete feature/PROJ-123/user-auth

# Rename branch
git branch -m new-name

# List all branches
git branch -a
```

#### Commit Workflow

```bash
# Stage all changes
git add .

# Stage specific files
git add file1.ts file2.ts

# Interactive staging
git add -i

# Commit with message
git commit -m "feat(auth): add OAuth2 support"

# Amend last commit (if not pushed)
git commit --amend

# Show commit history
git log --oneline --graph --all

# Show detailed commit
git show <commit-hash>
```

#### Merge & Rebase

```bash
# Merge branch into current
git merge feature/new-feature

# Rebase onto target branch
git rebase develop

# Interactive rebase (clean up history)
git rebase -i HEAD~3

# Abort rebase/merge
git rebase --abort
git merge --abort

# Continue after conflicts
git rebase --continue
git merge --continue
```

#### Handling Conflicts

```bash
# When conflicts occur:
# 1. Check status
git status

# 2. Open conflicting files
# Look for <<<<<<< ======= >>>>>> markers
vim conflicting-file.ts

# 3. Manually resolve conflicts

# 4. Stage resolved files
git add conflicting-file.ts

# 5. Complete merge/rebase
git commit  # for merges
git rebase --continue  # for rebases
```

#### Stashing

```bash
# Stash current work
git stash push -m "Work in progress"

# Apply last stash
git stash pop

# Apply specific stash
git stash apply stash@{2}

# List stashes
git stash list

# Drop specific stash
git stash drop stash@{2}

# Drop all stashes
git stash clear
```

#### Tagging

```bash
# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release v1.0.0"

# Lightweight tag
git tag v1.0.0

# List tags
git tag

# Push all tags
git push origin --tags

# Push specific tag
git push origin v1.0.0

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

#### Git Diff

```bash
# Show working directory changes
git diff

# Show staged changes
git diff --staged

# Show changes in specific file
git diff src/app.ts

# Show changes between commits
git diff HEAD~2 HEAD

# Show commit range
git log --oneline v1.0.0..v2.0.0

# Show stats
git diff --stat
```

#### Git Configuration

```bash
# Set global user
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Set default branch name
git config --global init.defaultBranch main

# Set GPG signing (for signed commits)
git config --global commit.gpgsign true

# Alias common commands
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Unset config
git config --unset user.name

# List all config
git config --list
```

---

## Part 2: Shell Scripting (bash/zsh) 

### General Principles

- Generate clean, simple, and concise code
- Ensure scripts are easily readable and understandable
- Add comments where needed for understanding
- Generate concise echo outputs for execution status
- Avoid unnecessary output and excessive logging

### Error Handling & Safety

#### Enable Strict Mode

Always enable strict mode at the top of scripts:

```bash
#!/bin/bash
set -euo pipefail
```

- `-e`: Exit on first error
- `-u`: Treat unset variables as errors
- `-o pipefail`: Surface pipeline failures

#### Cleanup with Traps

```bash
cleanup() {
    # Remove temporary files
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    # Close connections
    if [[ -n "${CONNECTION:-}" ]]; then
        echo "Closing connection..."
        # connection close logic
    fi
}

trap cleanup EXIT

# Also catch specific signals
trap 'echo "Interrupted"; cleanup; exit 1' INT TERM
```

#### Validate Requirements

```bash
validate_requirements() {
    local errors=0
    
    # Check required variables
    if [[ -z "${RESOURCE_GROUP:-}" ]]; then
        echo "Error: RESOURCE_GROUP environment variable not set" >&2
        ((errors++))
    fi
    
    # Check required commands
    for cmd in curl jq az; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: $cmd is not installed" >&2
            ((errors++))
        fi
    done
    
    # Return appropriate exit code
    return $errors
}

# Call validation
if ! validate_requirements; then
    exit 1
fi
```

### Working with Variables

```bash
# Safe variable expansion with defaults
echo "Config: ${CONFIG_FILE:-./config.default.yaml}"

# Variable substitution
name="World"
echo "Hello, ${name}!"

# Array handling
apps=("app1" "app2" "app3")
for app in "${apps[@]}"; do
    echo "Processing: $app"
done

# Associative arrays (bash 4+)
declare -A config
config[host]="localhost"
config[port]="8080"
echo "Connecting to ${config[host]}:${config[port]}"
```

### Control Flow

```bash
# If statements
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux detected"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected"
else
    echo "Unknown OS"
fi

# Case statements
case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac

# Loops
for i in {1..5}; do
    echo "Iteration $i"
done

# While loop with timeout
timeout=30
elapsed=0
while [[ $elapsed -lt $timeout ]]; do
    if check_ready; then
        echo "Service ready"
        break
    fi
    sleep 1
    ((elapsed++))
done
```

### Parsing JSON with jq

```bash
# Parse JSON from file or URL
result=$(curl -s "https://api.example.com/data")
name=$(echo "$result" | jq -r '.name')
count=$(echo "$result" | jq '.items | length')
first_item=$(echo "$result" | jq -r '.items[0]')

# Filter JSON
active_users=$(echo "$result" | jq '.users[] | select(.status == "active")')

# Extract multiple fields
read -r first_name last_name email <<<$(echo "$result" | jq -r '"\(.firstName) \(.lastName) \(.email)"')

# Update JSON
echo "$result" | jq '.count += 1' > updated.json

# Create JSON
jq -n \
  --arg name "John" \
  --arg age "30" \
  '{name: $name, age: ($age | tonumber)}'
```

### Parsing Arguments

```bash
#!/bin/bash

# Default values
verbose=0
output_file="output.txt"
config="./config.yaml"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            verbose=1
            shift
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -c|--config)
            config="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

echo "Config: $config"
echo "Output: $output_file"
echo "Verbose: $verbose"
```

### File Operations

```bash
# Check if file exists
if [[ -f "$FILE_PATH" ]]; then
    echo "File exists"
fi

# Check if directory exists
if [[ ! -d "$DIR_PATH" ]]; then
    mkdir -p "$DIR_PATH"
fi

# Make directories
mkdir -p ./dir1/dir2

# Copy with directories
cp -r source_dir/ dest_dir/

# Remove
rm -f file.txt          # Force delete file
rm -rf directory/       # Recursive delete directory

# Find files
find . -name "*.py"           # All Python files
find . -type f -name "*.js"   # All JS files (regular files only)
find . -mtime -7              # Modified in last 7 days

# Safe file operations
# Using temporary files
temp_file=$(mktemp)
echo "data" > "$temp_file"
# ... work with temp_file
rm -f "$temp_file"

# Using mktemp for directories
temp_dir=$(mktemp -d)
# ... work with temp_dir
rm -rf "$temp_dir"
```

### Process Management

```bash
# Check if process is running
if pgrep -x "nginx" > /dev/null; then
    echo "Nginx is running"
else
    echo "Nginx is not running"
fi

# Wait for process
while pgrep -x "script-name" > /dev/null; do
    sleep 1
done

# Run command with timeout
timeout 30s ./long-running-script.sh || echo "Timed out after 30s"

# Background jobs
./script.sh &
job_pid=$!

# Kill background job on exit
trap "kill $job_pid 2>/dev/null" EXIT
```

### Logging

```bash
#!/bin/bash

# Logging levels
LOG_INFO() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') $*"
}

LOG_WARN() {
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

LOG_ERROR() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

LOG_DEBUG() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') $*"
    fi
}

# Usage
LOG_INFO "Starting deployment"
LOG_WARN "This is a warning"
LOG_ERROR "Deployment failed"
LOG_DEBUG "Detailed debugging info"
```

---

## Part 3: PowerShell Scripting

### General Practices

- Use proper cmdlet names instead of aliases (e.g., `Get-ChildItem`, not `dir`)
- Quote paths with spaces: `"C:\Path With Spaces\file.txt"`
- Use `ShouldProcess` for destructive operations
- Implement proper error handling with try-catch
- Parameterize scripts for reusability

### Error Handling

```powershell
# Enable strict mode
Set-StrictMode -Version Latest

# Error action preference
$ErrorActionPreference = "Stop"

# Try-Catch-Finally
try {
    $result = Invoke-RestMethod -Uri "https://api.example.com/data" -Method Get
}
catch [System.Net.WebException] {
    Write-Error "Network error occurred: $($_.Exception.Message)"
    exit 1
}
catch {
    Write-Error "Unexpected error: $($_.Exception.Message)"
    exit 1
}
finally {
    # Cleanup code always runs
    Write-Output "Execution completed"
}

# Error handling with trap
trap {
    Write-Error "Script failed: $_"
    # Cleanup code
    Remove-Variable -Name tempVar -ErrorAction SilentlyContinue
    exit 1
}
```

### Parameter Handling

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$false)]
    [string]$Path = ".",

    [Parameter(Mandatory=$false)]
    [switch]$Verbose,

    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev"
)

Write-Output "Name: $Name"
Write-Output "Path: $Path"
Write-Output "Environment: $Environment"
Write-Output "Verbose: $Verbose"
```

### Working with Objects

```powershell
# Create custom object
$user = [PSCustomObject]@{
    Name = "John"
    Age = 30
    Email = "john@example.com",
    Address = "123 Main St"
}

# Access properties
Write-Output $user.Name

# Add property
$user | Add-Member -MemberType NoteProperty -Name "City" -Value "Anytown"

# Filter objects
$users | Where-Object { $_.Age -gt 25 }

# Select properties
$users | Select-Object Name, Email

# Sort objects
$users | Sort-Object Name

# Group objects
$users | Group-Object City
```

### Working with JSON

```powershell
# Parse JSON
$json = '{"name": "John", "age": 30}'
$obj = $json | ConvertFrom-Json

Write-Output $obj.name

# Convert object to JSON
$data = @{ name = "John"; age = 30 }
$json = $data | ConvertTo-Json -Depth 10
Write-Output $json

# Read JSON from file
$config = Get-Content "config.json" | ConvertFrom-Json

# Write JSON to file
$config | ConvertTo-Json -Depth 10 | Set-Content "config.json"
```

### Working with Arrays and Hashtables

```powershell
# Arrays
$files = @("file1.txt", "file2.txt", "file3.txt")

# Append to array
$files += "file4.txt"

# Filter array
$filtered = $files | Where-Object { $_ -like "*.txt" }

# Hashtable (dictionary)
$config = @{
    host = "localhost"
    port = 8080
    tls = $true
}

# Access value
Write-Output $config.host

# Access via key as string
$key = "port"
Write-Output $config[$key]

# Iterate over hashtable
foreach ($item in $config.GetEnumerator()) {
    Write-Output "$($item.Name) = $($item.Value)"
}
```

### File Operations

```powershell
# Check if file exists
if (Test-Path "C:\path\to\file.txt") {
    Write-Output "File exists"
}

# Create directory
New-Item -ItemType Directory -Path "C:\new\dir" -Force

# Delete items
Remove-Item "C:\path\to\file.txt" -Force
Remove-Item "C:\path\to\directory" -Recurse -Force

# Copy items
Copy-Item "source.txt" "destination.txt" -Force
Copy-Item "dir\" "backup\" -Recurse

# Move items
Move-Item "old_name.txt" "new_name.txt"

# Get file content
$content = Get-Content "file.txt"
$content = Get-Content "file.txt" -Raw  # As single string

# Write file content
$content | Set-Content "file.txt"

# Append to file
"more content" | Add-Content "file.txt"
```

### String Operations

```powershell
# String interpolation
$name = "John"
Write-Output "Hello, $name!"

# String formatting
Write-Output ("Hello, {0}! Your score is {1:N2}" -f $name, 95.5)

# String methods
$string = "  Hello World  "

# Trim
$trimmed = $string.Trim()

# Replace
$replaced = $string.Replace("World", "PowerShell")

# Check if contains
if ($string -like "*World*") {
    Write-Output "Contains 'World'"
}

# Regular expressions
if ($string -match "^Hello") {
    Write-Output "Starts with 'Hello'"
}

# Split string
$parts = "a,b,c".Split(",")
```

---

## Part 4: CI/CD Configuration

### GitHub Actions

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch: # Allow manual trigger

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: build

      - name: Deploy to Azure
        run: az webapp up --name myapp --resource-group myrg
```

### Azure Pipelines

```yaml
trigger:
- main
- develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  packageFolder: '$(build.artifactStagingDirectory)/package'

stages:
- stage: Build
  displayName: 'Build stage'
  jobs:
  - job: Build
    displayName: 'Build job'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '18.x'
      displayName: 'Install Node.js'
    
    - script: |
        npm ci
      displayName: 'Install dependencies'
    
    - script: |
        npm run build
      displayName: 'Build application'
    
    - task: ArchiveFiles@2
      inputs:
        rootFolderOrFile: 'dist'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: $(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip
      displayName: 'Archive build artifacts'
    
    - publish: $(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip
      artifact: drop

- stage: Deploy
  displayName: 'Deploy stage'
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: Deploy
    displayName: 'Deploy job'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'your_subscription_id'
              appName: 'your_webapp_name'
              package: $(Pipeline.Workspace)/drop/$(Build.BuildId).zip
```

---

## DevOps Best Practices

### Git
- [ ] Use conventional commits
- [ ] Keep commits small and focused
- [ ] Write clear, descriptive messages
- [ ] Keep feature branches short-lived
- [ ] Rebase feature branches before merging
- [ ] Sign commits for security-critical projects

### Shell Scripting
- [ ] Always use strict mode (`set -euo pipefail`)
- [ ] Quote variables properly
- [ ] Handle errors gracefully with traps
- [ ] Validate inputs and parameters
- [ ] Use functions for reusability
- [ ] Add proper error messages to stderr

### PowerShell
- [ ] Use strict mode for security
- [ ] Use proper cmdlet names (no aliases)
- [ ] Implement error handling with try-catch
- [ ] Test scripts thoroughly
- [ ] Use parameter validation
- [ ] Handle pipeline errors properly

### CI/CD
- [ ] Use secure variable management for secrets
- [ ] Cache dependencies to speed up builds
- [ ] Run tests on multiple environments
- [ ] Use matrix builds for different configurations
- [ ] Implement proper artifact management
- [ ] Add deployment gates and approvals
- [ ] Provide clear build status

---

## References & Resources

### Documentation
- [CI/CD Patterns](./references/ci-cd-patterns.md) — GitHub Actions patterns, caching, security scanning, and deployment strategies
- [Shell Scripting Patterns](./references/shell-scripting-patterns.md) — PowerShell and Bash patterns side-by-side for automation

### Scripts
- [Setup Git Hooks](./scripts/setup-git-hooks.ps1) — PowerShell script to install pre-commit, commit-msg, and pre-push hooks

### Examples
- [GitHub Actions Templates](./examples/github-actions-templates.md) — 8 production-ready workflow templates for Node.js, Python, Docker, Terraform
