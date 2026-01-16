#!/bin/bash
# Deploy Claude Code configuration to ~/.claude
# Run from the claude-code-mastery directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Deploying Claude Code configuration..."
echo "Source: $SCRIPT_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Create directories
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/skills"

# Deploy global CLAUDE.md
echo "→ Deploying global CLAUDE.md..."
cp "$SCRIPT_DIR/templates/global-claude.md" "$CLAUDE_DIR/CLAUDE.md"

# Deploy settings.json (with pnpm-only permissions)
echo "→ Deploying settings.json..."
cat > "$CLAUDE_DIR/settings.json" << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/block-secrets.py"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-commands.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/after-edit.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/end-of-turn.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify.sh"
          }
        ]
      }
    ]
  },
  "permissions": {
    "deny": [
      "Read(./.env*)",
      "Read(./secrets/**)",
      "Bash(rm:-rf)",
      "Bash(curl:*)",
      "Bash(npm:*)",
      "Bash(yarn:*)",
      "Bash(bun:*)"
    ],
    "allow": [
      "Read(./.env.example)",
      "Bash(git:*)",
      "Bash(pnpm:*)",
      "Bash(make:*)",
      "Bash(docker:*)"
    ]
  }
}
EOF

# Deploy commands
echo "→ Deploying commands..."
for cmd in "$SCRIPT_DIR/commands"/*.md; do
    if [ -f "$cmd" ] && [ "$(basename "$cmd")" != "README.md" ]; then
        cp "$cmd" "$CLAUDE_DIR/commands/"
        echo "  - $(basename "$cmd")"
    fi
done

# Deploy hooks
echo "→ Deploying hooks..."
for hook in "$SCRIPT_DIR/hooks"/*; do
    if [ -f "$hook" ]; then
        cp "$hook" "$CLAUDE_DIR/hooks/"
        chmod +x "$CLAUDE_DIR/hooks/$(basename "$hook")"
        echo "  - $(basename "$hook")"
    fi
done

# Deploy skills
echo "→ Deploying skills..."
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "$CLAUDE_DIR/skills/$skill_name"
        cp -r "$skill_dir"* "$CLAUDE_DIR/skills/$skill_name/"
        echo "  - $skill_name/"
    fi
done

echo ""
echo "Deployment complete!"
echo ""
echo "Installed:"
echo "  ~/.claude/CLAUDE.md          (global instructions)"
echo "  ~/.claude/settings.json      (hooks & permissions)"
echo "  ~/.claude/commands/          (slash commands)"
echo "  ~/.claude/hooks/             (enforcement scripts)"
echo "  ~/.claude/skills/            (packaged expertise)"
echo ""
echo "Note: Restart Claude Code for changes to take effect."
