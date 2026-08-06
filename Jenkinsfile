pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Source code checked out successfully'
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
                sh 'docker build -t fastapi-backend -f ./src/Dockerfile .'
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
    }
}