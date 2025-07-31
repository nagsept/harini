pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/nagsept/harini.git'
        BRANCH = 'kubectl'
        KUBE_CONTEXT = 'docker-desktop'
        POD_NAME = 'drupal-75bff6858f-tnn2v'
        NAMESPACE = 'default'
        TARGET_PATH = '/var/www/html'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: "${REPO_URL}", branch: "${BRANCH}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t harini-app .'
            }
        }

        stage('Copy Code into Drupal Pod') {
            steps {
                script {
                    sh """
                        kubectl config use-context $KUBE_CONTEXT
                        kubectl cp . $POD_NAME:$TARGET_PATH -n $NAMESPACE
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Code deployed into existing Drupal pod.'
        }
        failure {
            echo '❌ Deployment failed.'
        }
    }
}
