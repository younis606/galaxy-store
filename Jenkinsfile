pipeline {
    agent any

    tools {
        nodejs 'nodejs-18-20-0'
    }

    environment {
        SONAR_URL = 'http://54.147.4.6:9000'
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo 'Cloning repository from GitHub...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "Installing dependencies for galaxy-store app"
                sh 'npm install --no-audit'
            }
        }

        stage('NPM Dependency Audit') {
            steps {
                sh 'npm audit --audit-level=high'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv('sonar-scanner') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=galaxy-app \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=$SONAR_URL \
                          -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'skip for now'
              //  timeout(time: 1, unit: 'MINUTES') {
                //    waitForQualityGate abortPipeline: true
                }    
            }
        }    
        stage('Unit Tests') {
            
            steps {
                echo 'Skipping Unit Tests temporarily...'
                 sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image for Galaxy Store..."
                    sh 'docker build -t younis606/galaxy-store:${GIT_COMMIT} .'
                }
            }
        }
    }
}
