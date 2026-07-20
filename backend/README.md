# Charter Backend (Node.js + Prisma + SQLite)

Internal API for Charter website admin panel and contact leads.

## Features
- Admin login with JWT session.
- Password change endpoint with strong-policy validation.
- Lockout protection after repeated failed logins.
- Public lead submission endpoint.
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
3. In frontend build, set:
   - `CHARTER_API_BASE_URL=https://<your-render-service>.onrender.com`

Manual Render env template is available at:
- `backend/.env.render.example`

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
