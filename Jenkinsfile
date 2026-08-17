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
