# Engineering Agents Collection

A curated collection of AI-powered automation agents designed to streamline common engineering workflows and boost developer productivity.

## 🤖 Available Agents

### [Standup Agent](./standup-agent/)
**Automate your daily standup preparation**

- 🔄 **Complete automation** - One command generates your entire standup summary
- 📊 **GitHub activity tracking** - Fetches commits and PRs from the last 24 hours  
- 🤖 **AI-powered summaries** - Uses Claude AI to generate professional scrum updates
- 📋 **Ready-to-share format** - Console output optimized for copy-paste into Slack/Teams
- 📁 **Multi-repo support** - Handles multiple repositories via JSON configuration
- 🎨 **Beautiful terminal interface** - Colorized progress tracking and formatted output

Perfect for engineers who want to spend less time writing standup updates and more time coding.

[→ Get started with Standup Agent](./standup-agent/README.md)

## 🚀 Quick Start

Each agent is self-contained with its own setup instructions. Navigate to the agent directory and follow the README:

```bash
# Example: Set up the Standup Agent
cd standup-agent
chmod +x agent.sh
./agent.sh
```

## 📋 Prerequisites

Most agents in this collection use common tools:

- **GitHub CLI (gh)** - For repository interactions
- **Claude CLI** - For AI-powered text generation  
- **jq** - For JSON processing
- **Standard shell tools** - bash, curl, git

Specific requirements are detailed in each agent's documentation.

## 🛠 Common Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd agents
   ```

2. **Choose an agent** and follow its specific setup instructions

3. **Configure your environment** as needed per agent requirements

## 🎯 Use Cases

These agents are designed for engineering teams and individual developers who want to:

- **Automate repetitive tasks** - Save time on routine workflows
- **Improve consistency** - Standardize output formats across teams
- **Enhance productivity** - Focus on coding instead of administrative tasks
- **Leverage AI assistance** - Get intelligent summaries and insights
- **Integrate with existing tools** - Work seamlessly with GitHub, Slack, and other platforms

## 🔧 Architecture

Each agent follows a modular design pattern:

- **Main script** (`agent.sh`) - Entry point and workflow orchestration
- **Scripts directory** - Individual task automation scripts
- **Configuration files** - JSON-based settings for customization
- **Build directory** - Generated outputs and reports
- **Prompts directory** - AI prompt templates

This structure makes agents easy to understand, modify, and extend.

## 📁 Repository Structure

```
agents/
├── README.md                 # This file
├── LICENSE                   # MIT License
├── standup-agent/           # Daily standup automation
│   ├── README.md
│   ├── agent.sh
│   ├── scripts/
│   ├── prompts/
│   └── build/
└── [future-agents]/         # Additional agents will be added here
```

## 🤝 Contributing

We welcome contributions! Whether you want to:

- **Improve existing agents** - Bug fixes, feature enhancements, documentation
- **Add new agents** - Create automation for new engineering workflows
- **Share feedback** - Report issues or suggest improvements

### Contributing Guidelines

1. **Fork the repository** and create a feature branch
2. **Follow the established patterns** - Use the standup-agent as a reference
3. **Include comprehensive documentation** - README with setup, usage, and examples
4. **Test thoroughly** - Ensure your agent works across different environments
5. **Submit a pull request** - Describe your changes and their benefits

### New Agent Structure

When creating new agents, please follow this structure:

```
your-agent/
├── README.md              # Comprehensive documentation
├── agent.sh               # Main entry point
├── scripts/               # Individual automation scripts
├── prompts/               # AI prompt templates (if applicable)
├── config.example.json    # Example configuration
└── build/                 # Generated outputs (auto-created)
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔮 Roadmap

Future agents under consideration:

- **Code Review Agent** - Automated code review summaries and insights
- **Documentation Agent** - Generate and maintain technical documentation
- **Release Agent** - Automate release notes and deployment summaries
- **Testing Agent** - Test result analysis and reporting automation
- **Incident Response Agent** - Post-mortem and incident report generation

## 💡 Ideas and Feedback

Have an idea for a new agent or improvement? We'd love to hear from you!

- **Open an issue** to discuss new agent ideas
- **Share your use cases** to help us prioritize development
- **Contribute feedback** on existing agents

---

**Built for engineers, by engineers.** 🚀

These agents are designed to eliminate the tedious parts of engineering workflows, letting you focus on what you do best - building amazing software.
