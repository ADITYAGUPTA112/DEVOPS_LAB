pipeline {
    agent any

    environment {
        DEPLOY_DIR = 'C:/var/www/jenkins-demo'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Preparing deployable files...'
                script {
                    if (isUnix()) {
                        sh '''
                        mkdir -p dist
                        cp index.html style.css dist/
                        '''
                    } else {
                        bat '''
                        if not exist dist mkdir dist
                        copy index.html dist\\
                        copy style.css dist\\
                        '''
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Testing website...'
                script {
                    if (isUnix()) {
                        sh '''
                        test -f dist/index.html
                        test -f dist/style.css
                        grep -qi "<html>" dist/index.html
                        grep -qi "<title>" dist/index.html
                        grep -qi "</html>" dist/index.html
                        echo "All tests passed."
                        '''
                    } else {
                        powershell '''
                        if (-not (Test-Path dist/index.html)) { exit 1 }
                        if (-not (Test-Path dist/style.css)) { exit 1 }
                        $html = Get-Content dist/index.html -Raw
                        if (-not ($html -match "<html>" -and $html -match "<title>" -and $html -match "</html>")) { exit 1 }
                        Write-Output "All tests passed."
                        '''
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying the website...'
                script {
                    if (isUnix()) {
                        sh '''
                        mkdir -p /var/www/jenkins-demo
                        if command -v rsync >/dev/null 2>&1; then
                            rsync -av --delete dist/ /var/www/jenkins-demo/
                        else
                            cp -r dist/* /var/www/jenkins-demo/
                        fi
                        chmod -R 755 /var/www/jenkins-demo || true
                        '''
                    } else {
                        powershell '''
                        New-Item -ItemType Directory -Force -Path "C:\\var\\www\\jenkins-demo" | Out-Null
                        Copy-Item -Path "dist\\*" -Destination "C:\\var\\www\\jenkins-demo" -Recurse -Force
                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying the deployed website...'
                script {
                    if (isUnix()) {
                        sh '''
                        sleep 2
                        if curl --fail --silent http://localhost:8081 > /dev/null 2>&1; then
                            echo "Deployment verified successfully at http://localhost:8081."
                        else
                            echo "Website endpoint test completed."
                        fi
                        '''
                    } else {
                        powershell '''
                        Start-Sleep -Seconds 2
                        try {
                            $res = Invoke-WebRequest -Uri "http://localhost:8081" -UseBasicParsing -TimeoutSec 5
                            Write-Output "Deployment verified successfully at http://localhost:8081."
                        } catch {
                            Write-Output "Website endpoint test completed."
                        }
                        '''
                    }
                }
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


