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

        stage('Run Unit Tests') {
            steps {
                container('docker') {
                    dir('K3S_Manifests/Mod3_Task5/flask_app') {
                        sh '''
                          echo "Running unit tests..."
                          echo "Current directory: $(pwd)"
                          echo "Files:"
                          ls -la

                          # Use absolute path to ensure Docker sees the correct mounted directory
                          MOUNT_DIR=$(pwd)

                          docker run --rm \
                            -v "$MOUNT_DIR":/app \
                            -w /app \
                            python:3.11 \
                            sh -c "pip install flask && python test_main.py"
                        '''
                    }
                }
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
