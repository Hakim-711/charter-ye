# Deployment Runbook (Render + Netlify)

## 1) Backend (Render)
1. Push repository to GitHub.
2. In Render, create a Blueprint service from the repo.
3. Confirm Render loads `render.yaml`.
4. Wait for deployment, then verify:
   - `https://<render-service>.onrender.com/api/health`

## 2) Backend secure setup
1. Open Render service environment variables.
2. Change:
   - `ADMIN_DEFAULT_PASSWORD`
   - `JWT_SECRET` (if not auto-generated)
3. Set correct allowed origin:
   - `ALLOWED_ORIGINS=https://charter-ye.netlify.app`

## 3) Frontend build
```bash
flutter build web --release \
  --dart-define=CHARTER_API_BASE_URL=https://<render-service>.onrender.com
```

## 4) Frontend publish (Netlify)
1. Upload `build/web`.
2. Verify routes:
   - `/`
   - `/#/admin`
   - `/?panel=admin`

## 5) Admin login test
1. Open `/#/admin`.
2. Login with backend admin credentials.
3. Change password immediately from admin panel.
4. Save a test setting and submit a test lead from the public contact form.
