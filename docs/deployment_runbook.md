# Deployment Runbook (Render + Netlify)

## 1) Backend (Render)
1. Push repository to GitHub.
2. In Render, create a Blueprint service from the repo.
3. Confirm Render loads `render.yaml`.
4. Wait for deployment, then verify:
   - `https://<render-service>.onrender.com/api/health`

## 2) Backend secure setup
1. Open Render service environment variables.
2. Set or verify:
   - `ADMIN_DEFAULT_PASSWORD`
   - `JWT_SECRET` (if not auto-generated)
3. Set correct allowed origins:
   - `ALLOWED_ORIGINS=https://charter-ye.netlify.app,https://charter-ye.com,https://www.charter-ye.com`
4. Configure SMTP variables if email alerts are required.
5. Confirm `BACKUP_ENABLED=true` and the backup directory is on the persistent disk.

## 3) GitHub-connected frontend
1. Link the existing Netlify project to `Hakim-711/charter-ye`.
2. Set production branch to `main`.
3. Keep the build command from `netlify.toml`.
4. Set `CHARTER_API_BASE_URL=https://<render-service>.onrender.com` with Builds scope.
5. Optionally set `PLAUSIBLE_DOMAIN=charter-ye.com` after configuring Plausible.

## 4) Frontend publish (Netlify)
1. Trigger a deploy from `main`.
2. Verify routes:
   - `/`
   - `/#/admin`
   - `/?panel=admin`
   - `/privacy.html`
   - `/terms.html`
   - `/sitemap.xml`

## 5) Admin login test
1. Open `/#/admin`.
2. Login with backend admin credentials.
3. Change password immediately from admin panel.
4. Save a test setting and submit a test lead from the public contact form.
5. Confirm the lead includes phone/email and appears in the admin inbox.
6. Confirm the notification email arrives when SMTP is enabled.
7. Run `npm run backup` once and verify a snapshot is created.
