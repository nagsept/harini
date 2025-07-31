pipeline {
    agent any

    environment {
        K8S_NAMESPACE = 'default' // Change if using another namespace
        POD_NAME = ''             // Will be dynamically set
        CONTAINER_NAME = 'drupal' // Your Drupal container name
    }

    stages {
        stage('Clone kubectl Branch') {
            steps {
                git url: 'https://github.com/nagsept/harini.git', branch: 'kubectl'
            }
        }

        stage('Set POD_NAME') {
            steps {
                script {
                    env.POD_NAME = sh(
                        script: "kubectl get pods -n $K8S_NAMESPACE -l app=drupal -o jsonpath='{.items[0].metadata.name}'",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Copy Code into Drupal Pod') {
            steps {
                // Example: copy a custom module to /var/www/html/modules/custom
                sh "kubectl cp ./src $POD_NAME:/var/www/html/modules/custom -n $K8S_NAMESPACE -c $CONTAINER_NAME"
            }
        }

        stage('Clear Cache (Optional)') {
            steps {
                sh "kubectl exec -n $K8S_NAMESPACE $POD_NAME -c $CONTAINER_NAME -- drush cr"
            }
        }
    }

    post {
        success {
            echo '✅ Code deployed to Drupal pod successfully.'
        }
        failure {
            echo '❌ Deployment to Drupal pod failed.'
        }
    }
}
