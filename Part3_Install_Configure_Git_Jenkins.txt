# Part 3: Install and Configure Git and Jenkins on Ubuntu Linux

**Student Name**: Aditya Gupta  
**Course**: DevOps Foundations & Continuous Integration  
**Lab Assignment**: Lab 1 - DevOps Foundations & CI  
**Repository**: https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git  
**Marks Weightage**: 5 Marks  

---

## 1. Installation of Git, Java, and Jenkins on Ubuntu Linux

### Step 1.1: Update System Packages
```bash
sudo apt update && sudo apt upgrade -y
```

### Step 1.2: Install Git & Core Utilities
```bash
sudo apt install -y git rsync curl software-properties-common
```

### Step 1.3: Verify Git Installation
```bash
git --version
```
- **Output**: `git version 2.34.1` (or higher)

### Step 1.4: Install Java OpenJDK 17 (Prerequisite for Jenkins)
```bash
sudo apt install -y openjdk-17-jre
java -version
```

### Step 1.5: Install Jenkins LTS
```bash
# Add Jenkins GPG Key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins Debian Repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt update
sudo apt install -y jenkins
```

### Step 1.6: Enable and Start Jenkins Service
```bash
sudo systemctl enable --now jenkins
sudo systemctl status jenkins
```

---

## 2. Global Git Configuration

Configure global user credentials and default branch name on Ubuntu Linux:

```bash
# Set global User Name
git config --global user.name "Aditya Gupta"

# Set global User Email
git config --global user.email "ag6830221@gmail.com"

# Set default branch name to main
git config --global init.defaultBranch main

# Verify global configuration settings
git config --list --global
```

### Verified Output:
```
user.name=Aditya Gupta
user.email=ag6830221@gmail.com
init.defaultbranch=main
```

---

## 3. Jenkins Initial Configuration & Plugin Setup

1. **Access Initial Setup**:
   - Open browser at `http://localhost:8080`
   - Retrieve initial admin password:
     ```bash
     sudo cat /var/lib/jenkins/secrets/initialAdminPassword
     ```
2. **Install Required Plugins**:
   Navigate to **Manage Jenkins** → **Plugins** → **Available Plugins** and install:
   - `Pipeline` (Core pipeline execution engine)
   - `Git` (Git SCM integration)
   - `GitHub` (GitHub trigger & repository integration)
   - `Credentials Binding` (Secure credentials store)
   - `Workspace Cleanup` (`cleanWs` support)
3. **Restart Jenkins to Finalize Plugins**:
   ```bash
   sudo systemctl restart jenkins
   ```
