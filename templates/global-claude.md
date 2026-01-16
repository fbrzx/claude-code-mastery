# Global CLAUDE.md

This file applies to ALL your projects. Define your identity, security rules, and scaffolding standards once.

## Identity & Accounts

- **Git**: Local repositories only (no GitHub/GitLab remote access)
- **Docker Hub**: authenticated via `~/.docker/config.json`

> **Note**: This configuration is for local-only development workflows.

---

## NEVER EVER DO (Security Gatekeeper)

These rules are **ABSOLUTE**. No exceptions.

### NEVER Publish Sensitive Data
- ❌ NEVER commit passwords, API keys, tokens to git/npm/docker
- ❌ NEVER hardcode credentials in source files
- ❌ NEVER include secrets in error messages or logs

### NEVER Commit .env Files
- ❌ NEVER commit `.env` to git
- ✅ ALWAYS verify `.env` is in `.gitignore`
- ✅ ALWAYS use `.env.example` with placeholder values

### NEVER Skip Verification
- Before ANY commit: verify no secrets included
- Before ANY push: check staged files for sensitive data
- Before ANY publish: audit package contents

### NEVER Use Wrong Package Manager
- ❌ NEVER use npm, yarn, or bun
- ✅ ALWAYS use pnpm
- ✅ ALWAYS use `pnpm-workspace.yaml` for monorepo configuration

### NEVER Create Markdown Files Outside .claude/docs
- ❌ NEVER create new `*.md` files anywhere except `.claude/docs/`
- ✅ ALWAYS place new documentation in `.claude/docs/`
- ✅ You MAY edit existing markdown files (README.md, CLAUDE.md, etc.)
- ✅ Exception: CLAUDE.md and README.md at project root are allowed

---

## New Project Setup (Scaffolding Rules)

When creating ANY new project, ALWAYS do the following:

### 1. Required Files (Create Immediately)

| File | Purpose | Notes |
|------|---------|-------|
| `.env` | Environment variables | NEVER commit |
| `.env.example` | Template with placeholders | Commit this |
| `.gitignore` | Ignore patterns | Must include .env |
| `.dockerignore` | Docker ignore patterns | Mirror .gitignore |
| `README.md` | Project overview | Reference env vars, don't hardcode |
| `CLAUDE.md` | Project instructions | Required sections below |
| `pnpm-workspace.yaml` | Monorepo workspace config | Required for all projects |
| `docker-compose.yml` | Local infrastructure | Standard services below |

### 2. Required Monorepo Structure

```
project-root/
├── apps/              # Frontend applications (Next.js, etc.)
│   └── web/           # Example: main web app
├── services/          # Backend services (APIs, workers)
│   └── api/           # Example: main API service
├── packages/          # Shared libraries
│   ├── ui/            # Shared UI components
│   ├── db/            # Database schemas/clients
│   └── config/        # Shared configurations
├── docs/              # Documentation
├── .claude/           # Claude configuration
│   ├── commands/      # Custom slash commands
│   ├── docs/          # Claude-generated documentation (only place for new *.md)
│   ├── skills/        # Project-specific skills
│   └── settings.json  # Project settings
├── scripts/           # Build/deploy scripts
├── docker-compose.yml # Local infrastructure
└── pnpm-workspace.yaml
```

### 3. Required pnpm-workspace.yaml

```yaml
packages:
  - 'apps/*'
  - 'services/*'
  - 'packages/*'
```

### 4. Required docker-compose.yml (Local Infrastructure)

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: app
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dev"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  mailpit:
    image: axllent/mailpit
    ports:
      - "1025:1025"   # SMTP
      - "8025:8025"   # Web UI
    environment:
      MP_SMTP_AUTH_ACCEPT_ANY: 1
      MP_SMTP_AUTH_ALLOW_INSECURE: 1

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"   # API
      - "9001:9001"   # Console
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio_data:/data
    healthcheck:
      test: ["CMD", "mc", "ready", "local"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

### 5. Required .env.example

```bash
# Database
DATABASE_URL=postgresql://dev:dev@localhost:5432/app

# Redis
REDIS_URL=redis://localhost:6379

# Mail (Mailpit)
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_FROM=noreply@localhost

# Object Storage (MinIO)
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=uploads
```

### 6. Required .gitignore Entries

```gitignore
# Environment
.env
.env.*
.env.local
!.env.example

# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
.next/
.turbo/

# Claude local files
.claude/settings.local.json
CLAUDE.local.md

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Docker volumes (if local)
.docker/
```

### 7. Required CLAUDE.md Sections

Every project `CLAUDE.md` must include:

```markdown
# Project Name

## Overview
[What this project does]

## Tech Stack
- Runtime: Node.js
- Package Manager: pnpm (REQUIRED)
- Framework: [e.g., Next.js, Fastify]
- Database: PostgreSQL (via docker-compose)
- Cache: Redis (via docker-compose)
- Mail: Mailpit (via docker-compose)
- Storage: MinIO (via docker-compose)

## Monorepo Structure
- `apps/` — Frontend applications
- `services/` — Backend services
- `packages/` — Shared libraries

## Commands
- `pnpm install` — Install all dependencies
- `pnpm dev` — Start development (all workspaces)
- `pnpm build` — Build all packages
- `pnpm test` — Run tests
- `pnpm lint` — Check code style
- `docker compose up -d` — Start local infrastructure

## Environment Variables
[List required env vars WITHOUT values - see .env.example]
```

---

## Framework-Specific Rules

### Node.js/TypeScript Projects
- Use pnpm ONLY (never npm/yarn/bun)
- Add error handlers to entry point
- Use TypeScript strict mode
- Configure ESLint + Prettier
- Use Turbo for monorepo task orchestration

### Next.js Apps (in /apps)
- Use App Router (not Pages Router)
- Create `src/app/` directory structure
- Enable strict mode in next.config.js
- Share UI components from `packages/ui`

### API Services (in /services)
- Use Fastify or Hono for APIs
- Connect to shared database client from `packages/db`
- Use environment variables for all service connections

### Shared Packages (in /packages)
- Export TypeScript types
- Include `tsconfig.json` extending root config
- Use `exports` field in package.json

### Docker Projects
- Multi-stage builds ALWAYS
- Never run as root
- Include health checks
- `.dockerignore` must include `.git/` and `node_modules/`

---

## Quality Gates

### File Size Limits
- No file > 300 lines (split if larger)
- No function > 50 lines

### Required Before Commit
- [ ] All tests pass
- [ ] TypeScript compiles with no errors
- [ ] Linter passes with no warnings
- [ ] No secrets in staged files
- [ ] Used pnpm (not npm/yarn)

### Local CI Requirements
- Pre-commit hooks via Husky
- Lint-staged for formatting

---

## Required MCP Servers

Consider adding these MCP servers for enhanced capabilities:

```bash
# Live documentation access
claude mcp add context7 -- npx -y @anthropic-ai/context7-mcp

# Browser testing
claude mcp add playwright -- npx -y @anthropic-ai/playwright-mcp
```

---

## Global Commands

Store these in `~/.claude/commands/` for use in ALL projects:

| Command | Purpose |
|---------|---------|
| `/new-project` | Create monorepo with scaffolding rules |
| `/security-check` | Scan for secrets, validate .gitignore |
| `/pre-commit` | Run all quality gates |
| `/docs-lookup` | Research documentation via Context7 |
| `/infra-up` | Start docker-compose services |
| `/infra-down` | Stop docker-compose services |

---

*Last updated: [DATE]*
