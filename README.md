# Jenkins & Nginx CI/CD Pipeline Demo

This project provides a complete step-by-step CI/CD pipeline setup using **Jenkins**, **Nginx**, and **Git** on Ubuntu/Linux. The pipeline automatically tests, builds, and deploys static web content to Nginx when changes are pushed to GitHub.

---

## 📁 Project Structure

```
jenkins-nginx-demo/
├── index.html           # Web application landing page
├── style.css            # Stylesheet for the web application
├── Jenkinsfile          # Jenkins declarative CI/CD pipeline definition
├── nginx/
│   └── jenkins-demo.conf# Nginx server block configuration (Port 8081)
├── scripts/
│   └── setup-nginx.sh   # Bash setup script for permissions & Nginx config
└── README.md            # Detailed setup instructions & documentation
```

---

## 🛠️ Complete Setup Instructions

### Step 1: Verify System Requirements (Jenkins, Nginx, Git)
Run the following commands on your Ubuntu server to verify services and tools:

```bash
sudo systemctl status jenkins
sudo systemctl status nginx
git --version
```

If necessary, enable services and install missing packages:

```bash
sudo systemctl enable --now jenkins
sudo systemctl enable --now nginx
sudo apt update
sudo apt install -y git rsync curl
```

Verify service dashboards in browser:
- **Jenkins**: `http://localhost:8080`
- **Nginx (Default)**: `http://localhost`

---

### Step 2: Prepare Project Directory and Files

Clone or create the directory `~/jenkins-nginx-demo`:

```bash
mkdir -p ~/jenkins-nginx-demo
cd ~/jenkins-nginx-demo
```

Ensure `index.html`, `style.css`, and `Jenkinsfile` are present in this directory.

---

### Step 3: Create Nginx Production Directory & Set Permissions

To allow Jenkins to deploy files without needing `sudo` in the pipeline:

```bash
sudo mkdir -p /var/www/jenkins-demo
sudo chown -R jenkins:www-data /var/www/jenkins-demo
sudo chmod -R 755 /var/www/jenkins-demo
```

*Alternatively, run the automated setup script:*
```bash
chmod +x scripts/setup-nginx.sh
./scripts/setup-nginx.sh
```

---

### Step 4: Configure Nginx Server Block (Port 8081)

Create `/etc/nginx/sites-available/jenkins-demo`:

```nginx
server {
    listen 8081;
    listen [::]:8081;
    server_name localhost;
    root /var/www/jenkins-demo;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Enable site and reload Nginx:

```bash
sudo ln -sf /etc/nginx/sites-available/jenkins-demo /etc/nginx/sites-enabled/jenkins-demo
sudo nginx -t
sudo systemctl reload nginx
```

Website target URL: **`http://localhost:8081`**

---

### Step 5: Understand the `Jenkinsfile` Pipeline

The declarative pipeline consists of 4 main stages:

| Stage | Purpose |
| :--- | :--- |
| **Build** | Creates `dist/` directory and copies `index.html` and `style.css` into it. |
| **Test** | Validates existence of deployable files and verifies essential HTML structure (`<html>`, `<title>`, `</html>`). |
| **Deploy** | Uses `rsync -av --delete dist/ "${DEPLOY_DIR}/"` to sync files to `/var/www/jenkins-demo`. |
| **Verify Deployment** | Sends a `curl` request to `http://localhost:8081` to verify Nginx serves the site. |

---

### Step 6: Initialize Git & Push to GitHub

1. Create a new, empty repository on GitHub named `jenkins-nginx-demo`.
2. Push your project:

```bash
cd ~/jenkins-nginx-demo
git init
git branch -M main
git add .
git commit -m "Add Jenkins Nginx CI-CD project"
git remote add origin https://github.com/YOUR-USERNAME/jenkins-nginx-demo.git
git push -u origin main
```
*(Replace `YOUR-USERNAME` with your actual GitHub username).*

---

### Step 7: Install Required Jenkins Plugins

Navigate to **Jenkins (`http://localhost:8080`)** → **Manage Jenkins** → **Plugins** → **Installed / Available plugins**. Ensure the following are installed:

- **Pipeline**
- **Git**
- **GitHub**
- **Credentials Binding**
- **Workspace Cleanup**

If prompted, restart Jenkins: `sudo systemctl restart jenkins`.

---

### Step 8: Create the Jenkins Pipeline Job

1. Open Jenkins and click **New Item**.
2. Enter item name: `jenkins-nginx-demo`.
3. Select **Pipeline** and click **OK**.
4. Scroll to **Pipeline** section:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/YOUR-USERNAME/jenkins-nginx-demo.git`
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile`
5. Click **Save**.
6. Click **Build Now** to trigger the initial run.

---

### Step 9: Configure GitHub Credentials (For Private Repositories)

If the GitHub repository is **private**:
1. Create a Personal Access Token (PAT) in GitHub: **Settings** → **Developer Settings** → **Personal Access Tokens**.
2. In Jenkins: **Manage Jenkins** → **Credentials** → **System** → **Global credentials** → **Add Credentials**.
   - **Kind**: `Username with password`
   - **Username**: Your GitHub username
   - **Password**: GitHub Personal Access Token
   - **ID**: `github-credentials`
3. In the Pipeline job configuration, select `github-credentials` under **Credentials**.

---

### Step 10: Verify Deployment

After the build turns **Green (Success)**:
1. Inspect deployment directory:
   ```bash
   ls -la /var/www/jenkins-demo
   ```
2. Test endpoint:
   ```bash
   curl http://localhost:8081
   ```
3. Open in browser: `http://localhost:8081`

---

### Step 11: Demonstrate Automated CI/CD (SCM Polling)

To trigger automated builds, enable **Poll SCM** in the Jenkins job configuration:
- Check **Build Triggers** → **Poll SCM**
- Schedule: `H/2 * * * *` *(polls GitHub every 2 minutes)*

Make a change to `index.html`:
```bash
# Update heading in index.html
git add index.html
git commit -m "Update website heading"
git push origin main
```
Within 2 minutes, Jenkins will detect the commit, execute the pipeline, and automatically deploy the updated site to `http://localhost:8081`.

---

### Step 12: Webhook Limitation on Local Environments

> [!NOTE]
> Local Jenkins instances (`localhost:8080`) cannot directly receive GitHub Webhooks because GitHub servers cannot reach `127.0.0.1`. Therefore, **SCM Polling (`pollSCM`)** is recommended for local/classroom demos.
> 
> If Jenkins is hosted on a public domain/IP:
> - Configure GitHub Repo → **Settings** → **Webhooks** → **Add webhook**
> - **Payload URL**: `https://YOUR-PUBLIC-JENKINS-URL/github-webhook/`
> - **Content type**: `application/json`
> - **Events**: Just the `push` event.

---

### Step 13: CI Failure Teaching Experiment

To demonstrate how CI prevents bad code from reaching production:

1. Intentionally break `index.html` by removing `<title>Jenkins CI/CD Demo</title>`.
2. Commit and push:
   ```bash
   git add index.html
   git commit -m "Demonstrate failed CI test"
   git push origin main
   ```
3. **Pipeline Result**:
   - The test `grep -qi "<title>" dist/index.html` fails.
   - Stage **Test** turns RED.
   - Stage **Deploy** is **skipped**.
   - The production website at `http://localhost:8081` remains untouched and safe.

---

## 🔍 Common Errors & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| **Permission denied during deployment** | Jenkins user lacks write access to `/var/www/jenkins-demo` | `sudo chown -R jenkins:www-data /var/www/jenkins-demo`<br>`sudo chmod -R 755 /var/www/jenkins-demo` |
| **`rsync: command not found`** | `rsync` package missing | `sudo apt install -y rsync` |
| **`curl: command not found`** | `curl` package missing | `sudo apt install -y curl` |
| **Nginx returns 403 Forbidden** | Parent directory permission restricted | `sudo chmod 755 /var`<br>`sudo chmod 755 /var/www`<br>`sudo chmod -R 755 /var/www/jenkins-demo` |
| **Website does not open (Connection Refused)** | Port 8081 not bound or Nginx inactive | `sudo nginx -t`<br>`sudo systemctl restart nginx`<br>`sudo ss -lntp \| grep 8081` |
| **Jenkins clone failure** | Auth error or branch mismatch | Check repo URL, branch (`main`), internet access, and credentials ID. |

# DEVOPS_LAB

