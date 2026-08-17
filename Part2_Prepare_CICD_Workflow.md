# Part 2: CI/CD Workflow Report - Architecture, Stages & Automation Results

**Student Name**: Aditya Gupta  
**Course**: DevOps Foundations & Continuous Integration  
**Lab Assignment**: Lab 1 - DevOps Foundations & CI  
**Repository**: https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git  
**Marks Weightage**: 10 Marks  

---

## 1. CI/CD Pipeline Architecture & Component Flow

The CI/CD workflow establishes automated continuous integration and continuous deployment between **GitHub**, **Jenkins**, and **Nginx**.

```
 +------------------+           +------------------+           +----------------------+
 |                  | git push  |                  | pollSCM   |                      |
 | Developer Workstation | ------> | GitHub Repository| <-------- |    Jenkins Server    |
 |                  |           | (DEVOPS_LAB.git) |           |  (http://localhost:8080)
 +------------------+           +------------------+           +----------+-----------+
                                                                          |
                                                                          | Pipeline Stages
                                                                          v
 +------------------------------------------------------------------------------------+
 | 1. Checkout SCM  --> Downloads latest commit from main branch                      |
 | 2. Build Stage   --> Creates dist/ directory & copies static assets (HTML/CSS)      |
 | 3. Test Stage    --> Executes automated grep/file assertions (HTML syntax checks)   |
 | 4. Deploy Stage  --> Non-sudo rsync sync to /var/www/jenkins-demo                   |
 | 5. Verify Stage  --> Executes curl HTTP check against http://localhost:8081        |
 +------------------------------------------------------------------------------------+
                                                                          |
                                                                          v
                                                               +----------------------+
                                                               |  Nginx Web Server    |
                                                               | (http://localhost:8081)|
                                                               +----------------------+
```

---

## 2. Detailed Breakdown of Pipeline Stages

### Stage 1: SCM Checkout
- **Mechanism**: Jenkins Git plugin connects to `https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git`.
- **Branch**: `*/main`
- **Script Path**: `Jenkinsfile`

### Stage 2: Build Stage
- **Objective**: Packages static assets into a release-ready directory structure `dist/`.
- **Groovy Snippet**:
  ```groovy
  stage('Build') {
      steps {
          echo 'Preparing deployable files...'
          sh '''
          mkdir -p dist
          cp index.html style.css dist/
          '''
      }
  }
  ```

### Stage 3: Test Stage
- **Objective**: Runs sanity and structural validation on the prepared build artifacts before deployment.
- **Groovy Snippet**:
  ```groovy
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
  ```

### Stage 4: Deploy Stage
- **Objective**: Deploys valid code to the Nginx production web folder `/var/www/jenkins-demo` cleanly using `rsync`.
- **Groovy Snippet**:
  ```groovy
  stage('Deploy') {
      steps {
          echo 'Deploying the website to Nginx...'
          sh '''
          rsync -av --delete dist/ "${DEPLOY_DIR}/"
          chmod -R 755 "${DEPLOY_DIR}"
          '''
      }
  }
  ```

### Stage 5: Verify Deployment
- **Objective**: Performs an automated HTTP health check against the live Nginx endpoint.
- **Groovy Snippet**:
  ```groovy
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
  ```

### Post-Execution Cleanup
- **Always block**: Runs `cleanWs()` to clear workspace files after execution, keeping Jenkins storage efficient.

---

## 3. Automation Results & Execution Paths

### Success Path Execution Flow:
```
[Checkout SCM] ---> [Build: OK] ---> [Test: OK] ---> [Deploy: OK] ---> [Verify: OK] ---> [Pipeline Status: GREEN]
```
- **Console Log Output**:
  ```
  Preparing deployable files...
  Testing website...
  All tests passed.
  Deploying the website to Nginx...
  sending incremental file list
  dist/index.html
  dist/style.css
  Verifying the deployed website...
  Deployment verified successfully.
  CI/CD pipeline completed successfully.
  Website: http://localhost:8081
  Finished: SUCCESS
  ```

### Failure Path Execution Flow (CI Protection):
```
[Checkout SCM] ---> [Build: OK] ---> [Test: FAILED (Exit Code 1)] ---> [Deploy: SKIPPED] ---> [Pipeline Status: RED]
```
- **Console Log Output**:
  ```
  Testing website...
  + test -f dist/index.html
  + test -f dist/style.css
  + grep -qi <html> dist/index.html
  + grep -qi <title> dist/index.html
  ERROR: script returned exit code 1
  Stage 'Test' skipped remaining steps
  Stage 'Deploy' skipped due to earlier failure(s)
  Pipeline failed. The website was not successfully deployed.
  Finished: FAILURE
  ```

---

## 4. Observations & Key Engineering Insights

1. **Non-Root Privilege Deployment**:
   By assigning `/var/www/jenkins-demo` ownership to `jenkins:www-data` with mode `755`, Jenkins deploys files without needing `sudo` rights in scripts, adhering to least-privilege security principles.
2. **SCM Polling vs Webhooks**:
   Because local test servers behind NAT/firewalls cannot receive public GitHub webhooks (`http://localhost:8080/github-webhook/`), using `pollSCM('H/2 * * * *')` provides robust periodic change detection without external IP requirements.
3. **Deployment Safety Guarantee**:
   The pipeline enforces strict sequential dependence: deployment happens **only** after 100% of test assertions pass. Broken code is trapped in the CI stage, ensuring zero downtime or corruption on the production web server.
