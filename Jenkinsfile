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
                echo 'Installing dependencies for galaxy-store app'
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
                // timeout(time: 1, unit: 'MINUTES') {
                //     waitForQualityGate abortPipeline: true
                // }
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'Skipping Unit Tests temporarily...'
                // sh 'npm test'
            }
        }

        stage('Build Image with nerdctl') {
            steps {
                script {
                    echo 'Building container image for Galaxy Store with nerdctl...'
                    sh 'nerdctl build -t younis606/galaxy-store:${GIT_COMMIT} .'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    echo 'Scanning container image for vulnerabilities with Trivy...'
                    sh '''
                    trivy image --exit-code 0 --format json \
                    -o trivy-image-HIGH-CRITICAL-results.json \
                    --severity HIGH,CRITICAL younis606/galaxy-store:${GIT_COMMIT}
                    '''
                }
            }
        }

        stage('Push Image with nerdctl') {
            steps {
                script {
                    echo 'Pushing container image to Docker Hub...'
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh '''
                        echo "$DOCKER_PASS" | nerdctl login -u "$DOCKER_USER" --password-stdin docker.io
                        nerdctl push younis606/galaxy-store:${GIT_COMMIT}
                        '''
                    }
                }
            }
        }

        stage('Update and Commit Image Tag') {
            steps {
                script {
                    sh '''
                    echo "Updating image tag in gitops repo..."
                    git clone -b main https://github.com/younis606/galaxy-store-gitops
                    cd galaxy-store-gitops/kubernetes

                    sed -i "s#image: .*#image: younis606/galaxy-store:${GIT_COMMIT}#g" deployment.yml

                    git config user.name "Jenkins Automation"
                    git config user.email "ci-bot@galaxy-store.local"

                    git remote set-url origin https://$GITHUB_TOKEN@github.com/younis606/galaxy-store-gitops.git
                    git add .
                    git commit -m "Update image tag to ${GIT_COMMIT}"
                    git push origin main
                    '''
                }
            }
        }

    }
}
