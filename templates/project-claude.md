# Project Name

## Overview

[One paragraph describing what this project does and its primary purpose]

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | TypeScript |
| Runtime | Node.js 20+ |
| Package Manager | pnpm (REQUIRED) |
| Web App | Next.js (App Router) |
| API | Fastify |
| Database | PostgreSQL (via docker-compose) |
| ORM | Prisma |
| Cache | Redis (via docker-compose) |
| Mail | Mailpit (via docker-compose) |
| Storage | MinIO (via docker-compose) |
| Testing | Vitest |

## Monorepo Structure

```
├── apps/                    # Frontend applications
│   └── web/                 # Next.js web application
├── services/                # Backend services
│   └── api/                 # Fastify API service
├── packages/                # Shared libraries
│   ├── db/                  # Prisma client and schema
│   ├── ui/                  # Shared UI components
│   └── config/              # Shared configurations (tsconfig, eslint)
├── docker-compose.yml       # Local infrastructure
├── Makefile                 # Development commands
└── pnpm-workspace.yaml      # Workspace configuration
```

## Getting Started

```bash
# Start infrastructure (postgres, redis, mailpit, minio)
make up

# Install dependencies
make install

# Set up environment
cp .env.example .env
# Edit .env with your values

# Run database migrations
make db-migrate

# Start development server (all workspaces)
make dev
```

## Commands (Makefile)

| Command | Description |
|---------|-------------|
| `make install` | Install all dependencies with pnpm |
| `make dev` | Start all services in development mode |
| `make build` | Build all packages and apps |
| `make lint` | Run ESLint across all workspaces |
| `make typecheck` | Run TypeScript compiler (no emit) |
| `make test` | Run test suite with Vitest |
| `make db-migrate` | Run Prisma migrations |
| `make db-generate` | Generate Prisma client |
| `make db-studio` | Open Prisma Studio |
| `make up` | Start docker-compose services |
| `make down` | Stop docker-compose services |
| `make reset` | Full reset: remove node_modules, build artifacts, volumes |

## Environment Variables

> Copy `.env.example` to `.env` and fill in values. Never commit `.env`!

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://dev:dev@localhost:5432/app` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `SMTP_HOST` | Mail server host | `localhost` |
| `SMTP_PORT` | Mail server port | `1025` |
| `S3_ENDPOINT` | MinIO endpoint | `http://localhost:9000` |
| `S3_ACCESS_KEY` | MinIO access key | `minioadmin` |
| `S3_SECRET_KEY` | MinIO secret key | `minioadmin` |

## Local Services (docker-compose)

| Service | Port(s) | Purpose |
|---------|---------|---------|
| PostgreSQL | 5432 | Primary database |
| Redis | 6379 | Cache and queues |
| Mailpit | 1025 (SMTP), 8025 (UI) | Email testing |
| MinIO | 9000 (API), 9001 (Console) | Object storage |

Access Mailpit UI at: http://localhost:8025
Access MinIO Console at: http://localhost:9001

## Architecture

### apps/web (Next.js)

```
apps/web/
├── src/
│   ├── app/                 # App Router pages and layouts
│   │   ├── (auth)/          # Auth-required routes
│   │   ├── api/             # API routes (if needed)
│   │   └── layout.tsx       # Root layout
│   ├── components/          # App-specific components
│   └── lib/                 # App-specific utilities
├── next.config.js
└── package.json
```

### services/api (Fastify)

```
services/api/
├── src/
│   ├── routes/              # Route handlers
│   ├── plugins/             # Fastify plugins
│   ├── services/            # Business logic
│   └── index.ts             # Entry point
├── package.json
└── tsconfig.json
```

### packages/db (Prisma)

```
packages/db/
├── prisma/
│   ├── schema.prisma        # Database schema
│   └── migrations/          # Migration files
├── src/
│   └── index.ts             # Export Prisma client
└── package.json
```

## Key Patterns

### Error Handling
- All async functions use try/catch
- Errors are logged with context
- User-facing errors are generic; detailed errors in logs only

### Database (Prisma)
- Schema defined in `packages/db/prisma/schema.prisma`
- Client exported from `@repo/db`
- Migrations tracked in version control
- Use transactions for multi-step operations

### API (Fastify)
- All endpoints require authentication (unless public)
- Rate limiting is enabled
- Input validated with Zod schemas
- Use Fastify plugins for cross-cutting concerns

### Shared Packages
- Import from `@repo/db`, `@repo/ui`, `@repo/config`
- All packages export TypeScript types
- Use `exports` field in package.json

## Testing

```bash
# Run all tests
make test

# Run tests in watch mode
pnpm test --watch

# Run specific workspace tests
pnpm --filter @repo/api test

# Run with coverage
pnpm test --coverage
```

## Notes for Claude

### Do
- Use pnpm ONLY (never npm, yarn, or bun)
- Follow the monorepo structure (apps/, services/, packages/)
- Use Makefile commands for common operations
- Import shared code from @repo/* packages
- Run `make typecheck` and `make lint` before commits
- Keep Prisma schema in packages/db

### Don't
- Hardcode credentials or secrets
- Use npm, yarn, or bun commands
- Skip error handling
- Ignore TypeScript errors
- Put database logic outside packages/db
- Create files outside the monorepo structure
- Create new `*.md` files outside `.claude/docs/` (editing existing files is OK)

---

*Last updated: [DATE]*
