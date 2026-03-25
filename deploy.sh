#!/bin/bash

###############################################################################
# Deployment Script for Claude Code Novel Writing Tools
# This script deploys skills and agents from tools/ to .claude/ directory
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TOOLS_DIR="tools"
CLAUDE_DIR=".claude"
SKILLS_SOURCE="$TOOLS_DIR/skills"
AGENTS_SOURCE="$TOOLS_DIR/agents"
SKILLS_DEST="$CLAUDE_DIR/skills"
AGENTS_DEST="$CLAUDE_DIR/agents"

# Skill names
SKILLS=("auto-novel" "novel-planning" "novel-chapter")

# Agent names
AGENTS=("novel-supervisor.md" "interstellar-novelist.md" "logic-reviewer.md")

###############################################################################
# Functions
###############################################################################

print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

print_step() {
    echo -e "${YELLOW}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

validate_directory() {
    if [ ! -d "$1" ]; then
        print_error "Directory '$1' does not exist"
        exit 1
    fi
}

create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_success "Created directory: $1"
    fi
}

###############################################################################
# Deployment Steps
###############################################################################

print_header "Claude Code Novel Writing Tools - Deployment"

# Step 1: Validate source directories
print_step "Validating source directories..."
validate_directory "$TOOLS_DIR"
validate_directory "$SKILLS_SOURCE"
validate_directory "$AGENTS_SOURCE"
print_success "Source directories validated"

# Step 2: Create .claude directory structure
print_step "Creating .claude directory structure..."
create_directory "$CLAUDE_DIR"
create_directory "$SKILLS_DEST"
create_directory "$AGENTS_DEST"

# Step 3: Deploy skills
print_step "Deploying skills..."
for skill in "${SKILLS[@]}"; do
    skill_source="$SKILLS_SOURCE/$skill"
    skill_dest="$SKILLS_DEST/$skill"

    if [ ! -d "$skill_source" ]; then
        print_error "Skill source not found: $skill_source"
        exit 1
    fi

    # Create skill directory
    create_directory "$skill_dest"

    # Copy SKILL.md file
    if [ -f "$skill_source/SKILL.md" ]; then
        cp "$skill_source/SKILL.md" "$skill_dest/"
        print_success "Deployed skill: $skill"
    else
        print_error "SKILL.md not found in: $skill_source"
        exit 1
    fi
done

# Step 4: Deploy agents
print_step "Deploying agents..."
for agent in "${AGENTS[@]}"; do
    agent_source="$AGENTS_SOURCE/$agent"
    agent_dest="$AGENTS_DEST/$agent"

    if [ ! -f "$agent_source" ]; then
        print_error "Agent source not found: $agent_source"
        exit 1
    fi

    cp "$agent_source" "$agent_dest"
    print_success "Deployed agent: $agent"
done

# Step 5: Verify deployment
print_step "Verifying deployment..."
deployment_success=true

# Check skills
for skill in "${SKILLS[@]}"; do
    if [ ! -f "$SKILLS_DEST/$skill/SKILL.md" ]; then
        print_error "Verification failed: $SKILLS_DEST/$skill/SKILL.md"
        deployment_success=false
    fi
done

# Check agents
for agent in "${AGENTS[@]}"; do
    if [ ! -f "$AGENTS_DEST/$agent" ]; then
        print_error "Verification failed: $AGENTS_DEST/$agent"
        deployment_success=false
    fi
done

if [ "$deployment_success" = true ]; then
    print_success "All deployments verified successfully"
else
    print_error "Deployment verification failed"
    exit 1
fi

# Step 6: Summary
print_header "Deployment Summary"
echo ""
echo "Deployed Skills:"
for skill in "${SKILLS[@]}"; do
    echo "  - $skill"
done
echo ""
echo "Deployed Agents:"
for agent in "${AGENTS[@]}"; do
    echo "  - $agent"
done
echo ""
print_success "Deployment completed successfully!"
echo ""
echo "You can now use these skills and agents in Claude Code."
echo "Skills: Invoke with /auto-novel, /novel-planning, /novel-chapter"
echo "Agents: Available in .claude/agents/"
echo ""
