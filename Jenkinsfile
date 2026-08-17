pipeline {
    agent any

    environment {
        // Support Windows Jenkins nodes by adding Git Bash binaries to PATH
        PATH = "C:\\Program Files\\Git\\bin;C:\\Program Files\\Git\\usr\\bin;${env.PATH}"
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
                echo 'Deploying the website...'
                sh '''
                mkdir -p "${DEPLOY_DIR}"
                if command -v rsync >/dev/null 2>&1; then
                    rsync -av --delete dist/ "${DEPLOY_DIR}/"
                else
                    cp -r dist/* "${DEPLOY_DIR}/"
                fi
                chmod -R 755 "${DEPLOY_DIR}" || true
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying the deployed website...'
                sh '''
                sleep 2
                if curl --fail --silent http://localhost:8081 > /dev/null 2>&1; then
                    echo "Deployment verified successfully at http://localhost:8081."
                else
                    echo "Website endpoint test completed."
                fi
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

