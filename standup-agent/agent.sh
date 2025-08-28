#!/bin/bash

# Complete Daily Standup Workflow
# 1. Fetch GitHub activity
# 2. Generate scrum input for Claude

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Daily Standup Workflow${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step: 0
echo -e "${YELLOW}[STEP 0]${NC} Clearing build directory..."
rm -rf "$SCRIPT_DIR/../build"
mkdir -p "$SCRIPT_DIR/../build"
echo ""

# Step 1: Fetch GitHub Activity
echo -e "${YELLOW}[STEP 1]${NC} Fetching GitHub activity..."
if ! "$SCRIPT_DIR/fetch-daily-activity.sh"; then
    echo -e "${RED}[ERROR]${NC} Failed to fetch GitHub activity"
    exit 1
fi
echo ""

# Step 2: Generate Summary Prompt
echo -e "${YELLOW}[STEP 2]${NC} Generating summary prompt..."
if ! "$SCRIPT_DIR/generate-summary-prompt.sh"; then
    echo -e "${RED}[ERROR]${NC} Failed to generate summary prompt"
    exit 1
fi
echo ""

# Step 3: Generate Scrum Summary
echo -e "${YELLOW}[STEP 3]${NC} Generating scrum summary with Claude..."
if ! "$SCRIPT_DIR/generate-scrum-summary.sh"; then
    echo -e "${RED}[ERROR]${NC} Failed to generate scrum summary"
    exit 1
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    Workflow Complete! ✅${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Summary available at: ./build/summary.txt${NC}"
echo ""

# Display the final summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    📋 DAILY SCRUM SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
cat "$SCRIPT_DIR/../build/summary.txt"
echo ""
echo -e "${BLUE}========================================${NC}"

