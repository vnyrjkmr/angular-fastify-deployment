# ⚡ Quick Deploy to Render.com (5 Minutes)

Your Docker image builds successfully locally. Let's deploy it to Render.com (free hosting)!

## Why Render.com?
- ✅ **100% Free tier** (no credit card required)
- ✅ **Auto-deploys from GitHub** (no manual builds)
- ✅ **SSL certificate included** (https://)
- ✅ **Zero configuration** (detects Dockerfile automatically)
- ✅ **No AWS permissions needed**

---

## Step-by-Step Deployment

### 1. Sign Up for Render
- Go to: https://render.com
- Click **"Get Started"**
- Sign up with **GitHub** (easiest)

### 2. Connect Your Repository
- After login, click **"New +"** (top right)
- Select **"Web Service"**
- Click **"Connect account"** if needed
- Find and select: `vnyrjkmr/angular-fastify-deployment`

### 3. Configure Service
Fill in these settings:

| Setting | Value |
|---------|-------|
| **Name** | `angular-fastify-app` |
| **Region** | `Oregon (US West)` or any |
| **Branch** | `master` |
| **Root Directory** | _(leave empty)_ |
| **Environment** | `Docker` |
| **Plan** | `Free` |

### 4. Deploy
- Click **"Create Web Service"**
- Render will:
  1. Clone your repo
  2. Build Docker image
  3. Deploy container
  4. Assign a URL

### 5. Access Your App
Your app will be live at:
```
https://angular-fastify-app.onrender.com
```

Test endpoints:
- Frontend: `https://angular-fastify-app.onrender.com/`
- API Health: `https://angular-fastify-app.onrender.com/api/health`
- API Data: `https://angular-fastify-app.onrender.com/api/data`

---

## ⚙️ Optional: Environment Variables

If needed, add these in Render dashboard:

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `PORT` | `3000` |

---

## 🔄 Auto-Deploy on Push

Render automatically redeploys when you push to GitHub:

```bash
# Make changes
git add .
git commit -m "Update feature"
git push

# Render detects push and redeploys automatically!
```

---

## 📊 Monitoring

In Render dashboard you can:
- View logs (real-time)
- Check deployment status
- Monitor resource usage
- Configure custom domains

---

## 💰 Free Tier Limits

Render Free tier includes:
- ✅ 750 hours/month runtime
- ✅ Auto-sleep after 15 min inactivity
- ✅ Wakes up on request (~30 seconds)
- ✅ 512 MB RAM
- ✅ Unlimited projects

**Note:** First request after sleep takes ~30 seconds (free tier limitation)

---

## 🚀 That's It!

No Docker commands needed, no AWS permissions required, no configuration files. Just connect GitHub and deploy!

---

## Alternative: Railway.app

If you prefer Railway instead:

1. Go to: https://railway.app
2. Sign up with GitHub
3. Click **"New Project"** → **"Deploy from GitHub repo"**
4. Select `vnyrjkmr/angular-fastify-deployment`
5. Railway auto-detects Dockerfile and deploys

**$5 free credit** included (roughly 500 hours of runtime)

---

## Need Help?

Both platforms have excellent documentation:
- Render: https://render.com/docs/docker
- Railway: https://docs.railway.app/deploy/dockerfiles

**Your app is ready - just pick a platform and deploy! 🎉**
