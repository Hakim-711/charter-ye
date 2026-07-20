# Charter Backend (Node.js + Prisma + SQLite)

Internal API for Charter website admin panel and contact leads.

## Features
- Admin login with JWT session.
- Server-side token invalidation on logout and password change.
- Password change endpoint with strong-policy validation.
- Lockout protection after repeated failed logins.
- Public lead submission endpoint.
- Required client phone/email, server-side anti-spam validation, and request rate limiting.
- Optional SMTP notifications for new leads.
- Scheduled SQLite snapshots with configurable retention.
- Admin CRUD endpoints for site settings and leads.
- Auto database bootstrap on server start (no migration step required to run).

## Quick Start
1. Copy env file:
   ```bash
   cp .env.example .env
   ```
2. Install:
   ```bash
   npm install
   ```
3. Initialize DB + default admin:
   ```bash
   npm run setup
   ```
4. Run:
   ```bash
   npm run dev
   ```
5. Run tests:
   ```bash
   npm test
   ```

Default API URL: `http://localhost:4000`
Default admin credentials from `.env`:
- Username: `admin`
- Password: `ChangeMe@12345`

## Render One-Click (Blueprint)
This repository includes `render.yaml` at project root.

1. Push project to GitHub.
2. In Render, create Blueprint service from the repo.
3. Render will create `charter-admin-api` automatically with:
   - Node web service (`backend/`)
   - Persistent disk for SQLite (`/opt/render/project/src/backend/data`)
   - SQLite database path: `file:/opt/render/project/src/backend/data/prod.db`
   - Health check (`/api/health`)
   - Required env vars

During Blueprint creation and after first deploy:
1. Enter a strong `ADMIN_DEFAULT_PASSWORD` when Render prompts for it.
2. Keep `ALLOWED_ORIGINS` aligned with your Netlify domain.
3. Configure `SMTP_HOST`, `SMTP_USER`, `SMTP_PASSWORD`, and `LEAD_NOTIFICATION_TO` for email alerts.
4. Keep automated backups enabled and periodically export copies off the Render disk.
5. In frontend build, set:
   - `CHARTER_API_BASE_URL=https://<your-render-service>.onrender.com`

Manual Render env template is available at:
- `backend/.env.render.example`

## Email notifications
New-lead email is enabled when all of these are set:
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`
- `SMTP_USER`, `SMTP_PASSWORD`
- `LEAD_NOTIFICATION_TO`
- `LEAD_NOTIFICATION_FROM` (optional; defaults to `SMTP_USER`)

Lead storage succeeds independently of notification delivery. Notification failures are logged without losing the lead.

## Database backups
- Production defaults to one SQLite snapshot every 24 hours.
- `BACKUP_RETENTION_COUNT` controls how many snapshots are kept.
- `npm run backup` creates one snapshot immediately.
- Render snapshots are stored on the persistent disk. Export copies offsite to protect against disk or account loss.

## Main Endpoints
- `GET /api/health`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/change-password`
- `GET /api/public/settings`
- `POST /api/public/leads`
- `GET /api/admin/settings` (auth)
- `PUT /api/admin/settings` (auth)
- `DELETE /api/admin/settings` (auth)
- `GET /api/admin/leads` (auth)
- `PUT /api/admin/leads` (auth)
- `PATCH /api/admin/leads/:id/status` (auth)
- `DELETE /api/admin/leads/:id` (auth)
- `DELETE /api/admin/leads` (auth)

## Netlify + Backend
- Deploy this backend to a Node host (Render/Railway/Fly.io/etc).
- Set frontend build define in Flutter web build:
  - `CHARTER_API_BASE_URL=https://your-backend-domain`
- Access admin from frontend:
  - `https://your-site.netlify.app/#/admin`
  - or `https://your-site.netlify.app/?panel=admin`
