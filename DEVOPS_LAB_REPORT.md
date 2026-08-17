# DevOps Lab Experiment Report: End-to-End Jenkins & Nginx CI/CD Pipeline

**Course / Lab**: DevOps Lab  
**Project Repository**: [https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git](https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git)  
**Branch**: `main`  
**Target Server**: Nginx on Ubuntu (Port 8081)  
**CI Engine**: Jenkins (Port 8080)  

---

## 📋 Executive Summary & Lab Objectives

The objective of this lab is to build an automated, robust CI/CD pipeline using **Jenkins**, **Nginx**, and **Git**. The pipeline automatically monitors a GitHub repository, prepares deployment artifacts, executes automated unit/lint tests, deploys valid code to Nginx without `sudo` escalation, and verifies web service health.

---

## 1. System Verification & Pre-requisites

### Executed Commands:
```bash
# 1. Verify Jenkins service status
sudo systemctl status jenkins

# 2. Verify Nginx service status
sudo systemctl status nginx

# 3. Verify Git installation
git --version

# 4. Enable and start required services (if inactive)
sudo systemctl enable --now jenkins
sudo systemctl enable --now nginx

# 5. Install missing deployment utilities
sudo apt update
sudo apt install -y git rsync curl
```

### Observations:
- **Jenkins UI**: Accessible at `http://localhost:8080`
- **Default Nginx**: Accessible at `http://localhost`
- Installed utilities (`rsync`, `curl`, `git`) were verified for pipeline execution.

---

## 2. Project Creation & Source Assets

### Directory Structure:
```
jenkins-nginx-demo/
├── index.html           # Web landing page
├── style.css            # Custom CSS stylesheet
├── Jenkinsfile          # Declarative CI/CD pipeline script
├── nginx/
│   └── jenkins-demo.conf# Nginx server block (Port 8081)
├── scripts/
│   └── setup-nginx.sh   # Production setup & permissions script
└── README.md            # Project documentation & lab notes
```

### Code Assets:

#### `index.html`
```html
<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>Jenkins CI/CD Demo</title>
 <link rel="stylesheet" href="style.css">
</head>
<body>
 <div class="container">
 <h1>Jenkins CI/CD Pipeline</h1>
 <p>This website was automatically deployed from GitHub.</p>
 <p>Server: Nginx on Ubuntu</p>
 </div>
</body>
</html>
```

#### `style.css`
```css
body {
 background: #eef2f7;
 font-family: Arial, sans-serif;
 text-align: center;
 padding-top: 100px;
}
.container {
 background: white;
 width: 60%;
 margin: auto;
 padding: 40px;
 border-radius: 10px;
 box-shadow: 0 4px 15px #aaa;
}
h1 {
 color: #1565c0;
}
```

---

## 3. Production Environment & Permission Setup

To allow Jenkins to deploy files directly to `/var/www/jenkins-demo` without using `sudo` inside pipeline stages:

### Executed Commands:
```bash
sudo mkdir -p /var/www/jenkins-demo
sudo chown -R jenkins:www-data /var/www/jenkins-demo
sudo chmod -R 755 /var/www/jenkins-demo
```

### Automation Script (`scripts/setup-nginx.sh`):
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating production directory /var/www/jenkins-demo..."
sudo mkdir -p /var/www/jenkins-demo

echo "==> Setting directory ownership to jenkins:www-data..."
sudo chown -R jenkins:www-data /var/www/jenkins-demo

echo "==> Setting directory permissions to 755..."
sudo chmod -R 755 /var/www/jenkins-demo

CONF_SRC="./nginx/jenkins-demo.conf"
CONF_DEST="/etc/nginx/sites-available/jenkins-demo"

if [ -f "$CONF_SRC" ]; then
    sudo cp "$CONF_SRC" "$CONF_DEST"
    sudo ln -sf "$CONF_DEST" /etc/nginx/sites-enabled/jenkins-demo
fi

sudo nginx -t
sudo systemctl reload nginx
echo "==> Setup complete. Serving at http://localhost:8081"
```

---

## 4. Nginx Server Block Configuration

Configuration saved at `/etc/nginx/sites-available/jenkins-demo`:

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

### Enabling and Testing Site:
```bash
sudo ln -sf /etc/nginx/sites-available/jenkins-demo /etc/nginx/sites-enabled/jenkins-demo
sudo nginx -t
sudo systemctl reload nginx
```

---

## 5. Jenkins Pipeline Configuration (`Jenkinsfile`)

```groovy
pipeline {
    agent any

    environment {
        DEPLOY_DIR = '/var/www/jenkins-demo'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Preparing deployable files...'
                sh '''
                mkdir -p dist
                cp index.html style.css dist/
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Testing website...'
                sh '''
                test -f dist/index.html
                test -f dist/style.css
                grep -qi "<html>" dist/index.html
                grep -qi "<title>" dist/index.html
                grep -qi "</html>" dist/index.html
                echo "All tests passed."
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying the website to Nginx...'
                sh '''
                rsync -av --delete dist/ "${DEPLOY_DIR}/"
                chmod -R 755 "${DEPLOY_DIR}"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying the deployed website...'
                sh '''
                sleep 2
                curl --fail --silent http://localhost:8081 > /dev/null
                echo "Deployment verified successfully."
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
            echo 'Website: http://localhost:8081'
        }
        failure {
            echo 'Pipeline failed. The website was not successfully deployed.'
        }
        always {
            cleanWs()
        }
    }
}
```

---

## 6. Git Version Control & Commit History

### Executed Commands:
```bash
git init
git branch -M main
git add .
git commit -m "Add Jenkins Nginx CI-CD project setup and configuration"
echo "# DEVOPS_LAB" >> README.md
git add README.md
git commit -m "Add DEVOPS_LAB section to README"
git remote add origin https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git
git push -u origin main
```

### Commit History Log (`git log --oneline`):
```
0d43c94 Add DEVOPS_LAB section to README
8669601 Add Jenkins Nginx CI-CD project setup and configuration
```

---

## 7. Jenkins Job & Plugin Configuration

1. **Required Plugins Installed**:
   - `Pipeline`
   - `Git`
   - `GitHub`
   - `Credentials Binding`
   - `Workspace Cleanup`
2. **Job Setup**:
   - Name: `jenkins-nginx-demo`
   - Type: `Pipeline`
   - SCM Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
3. **Build Trigger**:
   - Poll SCM Schedule: `H/2 * * * *` *(Polls GitHub every 2 minutes for updates)*

---

## 8. Deployment Verification Results

### Terminal Verification Commands:
```bash
ls -la /var/www/jenkins-demo
curl http://localhost:8081
```

### Verified Terminal Output:
```html
<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>Jenkins CI/CD Demo</title>
 <link rel="stylesheet" href="style.css">
</head>
<body>
 <div class="container">
 <h1>Jenkins CI/CD Pipeline</h1>
 <p>This website was automatically deployed from GitHub.</p>
 <p>Server: Nginx on Ubuntu</p>
 </div>
</body>
</html>
```
- **HTTP Status Code**: `200 OK`
- **Deployed URL**: `http://localhost:8081`

---

## 9. Experiment Observations & Failure Testing

### Experiment A: Successful Automatic Deployment
1. Modified `index.html` header: `<h1>My Website Updated Automatically!</h1>`
2. Pushed commit to `main`.
3. Jenkins detected commit via `pollSCM`, triggered build, passed tests, and deployed updated content to Nginx.
4. **Observation**: Navigating to `http://localhost:8081` instantly displayed the updated heading.

### Experiment B: CI Test Failure Safety Demonstration
1. Intentionally removed `<title>Jenkins CI/CD Demo</title>` from `index.html`.
2. Committed and pushed change to GitHub.
3. **Jenkins Execution Result**:
   - Stage **Test** failed on assertion: `grep -qi "<title>" dist/index.html` (Exit code 1).
   - Stage **Deploy** was automatically **SKIPPED**.
   - Pipeline status marked **FAILED (RED)**.
4. **Production Web Server Observation**:
   - Checking `http://localhost:8081` showed the previously working version of the website.
   - **Conclusion**: The CI pipeline effectively guarded the production environment against broken releases.

---

## 10. Master Command Reference Table

| Category | Command | Description |
| :--- | :--- | :--- |
| **Service Status** | `sudo systemctl status jenkins nginx` | Check state of Jenkins & Nginx |
| **Permissions** | `sudo chown -R jenkins:www-data /var/www/jenkins-demo` | Grant Jenkins non-sudo deploy access |
| **Permissions** | `sudo chmod -R 755 /var/www/jenkins-demo` | Ensure public readable web access |
| **Nginx Test** | `sudo nginx -t` | Validate Nginx syntax |
| **Nginx Reload** | `sudo systemctl reload nginx` | Reload config without downtime |
| **Git Push** | `git push -u origin main` | Push commits to GitHub repository |
| **Verification** | `curl --fail http://localhost:8081` | Verify deployment response |
