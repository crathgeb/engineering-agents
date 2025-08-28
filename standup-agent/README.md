# Daily Standup Agent

This tool automates your daily standup preparation by fetching GitHub activity and generating professional scrum summaries using Claude AI. Get perfectly formatted standup updates with just one command!

## Features

- **🔄 Complete automation** - One command does everything
- **📊 GitHub activity tracking** - Fetches commits and PRs from last 24 hours  
- **🤖 AI-powered summaries** - Uses Claude to generate professional scrum updates
- **📋 Console output** - Displays formatted summary ready for copy-paste
- **🎨 Colorized output** - Beautiful terminal interface with progress tracking
- **📁 Multi-repo support** - Handles multiple repositories via JSON configuration
- **📝 Detailed reports** - Generates individual markdown reports per repository

## Prerequisites

### Required Tools

1. **GitHub CLI (gh)**: Install and authenticate with GitHub
   ```bash
   # macOS
   brew install gh
   
   # Ubuntu/Debian
   sudo apt install gh
   
   # Authenticate
   gh auth login
   ```

2. **Claude CLI**: Install for AI-powered summary generation
   ```bash
   # Install Claude CLI
   npm install -g @anthropic-ai/claude-cli
   
   # Or download from: https://claude.ai/cli
   ```

3. **jq**: JSON processor for parsing configuration
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt-get install jq
   ```

## Setup

1. **Configure your repositories** in `repos.config.json`:
   ```json
   {
     "repositories": [
       {
         "name": "my-project",
         "owner": "myusername",
         "repo": "my-project"
       },
       {
         "name": "company-app",
         "owner": "mycompany", 
         "repo": "company-app"
       }
     ],
     "settings": {
       "github_username": "your-github-username"
     }
   }
   ```

2. **Make the agent executable**:
   ```bash
   chmod +x agent.sh
   ```

## Usage

### 🚀 Quick Start - Complete Workflow

Run the complete automated standup workflow:

```bash
./agent.sh
```

This single command will:
1. **Clear build directory** - Fresh start for new reports
2. **Fetch GitHub activity** - Get latest commits and PRs from all configured repos
3. **Generate Claude prompt** - Combine activity data with AI prompt template
4. **Generate scrum summary** - Use Claude to create professional standup update
5. **Display results** - Show formatted summary in console ready for copy-paste

### Individual Scripts (Advanced)

If you need to run parts of the workflow separately:

```bash
# Fetch GitHub activity only
./scripts/fetch-daily-activity.sh

# Generate prompt file for Claude
./scripts/generate-summary-prompt.sh

# Generate final summary (requires prompt file)
./scripts/generate-scrum-summary.sh
```

## Output Files

The agent creates several files in the `./build/` directory:

- **`{repo-name}_{YYYY-MM-DD}.md`** - Individual activity reports per repository
- **`summary-prompt.md`** - Combined prompt and data for Claude
- **`summary.txt`** - Final scrum summary (also displayed in console)

## Individual Activity Reports

Each repository generates a detailed markdown report:

```markdown
# Daily Activity Report - my-project
**Repository:** myusername/my-project
**Date:** 2025-08-28
**User:** myusername

## Commits in myusername/my-project

- **abc1234** - Fix bug in user authentication (2025-08-28 09:30)
- **def5678** - Add new feature for dashboard (2025-08-28 14:15)

## Pull Requests Created in myusername/my-project

- **#123** - Fix authentication bug [open] (2025-08-28 09:45)
  ```
  This PR fixes the authentication issue by updating the JWT token validation.
  
  - Updated token validation logic
  - Added error handling for expired tokens
  - Updated tests
  ```

## Pull Requests Involved in myusername/my-project

- **#124** - Update dependencies [merged] - reviewer (2025-08-28 11:20)
```

## Testing

To test with public repositories:

```bash
# Copy the example config
cp repos.config.example.json repos.config.json

# Update your GitHub username in the config
# Then run the agent
./agent.sh
```

## Troubleshooting

### GitHub Issues
1. **"GitHub CLI is not authenticated"**: 
   ```bash
   gh auth login
   ```

2. **"Repository not found"**: 
   - Check repository name and owner are correct
   - Ensure you have access to the repositories
   - Verify authentication: `gh auth status`

### Claude Issues
3. **"Claude CLI not found"**: 
   ```bash
   # Install Claude CLI
   npm install -g @anthropic-ai/claude-cli
   ```

4. **"Failed to generate scrum summary"**: 
   - Ensure Claude CLI is properly configured
   - Check your Claude AI subscription/credits
   - Verify the prompt file was generated correctly

### General Issues
5. **"jq is required but not installed"**: 
   ```bash
   # macOS
   brew install jq
   # Ubuntu/Debian
   sudo apt-get install jq
   ```

6. **"Permission denied"**: 
   ```bash
   chmod +x agent.sh
   chmod +x scripts/*.sh
   ```

7. **"No activity found"**: Normal if you haven't made commits or PR activity in the last 24 hours

## Automation

Schedule the agent to run daily using cron:

```bash
# Add to crontab (run daily at 9 AM)
0 9 * * * cd /path/to/standup-agent && ./agent.sh > /tmp/standup-$(date +\%Y-\%m-\%d).log 2>&1
```

## Configuration Details

### Repository Configuration
- **`name`**: Friendly name for the repository (used in filenames and summaries)
- **`owner`**: GitHub username or organization name
- **`repo`**: Repository name

### Settings Configuration  
- **`github_username`**: Your GitHub username (auto-detected if not provided)

## Customization

The agent is designed to be easily customizable:

- **Modify date range**: Update `get_since_date()` in `fetch-daily-activity.sh`
- **Customize output format**: Edit the fetch functions in the same script
- **Update AI prompt**: Modify `prompts/generate-summary.md`
- **Add more repositories**: Update `repos.config.json`
- **Change summary format**: Update the Claude prompt template

## File Structure

```
standup-agent/
├── agent.sh                          # Main workflow script
├── repos.config.json                 # Your repository configuration
├── repos.config.example.json         # Example configuration
├── scripts/
│   ├── fetch-daily-activity.sh       # GitHub activity fetcher
│   ├── generate-summary-prompt.sh    # Claude prompt generator
│   └── generate-scrum-summary.sh     # Claude summary generator
├── prompts/
│   └── generate-summary.md           # AI prompt template
└── build/                            # Generated reports (auto-created)
    ├── {repo-name}_{date}.md         # Individual activity reports
    ├── summary-prompt.md             # Combined prompt for Claude
    └── summary.txt                   # Final scrum summary
```

## Contributing

Feel free to submit issues and enhancement requests! The agent is built with modularity in mind, making it easy to extend with additional features.