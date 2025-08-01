pipeline {
    agent any

    environment {
        K8S_NAMESPACE = 'default'
        CONTAINER_NAME = 'drupal'
        KUBECTL_IMAGE = 'bitnami/kubectl:latest'
        KUBECONFIG_PATH = '/var/jenkins_home/.kube/config'
        K8S_API_SERVER_PORT = '8081' // Custom port
    }

    stages {
        stage('Clone kubectl Branch') {
            steps {
                git url: 'https://github.com/nagsept/harini.git', branch: 'kubectl'
            }
        }

        stage('Update kubeconfig Port') {
            steps {
                script {
                    // Replace 8080 with 8081 in the kubeconfig file dynamically (temporary copy)
                    sh """
                    cp ${KUBECONFIG_PATH} kube_temp_config
                    sed -i 's|localhost:8080|localhost:${K8S_API_SERVER_PORT}|g' kube_temp_config
                    """
                }
            }
        }

        stage('Set POD_NAME') {
            steps {
                script {
                    env.POD_NAME = sh(
                        script: """
                        docker run --rm \
                          -v "\${PWD}/kube_temp_config:/root/.kube/config" \
                          ${KUBECTL_IMAGE} \
                          get pods -n ${K8S_NAMESPACE} -l app=drupal -o jsonpath='{.items[0].metadata.name}'
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
                    docker run --rm \
                      -v "\${PWD}/kube_temp_config:/root/.kube/config" \
                      -v ${env.WORKSPACE}:/app \
                      ${KUBECTL_IMAGE} \
                      cp /app/src ${K8S_NAMESPACE}/${POD_NAME}:/var/www/html/modules/custom -c ${CONTAINER_NAME}
                    """
                }
            }
        }

        stage('Clear Drupal Cache') {
            steps {
                sh """
                docker run --rm \
                  -v "\${PWD}/kube_temp_config:/root/.kube/config" \
                  ${KUBECTL_IMAGE} \
                  exec -n ${K8S_NAMESPACE} ${POD_NAME} -c ${CONTAINER_NAME} -- drush cr
                """
            }
        }
    }

    post {
        always {
            sh 'rm -f kube_temp_config'
        }
        success {
            echo '✅ Code deployed to Drupal pod successfully.'
        }
        failure {
            echo '❌ Deployment to Drupal pod failed.'
        }
    }
}
