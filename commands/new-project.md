---
description: Create a new monorepo project with standard structure
---

# New Project

Create a new monorepo project following the standard structure and conventions.

## Step 1: Gather Requirements

Ask the user for the following information. Show defaults and allow them to accept or customize:

### Project Name
- Ask: "What is the project name?" (lowercase, kebab-case). If we are in an empty folder, assume the project name is the name of the current folder.

### Technologies (show defaults, ask if they want to change)

| Component | Default | Options |
|-----------|---------|---------|
| Package Manager | **pnpm** (required, cannot change) | — |
| Web Framework | **Next.js** | Next.js, Vite, None |
| API Framework | **Fastify** | Fastify, Express, None |
| Testing | **Vitest** | Vitest, Jest |
| ORM | **Prisma** | Prisma, Drizzle, Sequelize, None |
| Event Sourcing | **Redis** | Redis, RabbitMQ, None |
| UI Library | **daisyUI** | daisyUI, materialUI, shadcn/ui, None |

Ask: "I'll create the project with these defaults. Would you like to customize any technologies?"

Present as a simple list:
```
- Package Manager: pnpm (required)
- Web App: Next.js (App Router)
- API: Fastify
- ORM: Prisma
- Database: PostgreSQL (docker-compose)
- Cache: Redis (docker-compose)
- Event Sourcing: Redis (docker-compose)
- Testing: Vitest

Press Enter to accept, or tell me what to change.
```

## Step 2: Create Project Structure

Create the following structure:

```
<project-name>/
├── apps/
│   └── web/                 # Next.js app (if selected)
├── services/
│   └── api/                 # Fastify service (if selected)
├── packages/
│   ├── db/                  # Prisma schema and client (if ORM selected)
│   ├── ui/                  # Shared UI components
│   └── config/              # Shared tsconfig, eslint config
├── .claude/
│   ├── commands/            # Project-specific commands
│   └── docs/                # Claude-generated documentation
├── .env.example
├── .gitignore
├── .dockerignore
├── CLAUDE.md
├── README.md
├── Makefile
├── docker-compose.yml
├── package.json             # Root package.json
├── pnpm-workspace.yaml
└── turbo.json               # Turborepo config
```

## Step 3: Create Core Files

### pnpm-workspace.yaml

```yaml
packages:
  - 'apps/*'
  - 'services/*'
  - 'packages/*'
```

### Root package.json

```json
{
  "name": "<project-name>",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "typecheck": "turbo typecheck",
    "test": "turbo test",
    "db:migrate": "pnpm --filter @repo/db migrate",
    "db:generate": "pnpm --filter @repo/db generate",
    "db:studio": "pnpm --filter @repo/db studio"
  },
  "devDependencies": {
    "turbo": "^2"
  },
  "packageManager": "pnpm@9.0.0",
  "engines": {
    "node": ">=20"
  }
}
```

### Makefile

```makefile
.PHONY: install dev build lint typecheck test db-migrate db-generate db-studio up down reset

# Dependencies
install:
	pnpm install

# Development
dev:
	pnpm dev

# Build
build:
	pnpm build

# Code Quality
lint:
	pnpm lint

typecheck:
	pnpm typecheck

test:
	pnpm test

# Database (Prisma)
db-migrate:
	pnpm db:migrate

db-generate:
	pnpm db:generate

db-studio:
	pnpm db:studio

# Docker Compose
up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

# Reset everything
reset:
	docker compose down -v
	rm -rf node_modules
	rm -rf apps/*/node_modules
	rm -rf services/*/node_modules
	rm -rf packages/*/node_modules
	rm -rf apps/*/.next
	rm -rf apps/*/dist
	rm -rf services/*/dist
	rm -rf packages/*/dist
	rm -rf .turbo
	pnpm store prune
	@echo "Reset complete. Run 'make install && make up' to start fresh."
```

### docker-compose.yml

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
      - "1025:1025"
      - "8025:8025"
    environment:
      MP_SMTP_AUTH_ACCEPT_ANY: 1
      MP_SMTP_AUTH_ALLOW_INSECURE: 1

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
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

### .env.example

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

# App
NODE_ENV=development
```

### .gitignore

```gitignore
# Environment
.env
.env.*
!.env.example

# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
.next/
.turbo/

# Prisma
packages/db/prisma/*.db
packages/db/prisma/*.db-journal

# Claude
.claude/settings.local.json
CLAUDE.local.md

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
```

### turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^lint"]
    },
    "typecheck": {
      "dependsOn": ["^typecheck"]
    },
    "test": {
      "dependsOn": ["^build"]
    }
  }
}
```

## Step 4: Create packages/config

Shared TypeScript and ESLint configuration.

### packages/config/package.json

```json
{
  "name": "@repo/config",
  "version": "0.0.0",
  "private": true,
  "exports": {
    "./tsconfig/base": "./tsconfig/base.json",
    "./tsconfig/nextjs": "./tsconfig/nextjs.json",
    "./tsconfig/node": "./tsconfig/node.json"
  }
}
```

### packages/config/tsconfig/base.json

```json
{
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "incremental": true
  }
}
```

## Step 5: Create packages/db (if Prisma selected)

### packages/db/package.json

```json
{
  "name": "@repo/db",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "generate": "prisma generate",
    "migrate": "prisma migrate dev",
    "studio": "prisma studio",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@prisma/client": "^5"
  },
  "devDependencies": {
    "prisma": "^5",
    "typescript": "^5"
  }
}
```

### packages/db/prisma/schema.prisma

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Add your models here
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

### packages/db/src/index.ts

```typescript
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

export * from '@prisma/client'
```

## Step 6: Create CLAUDE.md

Generate a project-specific CLAUDE.md based on the template, filling in the actual technologies selected.

## Step 7: Final Steps

After creating all files:

1. Tell the user to run:
   ```bash
   cd <project-name>
   make up        # Start infrastructure
   make install   # Install dependencies
   cp .env.example .env
   make db-migrate # Run initial migration
   make dev       # Start development
   ```

2. Remind them of key URLs:
   - Web app: http://localhost:3000
   - API: http://localhost:3001
   - Mailpit: http://localhost:8025
   - MinIO Console: http://localhost:9001
