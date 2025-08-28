#!/bin/bash

# Daily GitHub Activity Fetcher
# Reads repositories from repos.config.json and fetches recent activity

set -e  # Exit on any error

# Configuration
CONFIG_FILE="repos.config.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="$SCRIPT_DIR/../$CONFIG_FILE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Please install it first."
        echo "  macOS: brew install jq"
        echo "  Ubuntu: sudo apt-get install jq"
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is required but not installed. Please install it first."
        echo "  macOS: brew install gh"
        echo "  Ubuntu: sudo apt install gh"
        echo "  Then run: gh auth login"
        exit 1
    fi
    
    # Check if GitHub CLI is authenticated
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated. Please run: gh auth login"
        exit 1
    fi
    
    log_success "All dependencies are available"
}

# Check if config file exists
check_config() {
    if [[ ! -f "$CONFIG_PATH" ]]; then
        log_error "Configuration file not found: $CONFIG_PATH"
        log_info "Please create a repos.config.json file with your repository configuration"
        exit 1
    fi
    
    # Validate JSON syntax
    if ! jq . "$CONFIG_PATH" > /dev/null 2>&1; then
        log_error "Invalid JSON in configuration file: $CONFIG_PATH"
        exit 1
    fi
    
    log_success "Configuration file is valid"
}

# Get the current git user
get_git_user() {
    local github_username
    github_username=$(jq -r '.settings.github_username // empty' "$CONFIG_PATH")
    
    if [[ -z "$github_username" || "$github_username" == "null" ]]; then
        # Try to get from git config
        github_username=$(git config user.name 2>/dev/null || echo "")
        if [[ -z "$github_username" ]]; then
            # Try to get from GitHub CLI
            github_username=$(gh api user --jq '.login' 2>/dev/null || echo "")
        fi
    fi
    
    if [[ -z "$github_username" ]]; then
        log_error "Could not determine GitHub username. Please set 'github_username' in repos.config.json"
        exit 1
    fi
    
    echo "$github_username"
}

# Calculate date 24 hours ago in ISO format
get_since_date() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -u -v-1d +"%Y-%m-%dT%H:%M:%SZ"
    else
        # Linux
        date -u -d "24 hours ago" +"%Y-%m-%dT%H:%M:%SZ"
    fi
}

# Fetch commits for a repository
fetch_commits() {
    local owner="$1"
    local repo="$2"
    local username="$3"
    local since_date="$4"
    local output_file="$5"
    
    log_info "Fetching commits for $owner/$repo since $since_date..."
    
    # Fetch commits using GitHub API
    local commits_json
    local api_response
    api_response=$(gh api "repos/$owner/$repo/commits?since=$since_date" 2>&1)
    
    # Check if the API call was successful
    if echo "$api_response" | grep -q "^gh: Not Found\|^gh: Forbidden\|\"message\": \"Not Found\""; then
        log_warning "Repository $owner/$repo not found or not accessible"
        return 1
    elif echo "$api_response" | head -1 | grep -q "^gh: "; then
        local error_msg=$(echo "$api_response" | head -1 | sed 's/^gh: //')
        log_warning "API error accessing $owner/$repo: $error_msg"
        return 1
    else
        commits_json="$api_response"
    fi
    
    if [[ "$commits_json" != "[]" && -n "$commits_json" && "$commits_json" != "null" ]]; then
        # Filter commits by author
        local user_commits
        user_commits=$(echo "$commits_json" | jq --arg username "$username" \
            '[.[] | select(.commit.author.name == $username or (.commit.author.email | contains($username)) or .author.login == $username)]' 2>/dev/null || echo "[]")
        
        local commit_count
        commit_count=$(echo "$user_commits" | jq 'length' 2>/dev/null | tr -d '\n' || echo "0")
        
        if [[ "${commit_count:-0}" -gt 0 ]]; then
            echo "## Commits in $owner/$repo" >> "$output_file"
            echo "" >> "$output_file"
            echo "$user_commits" | jq -r '.[] | "- **" + (.sha[0:7]) + "** - " + (.commit.message | split("\n")[0]) + " (" + (.commit.author.date | sub("T"; " ") | sub("Z$"; "")) + ")"' >> "$output_file"
            echo "" >> "$output_file"
            return 0
        fi
    fi
    
    log_info "No commits found for $username in $owner/$repo"
    return 1
}

# Fetch pull requests for a repository
fetch_pull_requests() {
    local owner="$1"
    local repo="$2"
    local username="$3"
    local since_date="$4"
    local output_file="$5"
    
    log_info "Fetching pull requests for $owner/$repo..."
    
    # Fetch PRs created by the user
    local prs_created_json
    local api_response
    api_response=$(gh api "repos/$owner/$repo/pulls?state=all&sort=created&direction=desc" 2>&1)
    
    # Check if the API call was successful
    if echo "$api_response" | grep -q "^gh: Not Found\|^gh: Forbidden\|\"message\": \"Not Found\""; then
        log_warning "Repository $owner/$repo not found or not accessible"
        return 1
    elif echo "$api_response" | head -1 | grep -q "^gh: "; then
        local error_msg=$(echo "$api_response" | head -1 | sed 's/^gh: //')
        log_warning "API error accessing $owner/$repo: $error_msg"
        return 1
    else
        prs_created_json="$api_response"
    fi
    
    # Filter PRs created by user and within date range
    local prs_created
    if [[ "$prs_created_json" != "[]" ]]; then
        prs_created=$(echo "$prs_created_json" | jq --arg username "$username" --arg since "$since_date" \
            '[.[] | select(.user.login == $username) | select(.created_at >= $since)]' 2>/dev/null || echo "[]")
    else
        prs_created="[]"
    fi
    
    # Fetch PRs where user was assigned or requested for review (reuse same data)
    local prs_involved_json="$prs_created_json"
    
    # Filter PRs where user is involved and within date range
    local prs_involved
    if [[ "$prs_involved_json" != "[]" ]]; then
        prs_involved=$(echo "$prs_involved_json" | jq --arg username "$username" --arg since "$since_date" \
            '[.[] | select(.updated_at >= $since) | select((.assignees[]?.login == $username) or (.requested_reviewers[]?.login == $username) or (.user.login == $username)) | . + {involvement: (if .user.login == $username then "author" elif (.assignees[]?.login == $username) then "assignee" elif (.requested_reviewers[]?.login == $username) then "reviewer" else "involved" end)}]' 2>/dev/null || echo "[]")
    else
        prs_involved="[]"
    fi
    
    local has_prs=false
    
    # Check if we have created PRs
    local created_count
    created_count=$(echo "$prs_created" | jq 'length' 2>/dev/null | tr -d '\n' || echo "0")
    if [[ "${created_count:-0}" -gt 0 ]]; then
        echo "## Pull Requests Created in $owner/$repo" >> "$output_file"
        echo "" >> "$output_file"
        
        # Process each PR individually to include descriptions
        local pr_index=0
        local total_prs
        total_prs=$(echo "$prs_created" | jq 'length')
        
        while [[ $pr_index -lt $total_prs ]]; do
            local pr_number pr_title pr_state pr_date pr_body
            pr_number=$(echo "$prs_created" | jq -r ".[$pr_index].number")
            pr_title=$(echo "$prs_created" | jq -r ".[$pr_index].title")
            pr_state=$(echo "$prs_created" | jq -r ".[$pr_index].state")
            pr_date=$(echo "$prs_created" | jq -r ".[$pr_index].created_at | sub(\"T\"; \" \") | sub(\"Z$\"; \"\")")
            pr_body=$(echo "$prs_created" | jq -r ".[$pr_index].body // \"\"")
            
            # Write PR header
            echo "### **#$pr_number** - $pr_title [$pr_state]" >> "$output_file"
            echo "**Created:** $pr_date" >> "$output_file"
            echo "" >> "$output_file"
            
            # Add description if it exists
            if [[ -n "$pr_body" && "$pr_body" != "null" && "$pr_body" != "" ]]; then
                echo "**Description:**" >> "$output_file"
                echo '```' >> "$output_file"
                echo "$pr_body" >> "$output_file"
                echo '```' >> "$output_file"
            else
                echo "*No description provided*" >> "$output_file"
            fi
            echo "" >> "$output_file"
            echo "---" >> "$output_file"
            echo "" >> "$output_file"
            
            pr_index=$((pr_index + 1))
        done
        
        has_prs=true
    fi
    
    # Check if we have involved PRs  
    local involved_count
    involved_count=$(echo "$prs_involved" | jq 'length' 2>/dev/null | tr -d '\n' || echo "0")
    if [[ "${involved_count:-0}" -gt 0 ]]; then
        echo "## Pull Requests Involved in $owner/$repo" >> "$output_file"
        echo "" >> "$output_file"
        
        # Process each PR individually to include descriptions
        local pr_index=0
        local total_prs
        total_prs=$(echo "$prs_involved" | jq 'length')
        
        while [[ $pr_index -lt $total_prs ]]; do
            local pr_number pr_title pr_state pr_date pr_body pr_involvement
            pr_number=$(echo "$prs_involved" | jq -r ".[$pr_index].number")
            pr_title=$(echo "$prs_involved" | jq -r ".[$pr_index].title")
            pr_state=$(echo "$prs_involved" | jq -r ".[$pr_index].state")
            pr_date=$(echo "$prs_involved" | jq -r ".[$pr_index].updated_at | sub(\"T\"; \" \") | sub(\"Z$\"; \"\")")
            pr_body=$(echo "$prs_involved" | jq -r ".[$pr_index].body // \"\"")
            pr_involvement=$(echo "$prs_involved" | jq -r ".[$pr_index].involvement")
            
            # Write PR header
            echo "### **#$pr_number** - $pr_title [$pr_state] - $pr_involvement" >> "$output_file"
            echo "**Updated:** $pr_date" >> "$output_file"
            echo "" >> "$output_file"
            
            # Add description if it exists
            if [[ -n "$pr_body" && "$pr_body" != "null" && "$pr_body" != "" ]]; then
                echo "**Description:**" >> "$output_file"
                echo '```' >> "$output_file"
                echo "$pr_body" >> "$output_file"
                echo '```' >> "$output_file"
            else
                echo "*No description provided*" >> "$output_file"
            fi
            echo "" >> "$output_file"
            echo "---" >> "$output_file"
            echo "" >> "$output_file"
            
            pr_index=$((pr_index + 1))
        done
        
        has_prs=true
    fi
    
    if [[ "$has_prs" == "true" ]]; then
        return 0
    else
        log_info "No pull requests found for $username in $owner/$repo"
        return 1
    fi
}

# Main function
main() {
    log_info "Starting daily GitHub activity fetch..."
    
    # Check dependencies and config
    check_dependencies
    check_config
    
    # Get configuration values
    local github_username
    github_username=$(get_git_user)
    log_info "Fetching activity for user: $github_username"
    
    local output_dir
    output_dir="$SCRIPT_DIR/../build"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Get date 24 hours ago
    local since_date
    since_date=$(get_since_date)
    log_info "Fetching activity since: $since_date"
    
    # Get current date for filename
    local current_date
    current_date=$(date +"%Y-%m-%d")
    
    # Process each repository
    local repositories
    repositories=$(jq -c '.repositories[]' "$CONFIG_PATH")
    
    local total_repos=0
    local processed_repos=0
    
    while IFS= read -r repo_config; do
        total_repos=$((total_repos + 1))
    done <<< "$repositories"
    
    while IFS= read -r repo_config; do
        local name owner repo_name
        name=$(echo "$repo_config" | jq -r '.name')
        owner=$(echo "$repo_config" | jq -r '.owner')
        repo_name=$(echo "$repo_config" | jq -r '.repo')
        
        processed_repos=$((processed_repos + 1))
        log_info "Processing repository $processed_repos/$total_repos: $name ($owner/$repo_name)"
        
        # Create output file for this repository
        local output_file="$output_dir/${name}_${current_date}.md"
        
        # Initialize the output file
        echo "# Daily Activity Report - $name" > "$output_file"
        echo "**Repository:** $owner/$repo_name" >> "$output_file"
        echo "**Date:** $current_date" >> "$output_file"
        echo "**User:** $github_username" >> "$output_file"
        echo "" >> "$output_file"
        
        # Fetch commits and PRs
        local has_commits=false
        local has_prs=false
        local commits_exit_code=0
        local prs_exit_code=0
        
        if fetch_commits "$owner" "$repo_name" "$github_username" "$since_date" "$output_file"; then
            has_commits=true
        else
            commits_exit_code=$?
        fi
        
        if fetch_pull_requests "$owner" "$repo_name" "$github_username" "$since_date" "$output_file"; then
            has_prs=true
        else
            prs_exit_code=$?
        fi
        
        # Handle different scenarios
        if [[ $commits_exit_code -eq 1 && $prs_exit_code -eq 1 ]]; then
            echo "## Repository Access Error" >> "$output_file"
            echo "" >> "$output_file"
            echo "Unable to access repository $owner/$repo_name. Please check:" >> "$output_file"
            echo "- Repository exists and is public, or you have access to it" >> "$output_file"
            echo "- Your GitHub CLI authentication is working (run \`gh auth status\`)" >> "$output_file"
            echo "- Repository name and owner are spelled correctly" >> "$output_file"
            log_error "Could not access repository $name"
        elif [[ "$has_commits" == "false" && "$has_prs" == "false" ]]; then
            echo "## No Activity Found" >> "$output_file"
            echo "" >> "$output_file"
            echo "No commits or pull requests found for $github_username in the last 24 hours." >> "$output_file"
            log_warning "No activity found for $name"
        else
            log_success "Activity report generated: $output_file"
        fi
        
        echo "" >> "$output_file"
        echo "---" >> "$output_file"
        echo "*Report generated on $(date)*" >> "$output_file"
        
    done <<< "$repositories"
    
    log_success "Completed processing $processed_repos repositories"
    log_info "Reports saved to: $output_dir"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
