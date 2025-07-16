// pipeline {
//     agent any
//     environment {
//         REGISTRY = 'eckanas/rsschool_flask_app'
//         IMAGE_TAG = "${env.GIT_COMMIT}"
//         DOCKER_BUILDKIT = '1'
//     }
//     stages {
//         stage('Checkout') {
//             steps {
//                 checkout scm
//             }
//         }
//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     dir('K3S_Manifests/Mod3_Task5/flask_app') {
//                         sh 'docker build -t $REGISTRY:$IMAGE_TAG .'
//                     }
//                 }
//             }
//         }
//         stage('Push Docker Image') {
//             steps {
//                 sh 'docker push $REGISTRY:$IMAGE_TAG'
//             }
//         }
//     }
// } 

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
        stage('Push Docker Image') {
            steps {
                container('docker') {
                    sh 'docker push $REGISTRY:$IMAGE_TAG'
                }
            }
        }
    }
}
