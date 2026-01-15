# Contributing to WebStats

Thank you for considering contributing to WebStats! We welcome contributions from everyone. Here's how you can help.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

1. **Search existing issues** - Check if the bug has already been reported
2. **Create a new issue** - Include:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (Node.js version, OS, etc.)
   - Screenshots if applicable

### Suggesting Features

1. **Check existing suggestions** - Look for similar feature requests
2. **Create a feature request** - Include:
   - Clear description of the feature
   - Use cases and benefits
   - Potential implementation approaches
   - Any relevant examples

### Improving Documentation

1. **Fix typos and grammatical errors**
2. **Clarify confusing sections**
3. **Add examples and tutorials**
4. **Improve API documentation**

### Contributing Code

#### Setup Instructions
```bash
# Fork the repository
# Clone your fork
git clone https://github.com/YOUR_USERNAME/webstats.git
cd webstats

# Install dependencies
pnpm install

# Create a new branch
git checkout -b feature/your-feature-name
```

#### Development Workflow
1. **Create a feature branch** from `main`
2. **Make your changes** following code standards
3. **Test your changes** thoroughly
4. **Commit your changes** with clear commit messages
5. **Push to your fork** and create a pull request

#### Code Standards
- Follow existing code style and patterns
- Write clear, descriptive commit messages
- Include tests for new functionality
- Update documentation as needed
- Keep pull requests focused on a single issue/feature

## Development Guidelines

### TypeScript Standards
- Use strict TypeScript settings
- Include JSDoc for exported functions
- Follow established naming conventions
- Handle errors appropriately

### UI/UX Guidelines
- Maintain terminal-core aesthetic
- Ensure responsive design
- Follow accessibility best practices
- Keep user experience intuitive

### Testing
- Test manually since no automated tests exist yet
- Verify data generation and display
- Check cross-browser compatibility
- Test on different screen sizes

## Pull Request Process

1. **Ensure your PR description clearly describes the problem and solution**
2. **Include any relevant issue numbers**
3. **Follow the template provided**
4. **Make sure all tests pass** (manual verification for now)
5. **Request review from maintainers**

### Pull Request Template
```
## Summary
- Brief description of changes
- Related issues (if any)

## Changes Made
- List of changes
- New features or fixes

## Testing
- How changes were tested
- Test results
```

## Development Environment

### Required Tools
- Node.js (v18+)
- pnpm package manager
- Git
- Text editor or IDE

### Setup Commands
```bash
# Install dependencies
pnpm install

# Start development servers
pnpm dev

# Build the project
pnpm build

# Run monitoring locally
node apps/runner/dist/index.js
```

## Areas Needing Help

### Immediate Needs
- Automated testing implementation
- Additional monitoring protocols (TCP, DNS, SSL)
- Advanced alerting systems
- Mobile app development
- Internationalization support

### Long-term Goals
- Dashboard customization
- Advanced analytics
- Multi-location monitoring
- Integration with notification services
- API for external integrations

## Style Guides

### Git Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests after a blank line

### TypeScript Style
- Use PascalCase for classes and interfaces
- Use camelCase for variables and functions
- Use UPPER_SNAKE_CASE for constants
- Include type annotations where beneficial

### Documentation Style
- Use Markdown for documentation
- Keep sentences short and clear
- Use active voice
- Include code examples where helpful

## Getting Help

### Questions
- Check the documentation first
- Search existing issues
- Create a new issue for help requests

### Community
- GitHub Discussions (when available)
- Issue comments for specific topics
- Email for sensitive matters

## Recognition

Contributors will be recognized in:
- Release notes
- Contributors list
- README acknowledgment
- GitHub contributors graph

Thank you for contributing to WebStats! Your efforts help make this project better for everyone.