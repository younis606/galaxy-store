pipeline {
    agent any

    tools {
        nodejs 'nodejs-22-6-0'
    }

    environment {
        MONGO_URI = 'mongodb+srv://supercluster.d83jj.mongodb.net/superData'
        MONGO_USERNAME = credentials('mongo-db-username')
        MONGO_PASSWORD = credentials('mongo-db-password')
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo " Installing dependencies for galaxy-store application"
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