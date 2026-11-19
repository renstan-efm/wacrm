@AGENTS.md

# wacrm — project notes

## What this is
A self-hostable CRM for WhatsApp (shared inbox, contacts, sales pipelines,
broadcasts, no-code automations, AI reply assistant). It is a fork/copy of the
open-source template at github.com/ArnasDon/wacrm (MIT licence).
Stack: Next.js 16 (React 19), Supabase (database + login), Tailwind, TypeScript.

## Where things live
- `src/`        the app itself
- `supabase/`   database setup and migrations
- `mcp-server/` optional server that lets AI assistants read the CRM
- `messages/`   translations
- `docs/`       extra documentation (e.g. the public API and MCP guides)
- `CHANGELOG.md`, `README.md`  history and overview

## Everyday commands
- `npm install`      run once on a new machine (also if `node_modules` misbehaves)
- `npm run dev`      start a local preview of the app
- `npm run typecheck`, `npm run lint`, `npm test`   check the work before finishing
- `npm run build`    make a production build

## Things to be careful with
- `.env.local` holds private keys and passwords. Never print, copy or commit it.
  On a new machine it must exist for the app to run (`.env.local.example` shows the layout).
- Next.js here is a newer version than most guides describe: read the notes in
  `node_modules/next/dist/docs/` before writing Next.js code (see AGENTS.md).
- Explain changes in plain language; the owner is not a developer.

## Status / where we left off
Summary carried over from the old machine's Claude Code chat (Nov 2026).

- Version 0.8.1 (see CHANGELOG.md), about 590 commits, 36 database migrations. `main` was clean.
- Built: shared inbox (assignment, status, notes, reply buttons and lists), contacts with
  tags/custom fields/CSV import, Kanban sales pipelines, broadcasts with Meta-approved
  templates, no-code automations (visual builder), AI assistant (own OpenAI or Anthropic key:
  drafted replies, auto-reply bot with cap, take over/resume, knowledge base, token-usage
  dashboard), dashboard, team accounts and roles, public REST API (/api/v1, docs/public-api.md),
  MCP server (mcp-server/), security basics (encryption, row-level security, signed webhooks,
  CSP, rate limiting), translations (Korean added most recently) and Colombian Peso support.
- Recent fixes: duplicate-conversation bug, login redirect, settings navigation, timing-safe
  cron secret check.

### Update, 19 Nov 2026
- GitHub: `origin` is now the owner's own copy (github.com/renstan-efm/wacrm, public fork);
  `upstream` is the original (ArnasDon/wacrm). Get upstream updates with
  `git fetch upstream && git merge upstream/main`.
- Brought `main` up to upstream as of 17 Nov 2026 (337 commits): migrations now run to 060
  (050 and 056 don't exist). Upstream fixed the template-sharing TODO (migration 057).
- `supabase/check-migrations.sql` is a read-only query to paste into the Supabase SQL Editor;
  it shows which migrations a database has. Add a row whenever a new migration arrives.

- Live Supabase project checked 19 Nov 2026: had 001–039; owner applied 040–060 by hand in
  the SQL Editor. Re-check shows all 58 migrations `ok`. Database matches `main`.

### Still to do
- Deploy the updated app (where it is hosted is not recorded yet; add it here).
- Marketing site and self-host docs live in a separate repo (wacrm-site), not tracked here.
- Upstream calls this a template, so new features are meant to be built in forks like this one.
- Goal for this fork (branding, a specific feature, deployment) is not recorded yet. Add it here.
