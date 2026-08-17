# Part 1: Record All Commands, Pipeline Configurations, Commit History, and Observations

**Student Name**: Aditya Gupta  
**Course**: DevOps Foundations & Continuous Integration  
**Lab Assignment**: Lab 1 - DevOps Foundations & CI  
**Repository**: https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git  
**Marks Weightage**: 5 Marks  

---

## 1. System Verification & Package Setup Commands

```bash
# Verify Jenkins service status
sudo systemctl status jenkins

# Verify Nginx service status
sudo systemctl status nginx

# Verify Git installation & version
git --version

# Enable and start Jenkins and Nginx services
sudo systemctl enable --now jenkins
sudo systemctl enable --now nginx

# Update package lists and install required tools
sudo apt update
sudo apt install -y git rsync curl openjdk-17-jre
```

---

## 2. Directory Creation & Permission Setup Commands

```bash
# Create local project directory
mkdir -p ~/jenkins-nginx-demo
cd ~/jenkins-nginx-demo

# Create production deployment directory
sudo mkdir -p /var/www/jenkins-demo

# Set ownership to jenkins user and www-data group
sudo chown -R jenkins:www-data /var/www/jenkins-demo

# Set permissions (read/write/execute for owner, read/execute for group/others)
sudo chmod -R 755 /var/www/jenkins-demo
```

---

## 3. Nginx Server Block Configuration

Configuration path: `/etc/nginx/sites-available/jenkins-demo`

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

### Enable Site and Verify Commands:
```bash
# Create symbolic link to enable website
sudo ln -sf /etc/nginx/sites-available/jenkins-demo /etc/nginx/sites-enabled/jenkins-demo

# Test Nginx syntax configuration
sudo nginx -t

# Reload Nginx to apply changes without downtime
sudo systemctl reload nginx

# Check listening sockets on port 8081
sudo ss -lntp | grep 8081
```

---

## 4. Complete Pipeline Configuration (`Jenkinsfile`)

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

## 5. Git Commands & Commit History

```bash
# Initialize Git repository
git init
git branch -M main

# Configure global git identity
git config --global user.name "Aditya Gupta"
git config --global user.email "ag6830221@gmail.com"

# Stage all files and create commits
git add .
git commit -m "Add Jenkins Nginx CI-CD project setup and configuration"

# Append section to README and commit
echo "# DEVOPS_LAB" >> README.md
git add README.md
git commit -m "Add DEVOPS_LAB section to README"

# Add remote and push main branch
git remote add origin https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git
git push -u origin main
```

### Git Commit Log Output (`git log --stat`):

```
commit ecbb127 (HEAD -> main, origin/main)
Author: Aditya Gupta <ag6830221@gmail.com>
Date:   Mon Aug 17 14:44:20 2026 +0530

    Add complete DevOps lab report document

 DEVOPS_LAB_REPORT.md | 354 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 354 insertions(+)

commit 0d43c94
Author: Aditya Gupta <ag6830221@gmail.com>
Date:   Mon Aug 17 14:42:15 2026 +0530

    Add DEVOPS_LAB section to README

 README.md | 3 +++
 1 file changed, 3 insertions(+)

commit 8669601
Author: Aditya Gupta <ag6830221@gmail.com>
Date:   Mon Aug 17 12:44:44 2026 +0530

    Add Jenkins Nginx CI-CD project setup and configuration

 Jenkinsfile          |  58 +++++++
 README.md            | 258 +++++++++++++++++++++++++++++
 index.html           |  16 ++
 nginx/jenkins-demo.conf |  10 ++
 scripts/setup-nginx.sh  |  37 +++++
 style.css            |  16 ++
 6 files changed, 395 insertions(+)
```

---

## 6. Observations for Each Experiment

### Experiment 1: Deployment & Health Check Verification
- **Command Run**: `curl --fail --silent http://localhost:8081`
- **Result**: Returned HTTP 200 OK with `index.html` payload.
- **Observation**: Nginx served the synced files from `/var/www/jenkins-demo` seamlessly on port 8081.

### Experiment 2: CI Automated Test Pass (Success Scenario)
- **Change**: Updated header text in `index.html` to `<h1>My Website Updated Automatically!</h1>`.
- **Trigger**: SCM Polling (`pollSCM 'H/2 * * * *'`) detected the git push within 2 minutes.
- **Result**: All test assertions passed (`grep` for `<html>`, `<title>`, `</html>`). Deployment succeeded and live site updated.

### Experiment 3: CI Automated Test Failure (Failure Scenario)
- **Change**: Intentionally removed `<title>Jenkins CI/CD Demo</title>` from `index.html`.
- **Trigger**: Git push to `main`.
- **Result**: Stage **Test** failed on `grep -qi "<title>" dist/index.html`.
- **Observation**: Stage **Deploy** was skipped automatically. The live website at `http://localhost:8081` retained the existing working version, demonstrating how CI protects production from faulty code.
