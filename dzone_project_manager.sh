#!/bin/bash

# D-Zone Clone Project Manager
# For Godot 2D development on Linux with GitHub integration

set -e  # Exit on any error

PROJECT_NAME="dzone-test"
PROJECT_DIR="dzone-test"
GITHUB_REPO="rstevenson1237/dzone-test"  # Update with your GitHub username
GODOT_VERSION="4.x"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Function to initialize project structure
init_project() {
    log "Initializing D-Zone Clone project structure..."
    
    cd "$PROJECT_DIR" || error "Cannot access project directory: $PROJECT_DIR"
    
    # Create main folder structure
    mkdir -p {scenes,scripts,assets,docs,tools,tests}
    
    # Create scene subfolders
    mkdir -p scenes/{tanks,arena,ui,menus,weapons,effects}
    
    # Create script subfolders
    mkdir -p scripts/{core,tanks,weapons,ai,ui,utils,managers}
    
    # Create asset subfolders
    mkdir -p assets/{sprites,sounds,music,fonts,shaders}
    mkdir -p assets/sprites/{tanks,weapons,effects,ui,arena}
    mkdir -p assets/sounds/{weapons,effects,ui,ambient}
    
    # Create documentation folders
    mkdir -p docs/{design,api,tutorials}
    
    # Create test folders
    mkdir -p tests/{unit,integration,performance}
    
    log "Project structure created successfully!"
}

# Function to create stub files
create_stubs() {
    log "Creating stub files..."
    
    # Main project file (Godot will create this, but we can stub it)
    cat > project.godot << 'EOF'
; Engine configuration file.
; This is an auto-generated file and should not be edited manually.
; Please use the Project Settings dialog to configure the project.

[application]

config/name="D-Zone Clone"
config/description="A modern recreation of the classic Destruction Zone tank combat game"
run/main_scene="res://scenes/menus/MainMenu.tscn"
config/features=PackedStringArray("4.2")
config/icon="res://assets/sprites/ui/icon.svg"

[display]

window/size/viewport_width=1024
window/size/viewport_height=768
window/size/resizable=true

[input]

# Player 1 controls
p1_move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"echo":false,"script":null)]
}
p1_move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"echo":false,"script":null)]
}

[rendering]

renderer/rendering_method="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
EOF

    # Create main scene stubs
    create_scene_stub "scenes/menus/MainMenu.tscn" "Main Menu Scene"
    create_scene_stub "scenes/arena/Arena.tscn" "Arena Scene"
    create_scene_stub "scenes/tanks/Tank.tscn" "Tank Scene"
    create_scene_stub "scenes/ui/HUD.tscn" "HUD Scene"
    create_scene_stub "scenes/ui/ShopMenu.tscn" "Weapon Shop Scene"
    
    # Create core script stubs
    create_script_stub "scripts/core/GameManager.gd" "GameManager" "Node"
    create_script_stub "scripts/core/SceneManager.gd" "SceneManager" "Node"
    create_script_stub "scripts/tanks/Tank.gd" "Tank" "CharacterBody2D"
    create_script_stub "scripts/tanks/TankController.gd" "TankController" "Node"
    create_script_stub "scripts/ai/AIController.gd" "AIController" "Node"
    create_script_stub "scripts/weapons/Weapon.gd" "Weapon" "Node2D"
    create_script_stub "scripts/weapons/WeaponManager.gd" "WeaponManager" "Node"
    create_script_stub "scripts/managers/EconomyManager.gd" "EconomyManager" "Node"
    create_script_stub "scripts/ui/HUD.gd" "HUD" "Control"
    create_script_stub "scripts/ui/ShopMenu.gd" "ShopMenu" "Control"
    
    # Create documentation stubs
    create_doc_stub "README.md" "Project README"
    create_doc_stub "docs/design/GameDesignDocument.md" "Game Design Document"
    create_doc_stub "docs/design/TechnicalSpecification.md" "Technical Specification"
    create_doc_stub "CHANGELOG.md" "Changelog"
    
    # Create configuration files
    create_gitignore
    create_gitattributes
    
    log "Stub files created successfully!"
}

# Helper function to create scene stubs
create_scene_stub() {
    local file_path="$1"
    local scene_name="$2"
    
    mkdir -p "$(dirname "$file_path")"
    
    cat > "$file_path" << EOF
[gd_scene load_steps=1 format=3]

[node name="$scene_name" type="Node2D"]

# TODO: Implement $scene_name
# This is a stub file created by the project manager
EOF
}

# Helper function to create script stubs
create_script_stub() {
    local file_path="$1"
    local class_name="$2"
    local extends_class="$3"
    
    mkdir -p "$(dirname "$file_path")"
    
    cat > "$file_path" << EOF
extends $extends_class
class_name $class_name

# $class_name - D-Zone Clone
# TODO: Implement core functionality

# Called when the node enters the scene tree for the first time
func _ready():
    print("$class_name initialized")

# Called every frame (if needed)
func _process(delta):
    pass
EOF
}

# Helper function to create documentation stubs
create_doc_stub() {
    local file_path="$1"
    local doc_name="$2"
    
    mkdir -p "$(dirname "$file_path")"
    
    case "$file_path" in
        "README.md")
            cat > "$file_path" << 'EOF'
# D-Zone Clone

A modern recreation of the classic 1992 DOS game "Destruction Zone" using Godot 2D engine.

## Overview

D-Zone Clone is a tank battle game featuring:
- Up to 6 players (3 human, 3 AI)
- Weapon upgrade system
- Economic progression
- Multiple AI personalities
- Arena-based combat

## Development

Built with:
- Godot 4.x
- Linux development environment
- GitHub for version control

## Getting Started

1. Clone the repository
2. Open project in Godot
3. Run the main scene

## License

[Your chosen license]
EOF
            ;;
        *)
            cat > "$file_path" << EOF
# $doc_name

## TODO: Complete documentation

This document is a stub created by the project manager.

Created: $(date)
EOF
            ;;
    esac
}

# Create .gitignore
create_gitignore() {
    cat > .gitignore << 'EOF'
# Godot-specific ignores
.import/
export.cfg
export_presets.cfg
*.tmp
*.translation

# Imported translations (automatically generated from CSV files)
*.translation

# Mono-specific ignores
.mono/
data_*/
mono_crash.*.json

# System/editor files
.DS_Store
*~
*.swp
*.tmp
\#*\#
.\#*

# Build artifacts
builds/
exports/

# IDE files
.vscode/
.idea/

# Log files
*.log
EOF
}

# Create .gitattributes
create_gitattributes() {
    cat > .gitattributes << 'EOF'
# Normalize line endings
* text=auto

# Godot files
*.gd text
*.cs text
*.tscn text
*.tres text
*.cfg text
*.md text

# Binary files
*.png binary
*.jpg binary
*.jpeg binary
*.ogg binary
*.wav binary
*.mp3 binary
*.ttf binary
*.otf binary
*.woff binary
*.woff2 binary
EOF
}

# Function to initialize git repository
init_git() {
    log "Initializing Git repository..."
    
    if [ ! -d .git ]; then
        git init
        git branch -M main
        log "Git repository initialized"
    else
        warn "Git repository already exists"
    fi
    
    # Configure git if not already configured
    if [ -z "$(git config user.name)" ]; then
        warn "Git user.name not configured. Please run: git config --global user.name 'Your Name'"
    fi
    
    if [ -z "$(git config user.email)" ]; then
        warn "Git user.email not configured. Please run: git config --global user.email 'your.email@example.com'"
    fi
}

# Function to setup GitHub repository
setup_github() {
    log "Setting up GitHub repository..."
    
    if command -v gh &> /dev/null; then
        read -p "Create GitHub repository '$GITHUB_REPO'? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh repo create "$GITHUB_REPO" --public --description "D-Zone Clone - Recreation of the classic tank combat game"
            git remote add origin "https://github.com/$GITHUB_REPO.git"
            log "GitHub repository created and remote added"
        fi
    else
        warn "GitHub CLI not installed. Please manually create repository and add remote:"
        warn "git remote add origin https://github.com/$GITHUB_REPO.git"
    fi
}

# Function to commit changes
commit_changes() {
    local commit_message="$1"
    
    if [ -z "$commit_message" ]; then
        commit_message="Automated commit: $(date)"
    fi
    
    log "Committing changes..."
    
    git add .
    
    if git diff --staged --quiet; then
        warn "No changes to commit"
        return 0
    fi
    
    git commit -m "$commit_message"
    log "Changes committed: $commit_message"
    
    # Ask if user wants to push
    if git remote get-url origin &> /dev/null; then
        read -p "Push to remote repository? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push -u origin main
            log "Changes pushed to remote repository"
        fi
    fi
}

# Function to show project status
show_status() {
    echo -e "${BLUE}=== D-Zone Clone Project Status ===${NC}"
    echo "Project Directory: $PROJECT_DIR"
    echo "Git Status:"
    git status --short
    echo
    echo "Recent Commits:"
    git log --oneline -5 2>/dev/null || echo "No commits yet"
    echo
    echo "File Structure:"
    tree -L 2 2>/dev/null || find . -maxdepth 2 -type d | head -10
}

# Main script logic
case "${1:-help}" in
    "init")
        log "Initializing D-Zone Clone project..."
        init_project
        create_stubs
        init_git
        commit_changes "Initial project setup with folder structure and stubs"
        setup_github
        show_status
        log "Project initialization complete!"
        ;;
    "commit")
        shift
        commit_message="${*:-$(date +'Commit on %Y-%m-%d at %H:%M:%S')}"
        commit_changes "$commit_message"
        ;;
    "status")
        show_status
        ;;
    "help"|*)
        echo -e "${BLUE}D-Zone Clone Project Manager${NC}"
        echo
        echo "Usage: $0 <command> [options]"
        echo
        echo "Commands:"
        echo "  init              Initialize project structure and GitHub repository"
        echo "  commit [message]  Commit changes with optional message"
        echo "  status            Show project status"
        echo "  help              Show this help message"
        echo
        echo "Examples:"
        echo "  $0 init                                    # Initialize project"
        echo "  $0 commit 'Added tank movement system'    # Commit with message"
        echo "  $0 commit                                  # Commit with auto message"
        echo "  $0 status                                  # Show status"
        ;;
esac
