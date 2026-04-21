pipeline {
    agent any

    stages {
        stage ('1. Checkout code') {
            steps {
                checkout scm
            }
        }
        stage ('2. Build Docker Build') {
            steps {
                sh 'docker build -t sriramsrb/library4:latest .'
            }
        }
        stage ('3. Push docker image') {
            steps {
                withCredentials ([string(credentialsId: 'dockerhub_user', variable: 'DOCKER_PWD')]) {
                    sh 'echo "$DOCKER_PWD" | docker login -u sriramsrb --password-stdin'
                    sh 'docker push sriramsrb/library4:latest'
                }
            }
        }
        stage ('4. Deploy to kubernetes') {
            steps {
                sh 'kubectl apply -f deployment.yml'
                sh 'kubectl rollout restart deployment library4-deployment'
            }
        }
    }
}