# Charter Company Website

Flutter Web project for Charter company website.

## Current scope
- Corporate landing website (Arabic / English) covering both updated company profiles.
- General Contracting: structural, architectural, infrastructure, rehabilitation, and electromechanical works.
- General Services & Supplies: procurement, logistics, distribution, petroleum, transport/rental, commercial agencies, and technical support.
- Detailed delivery portfolio, Marib and Aden locations, nationwide coverage, and contact request form.
- Secure internal admin panel with backend authentication.
- Modular codebase where each section is in its own file.

## Structure
- `lib/app`: application shell.
- `lib/core`: shared theme and style foundation.
- `lib/features/landing`: public website.
- `lib/features/admin`: internal admin auth and content settings.
- `lib/features/leads`: lead inbox domain and repositories.
- `backend`: Node.js API + Prisma + SQLite database.
- `docs`: business and delivery roadmap.

## Frontend deployment flags
- `CHARTER_API_BASE_URL` (required for backend mode): API base URL, e.g. `https://charter-api.onrender.com`
- `ADMIN_BOOTSTRAP_USERNAME` (optional local fallback only): default `admin`
- `ADMIN_BOOTSTRAP_PASSCODE` (optional local fallback only)
- `ADMIN_ACCESS_KEY` (optional legacy URL guard; ignored when backend mode enabled)

## Admin access URL
- `https://your-site.netlify.app/#/admin`
- `https://your-site.netlify.app/?panel=admin`
- `https://your-site.netlify.app/?admin_access=any-value` (opens admin page intent)

## Backend quick start
From `backend/`:
```bash
cp .env.example .env
npm install
npm run setup
npm run dev
```

## Render one-click backend
1. Push this project to GitHub.
2. In Render, create a Blueprint from the repo.
3. Render will read `render.yaml` and provision the backend service automatically.
4. Enter a strong `ADMIN_DEFAULT_PASSWORD` when Render prompts for it.

## GitHub + Netlify deployment
1. Push the repository to GitHub.
2. In Netlify, select **Add new project > Import an existing project > GitHub**.
3. Select this repository. Netlify reads `netlify.toml`, so leave the detected build settings unchanged:
   - Build command: `bash tool/netlify_build.sh`
   - Publish directory: `build/web`
4. If the backend is deployed, add this Netlify environment variable with **Builds** scope:
   - `CHARTER_API_BASE_URL=https://your-backend-domain`
5. Deploy the site. Every push to the production branch triggers a new build and deployment.

Do not put `ADMIN_BOOTSTRAP_PASSCODE`, `ADMIN_ACCESS_KEY`, database credentials, or API secrets in a production Flutter web build. Values compiled with `--dart-define` are visible in the browser. Production admin authentication should use the backend.

## Production backend checklist
1. Deploy `backend/` to a Node host (Render, Railway, Fly.io, etc.).
2. In backend environment variables, set:
   - `JWT_SECRET`
   - `ADMIN_DEFAULT_USERNAME`
   - `ADMIN_DEFAULT_PASSWORD`
   - `ALLOWED_ORIGINS` (include your Netlify domain)
3. Set `CHARTER_API_BASE_URL` in Netlify and trigger a new deploy.
4. Open admin from:
   - `/#/admin`
   - or `/?panel=admin`
5. Log in with backend admin credentials (`ADMIN_DEFAULT_USERNAME` / `ADMIN_DEFAULT_PASSWORD`).
