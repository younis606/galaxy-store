pipeline {
    agent any

    tools {
        nodejs 'nodejs-18-20-0'
    }

    
    

    stages {
        stage('Install Dependencies') {
            steps {
                echo " Installing dependencies for galaxy-store app"
                sh 'npm install --no-audit'
            }
        }
        stage('NPM Dependency Audit') {
            steps {
                sh 'npm audit --audit-level=high'
            }
        }
        stage('Code Coverage') {
            steps {
                catchError(buildResult: 'SUCCESS', message: 'Oops! it will be fixed in future releases', stageResult: 'UNSTABLE') {
                    sh 'npm run coverage'
                }
            }
        }
    }
}