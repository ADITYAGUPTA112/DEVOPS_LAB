# Part 4: Version Control Setup using Git - Repository Initialization, Branching, Merging & GitHub Push

**Student Name**: Aditya Gupta  
**Course**: DevOps Foundations & Continuous Integration  
**Lab Assignment**: Lab 1 - DevOps Foundations & CI  
**Repository**: https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git  
**Marks Weightage**: 5 Marks  

---

## 1. Repository Initialization & Initial Commit

```bash
# Navigate to project root directory
cd ~/jenkins-nginx-demo

# Initialize empty Git repository
git init

# Rename default branch to main
git branch -M main

# Check initial status
git status

# Stage all files (index.html, style.css, Jenkinsfile, nginx config, scripts, README)
git add .

# Create initial commit
git commit -m "Add Jenkins Nginx CI-CD project setup and configuration"
```

---

## 2. Branching & Merging Workflow

Demonstrating feature branch creation, file modification, and merging back to `main`:

```bash
# 1. Create and switch to a feature branch
git checkout -b feature/update-header

# 2. Modify index.html header on feature branch
# (e.g., updating <h1> heading)

# 3. Stage and commit changes on feature branch
git add index.html
git commit -m "Update website heading in feature branch"

# 4. Switch back to main branch
git checkout main

# 5. Merge feature branch into main
git merge feature/update-header

# 6. Delete feature branch after successful merge
git branch -d feature/update-header
```

---

## 3. Remote Repository Setup & GitHub Push

```bash
# Add GitHub remote repository URL
git remote add origin https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git

# Verify remote URL configuration
git remote -v

# Push main branch to remote GitHub repository and set tracking upstream
git push -u origin main
```

### Verified Terminal Output:
```
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 12 threads
Compressing objects: 100% (10/10), done.
Writing objects: 100% (12/12), 3.42 KiB | 3.42 MiB/s, done.
Total 12 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## 4. Commit Log & Remote Status Verification

```bash
# Display full commit history
git log --oneline --graph --decorate
```

### Verified Log Output:
```
* ecbb127 (HEAD -> main, origin/main) Add complete DevOps lab report document
* 0d43c94 Add DEVOPS_LAB section to README
* 8669601 Add Jenkins Nginx CI-CD project setup and configuration
```

### Remote Repository Verification:
- **Repository URL**: `https://github.com/ADITYAGUPTA112/DEVOPS_LAB.git`
- **Tracked Branch**: `main`
- **Status**: Synchronized with `origin/main`
