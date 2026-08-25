pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jagasri2026/kanban-dashboard'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        CONTAINER_NAME = 'kanban-dashboard'
        APP_PORT = '8081'
        CONTAINER_PORT = '8080'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Generate Git SHA') {
            steps {
                script {
                    env.GIT_SHA = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Git SHA: ${env.GIT_SHA}"
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t ${IMAGE_NAME}:${GIT_SHA} \
                      .
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKER_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                          -u "$DOCKER_USERNAME" \
                          --password-stdin

                        docker push ${IMAGE_NAME}:${GIT_SHA}

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                    docker pull ${IMAGE_NAME}:${GIT_SHA}
                    rm -f previous_image.txt
                    docker inspect ${CONTAINER_NAME} --format='{{.Config.Image}}' > previous_image.txt 2>/dev/null || true

                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      --memory 512m \
                      --cpus 0.5 \
                      -p ${APP_PORT}:${CONTAINER_PORT} \
                      ${IMAGE_NAME}:${GIT_SHA}
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 10

                    curl --fail \
                      http://127.0.0.1:${APP_PORT}/ \
                      > /dev/null

                    docker ps --filter "name=${CONTAINER_NAME}" \
                      --filter "status=running"
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            sh '''
                if [ -s previous_image.txt ]; then
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      --memory 512m \
                      --cpus 0.5 \
                      -p ${APP_PORT}:${CONTAINER_PORT} \
                      $(cat previous_image.txt)
                    echo "Rollback completed successfully."
                else
                    echo "No previous image available for rollback."
                fi
            '''
            echo 'CI/CD pipeline failed.'
        }
    }
}
