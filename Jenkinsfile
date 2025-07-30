pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/nagsept/harini.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t harini-app .'
            }
        }

        stage('Run Docker Container') {
            steps {
                sh 'docker run -d --name harini-container -p 8080:8080 harini-app'
            }
        }
    }

    post {
        success {
            echo '✅ Deployed successfully.'
        }
        failure {
            echo '❌ Deployment failed.'
        }
    }
}
