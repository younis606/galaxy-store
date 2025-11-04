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
                sh 'npm audit --audit-level=high || true'
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
                echo 'Skipping Quality Gate for now'
                // timeout(time: 1, unit: 'MINUTES') {
                //     waitForQualityGate abortPipeline: true
                // }
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'Skipping Unit Tests temporarily'
                // sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image for Galaxy Store...'
                    sh 'docker build -t younis606/galaxy-store:${GIT_COMMIT} .'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    echo 'Scanning Docker image for vulnerabilities with Trivy...'
                    sh '''
                    trivy image --exit-code 0 --format json \
                    -o trivy-image-HIGH-CRITICAL-results.json \
                    --severity HIGH,CRITICAL younis606/galaxy-store:${GIT_COMMIT}
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub...'
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push younis606/galaxy-store:${GIT_COMMIT}
                        '''
                    }
                }
            }
        }
       stage('Update and Commit Image Tag') {
    steps {
        script {
            withCredentials([string(credentialsId: 'git-token', variable: 'GITHUB_TOKEN')]) {
                sh '''
                echo "Updating image tag in GitOps repo..."
                rm -rf galaxy-store-gitops
                git clone -b feature https://github.com/younis606/galaxy-store-gitops.git
                cd galaxy-store-gitops
                git checkout -b feature-$BUILD_ID
                cd kubernetes
                if [ -f deployment.yml ]; then
                    sed -i "s#image: .*#image: younis606/galaxy-store:${GIT_COMMIT}#g" deployment.yml
                else
                    echo "deployment.yml not found!"
                    exit 1
                fi
                git config user.name "Jenkins Automation"
                git config user.email "ci-bot@galaxy-store.local"
                git remote set-url origin https://$GITHUB_TOKEN@github.com/younis606/galaxy-store-gitops.git
                git add .
                git commit -m "Update image tag to ${GIT_COMMIT}"
                git push origin feature-$BUILD_ID
                '''
            }
        }
    }
}


stage('Kubernetes Deployment - Raise PR') {
    steps {
        script {
            withCredentials([string(credentialsId: 'git-token', variable: 'GITHUB_TOKEN')]) {
                sh '''
                echo "Creating Pull Request on GitHub..."
                curl -X POST \
                  -H "Authorization: token $GITHUB_TOKEN" \
                  -H "Accept: application/vnd.github.v3+json" \
                  https://api.github.com/repos/younis606/galaxy-store-gitops/pulls \
                  -d '{
                    "title": "Updated Docker Image to ${GIT_COMMIT}",
                    "head": "feature-${BUILD_ID}",
                    "base": "feature",
                    "body": "Automated PR created by Jenkins pipeline to update deployment image tag."
                  }'
                '''
            }
        }
    }
}
            stage('ZAP API Scan') {
    steps {
        withCredentials([string(credentialsId: 'API_ENDPOINT', variable: 'API_ENDPOINT')]) {
            sh '''
               docker run --rm \
              -v $WORKSPACE:/zap/wrk/:rw \
              ghcr.io/zaproxy/zaproxy \
              zap-api-scan.py \
             -t ${API_ENDPOINT}/api-docs/ \
             -f openapi \
             -r zap_report.html \
             -w zap_report.md \
             -J zap_json_report.json \
             -z "-config connection.ssl.acceptAllCertificates=true" || [ $? -eq 2 ]

              '''

        }
    }
    
}
       
    }

}post {
    always {
        script {
            echo "Cleaning up workspace..."
            if (fileExists('galaxy-store-gitops')) {
                sh 'rm -rf galaxy-store-gitops'
            }
        }

        echo " Publishing test and coverage reports..."

        junit allowEmptyResults: true, testResults: 'test-results.xml'

        publishHTML([
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'coverage/lcov-report',
            reportFiles: 'index.html',
            reportName: 'Galaxy Store - Code Coverage',
            reportTitles: 'Test Coverage Results',
            useWrapperFileDirectly: true
        ])
    }

    failure {
        echo " Pipeline failed! Check logs above for errors."
    }

    success {
        echo " Galaxy Store pipeline completed successfully!"
    }
}
