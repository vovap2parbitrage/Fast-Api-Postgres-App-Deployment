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
    }
}