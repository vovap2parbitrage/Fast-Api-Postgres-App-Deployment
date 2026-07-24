pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Successfuly downloaded the code from Github'
            }
        }
        stage('Check Docker engine') {
            steps {
                echo 'Checking Jenkins connection with Docker'
                sh 'docker --version'
            }
        }
        stage('Build API image') {
            steps {
                echo 'Building the FastAPI docker image'
                sh 'docker build -t fastapi-backend -f ./src/Dockerfile .'
            }
        }
    }
}