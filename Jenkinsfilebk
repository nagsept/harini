pipeline {
    agent any

    environment {
        K8S_NAMESPACE = 'default'           // Namespace of the Drupal pod
        CONTAINER_NAME = 'drupal'           // Drupal container name
        KUBECTL_IMAGE = 'bitnami/kubectl:latest'
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
                        script: """
                        docker run --rm -v ~/.kube:/root/.kube ${KUBECTL_IMAGE} \
                        get pods -n ${env.K8S_NAMESPACE} -l app=drupal -o jsonpath='{.items[0].metadata.name}'
                        """,
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Copy Code into Drupal Pod') {
            steps {
                script {
                    sh """
                    docker run --rm -v ~/.kube:/root/.kube -v ${env.WORKSPACE}:/app ${KUBECTL_IMAGE} \
                    cp /app/src ${env.K8S_NAMESPACE}/${env.POD_NAME}:/var/www/html/modules/custom -c ${env.CONTAINER_NAME}
                    """
                }
            }
        }

        stage('Clear Drupal Cache') {
            steps {
                sh """
                docker run --rm -v ~/.kube:/root/.kube ${KUBECTL_IMAGE} \
                exec -n ${env.K8S_NAMESPACE} ${env.POD_NAME} -c ${env.CONTAINER_NAME} -- drush cr
                """
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
