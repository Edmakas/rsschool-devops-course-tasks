pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:24.0.6-cli
    command:
    - cat
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    environment {
        REGISTRY = 'eckanas/rsschool_flask_app'
        IMAGE_TAG = "${env.GIT_COMMIT}"
        DOCKER_BUILDKIT = '1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    dir('K3S_Manifests/Mod3_Task5/flask_app') {
                        sh 'docker build -t $REGISTRY:$IMAGE_TAG .'
                    }
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                container('docker') {
                    sh 'docker run --rm $REGISTRY:$IMAGE_TAG python test_main.py'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                container('docker') {
                    dir('K3S_Manifests/Mod3_Task5/flask_app') {
                        withEnv([
                            'SONAR_HOST_URL=http://sonar.tuselis.lt',
                            'SONAR_TOKEN=sqp_17bffb63df48806e9d1feb669e678c293bc60244'
                        ]) {
                            sh '''
                            docker run --rm \
                              -e SONAR_HOST_URL=$SONAR_HOST_URL \
                              -e SONAR_TOKEN=$SONAR_TOKEN \
                              -v $(pwd):/usr/src \
                              sonarsource/sonar-scanner-cli \
                              sonar-scanner \
                                -Dsonar.projectKey=Flask-APP \
                                -Dsonar.sources=. \
                                -Dsonar.projectBaseDir=/usr/src \
                                -Dsonar.python.version=3
                            '''
                        }
                    }
                }
            }
        }

        stage('Docker Login') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    sh 'docker push $REGISTRY:$IMAGE_TAG'
                }
            }
        }
    }
}
