pipeline {
    agent any

    environment {
        K8S_NAMESPACE = 'default'           // Namespace of the Drupal pod
        CONTAINER_NAME = 'drupal'           // Drupal container name
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
                        script: "kubectl get pods -n ${env.K8S_NAMESPACE} -l app=drupal -o jsonpath={.items[0].metadata.name}",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Copy Code into Drupal Pod') {
            steps {
                script {
                    sh "kubectl cp ./src ${env.K8S_NAMESPACE}/${env.POD_NAME}:/var/www/html/modules/custom -c ${env.CONTAINER_NAME}"
                }
            }
        }

        stage('Clear Drupal Cache') {
            steps {
                sh "kubectl exec -n ${env.K8S_NAMESPACE} ${env.POD_NAME} -c ${env.CONTAINER_NAME} -- drush cr"
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
