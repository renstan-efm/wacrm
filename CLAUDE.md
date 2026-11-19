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

## Hosting (Google Cloud)
- Cloud Run service `wacrm`, project `wa-crm-eternalflame`, region `africa-south1`.
  Image repo: `africa-south1-docker.pkg.dev/wa-crm-eternalflame/wacrm/wacrm:<tag>`.
- No automatic deploys: deploy by hand with `scripts/deploy-cloud-run.sh <new-tag>`
  (uses `cloudbuild.yaml`; copies the NEXT_PUBLIC_* build values from the live service).
  Tags so far: v1 (built 29 Aug 2026), v2 (19 Nov 2026, upstream main as of 17 Nov).
- Server secrets live in Secret Manager and are attached to the Cloud Run service.
- Roll back: `gcloud run services update-traffic wacrm --region africa-south1
  --project wa-crm-eternalflame --to-revisions <old-revision>=100`
  (last v1 revision: `wacrm-00013-d86`; v2 went live as `wacrm-00014-lsv` on 19 Nov 2026).
- Sign-ins on this Mac: `gh` as renstan-efm; `gcloud` installed via Homebrew.

### Still to do
- Apply database migrations BEFORE deploying any version that adds new ones.
- Marketing site and self-host docs live in a separate repo (wacrm-site), not tracked here.
- Upstream calls this a template, so new features are meant to be built in forks like this one.
- Goal for this fork (branding, a specific feature, deployment) is not recorded yet. Add it here.
