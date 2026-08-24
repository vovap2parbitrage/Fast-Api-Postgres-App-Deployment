pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Source code checked out successfully'
            }
        }
        stage('Provision Infrastructure') {
            steps {
                dir('terraform') {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        echo 'Running Terraform via Makefile...'
                        sh 'make'
                    }
                }
            }
        }
        stage('Check Docker Engine') {
            steps {
                echo 'Checking Docker Engine version'
                sh 'docker --version'
            }
        }
        stage('Build Backend Image') {
            steps {
                sh 'docker build -t fastapi-backend ./src'
                echo 'The backend image has been successfully created'
            }
        }
        stage('Push Backend Image') {
            steps {
                echo 'Logging into Docker Hub and pushing the image...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag fastapi-backend $DOCKER_USER/fastapi-backend:$BUILD_NUMBER'
                    sh 'docker push $DOCKER_USER/fastapi-backend:$BUILD_NUMBER'
                }
            }
        }
        stage('Build Frontend Image') {
            steps {
                sh 'docker build -t vue-frontend ./vue-client'
                echo 'The frontend image has been successfully created'
            }
        }
        stage('Push Frontend Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag vue-frontend $DOCKER_USER/vue-frontend:$BUILD_NUMBER'
                    sh 'docker push $DOCKER_USER/vue-frontend:$BUILD_NUMBER'
                }
            }
        }
        stage('Deploy to AWS') { 
            steps {
                script {
                    dir('terraform') {
                        def EC2_IP = sh(script: 'terraform output -raw instance_ip', returnStdout: true).trim()
                        
                        sshagent(credentials: ['ec2-ssh-key']) {
                            withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                                sh """
                                    scp -o StrictHostKeyChecking=no ../docker-compose.yml ubuntu@${EC2_IP}:/home/ubuntu/docker-compose.yml
                                    ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} '
                                        export APP_VERSION=${BUILD_NUMBER}
                                        export DOCKER_USER=${DOCKER_USER}

                                        docker compose pull
                                        docker compose up -d
                                    '
                                """
                            }
                        }
                    }
                }
            }
        }
    }
}