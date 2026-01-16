# Claude Code Commands

Ready-to-use slash commands for Claude Code. Copy these to your project or global commands directory.

## Installation

### Per-Project (Recommended)

Copy commands to your project's `.claude/commands/` directory:

```bash
# From your project root
mkdir -p .claude/commands
cp path/to/claude-code-mastery/commands/*.md .claude/commands/
```

Commands will be available in that project only.

### Global (All Projects)

Copy to your global commands directory:

```bash
mkdir -p ~/.claude/commands
cp path/to/claude-code-mastery/commands/*.md ~/.claude/commands/
```

Commands will be available in all projects.

## Available Commands

| Command | Description |
|---------|-------------|
| `/new-project` | Create a new monorepo project with standard structure |
| `/review` | Review code changes for bugs, security issues, and improvements |
| `/explain` | Explain code in detail — what it does, how it works, and why |
| `/test` | Generate tests for code — unit tests, integration tests, edge cases |
| `/pr` | Generate a pull request description from branch changes |

## Usage

Simply type the command in Claude Code:

```
/review
```

Some commands accept arguments:

```
/explain src/auth/jwt.ts
/explain src/auth/jwt.ts:45-80
/test --edge
```

## Customization

These commands are markdown files. Feel free to:

1. **Modify** — Edit the prompts to match your team's style
2. **Extend** — Add new sections or checklists
3. **Combine** — Create new commands that chain these together

### Example: Custom Review Command

```markdown
---
description: Team-specific code review
---

Run the standard review, but also check:
- [ ] Follows our naming conventions (camelCase for functions)
- [ ] Uses our logger, not console.log
- [ ] Database queries use our query builder

[Include rest of review.md content...]
```

## Command Structure

Each command file has:

```markdown
---
description: Short description shown in command list
---

# Command Name

[Detailed instructions for Claude...]
```

The `description` frontmatter is required — it's what appears when you type `/` to see available commands.

## Contributing

Have a useful command? Contributions welcome:

1. Create a new `.md` file in this directory
2. Include frontmatter with `description`
3. Write clear, specific instructions
4. Submit a PR

## License

MIT — use these however you like.
