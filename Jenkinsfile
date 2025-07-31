pipeline {
    agent {
        docker {
            image 'bitnami/kubectl:latest' // ✅ Image that has kubectl pre-installed
            args '-v /var/run/docker.sock:/var/run/docker.sock' // optional if docker commands needed
        }
    }

    environment {
        K8S_NAMESPACE = 'default'
        CONTAINER_NAME = 'drupal'
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
