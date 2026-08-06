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
        stage('Build Image') {
            steps {
                sh 'docker build -t fastapi-backend -f ./src/Dockerfile .'
            }
        }
        stage('Push Backend Image') {
            steps {
                echo 'Logging into Docker Hub and pushing the image...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PWD')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag fastapi-backend $DOCKER_USER/fastapi:1.0'
                    sh 'docker push $DOCKER_USER/fastapi:1.0'
                }
            }
        }
    }
}