pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Successfuly downloaded the code from Github'
            }
        }
        stage('Test pipeline') {
            steps {
                echo 'Hello World!'
                sh 'ls -la'
            }
        }
    }
}