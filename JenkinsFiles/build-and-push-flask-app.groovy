pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:24.0.6
    command:
    - sleep
    args:
    - infinity
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  - name: ubuntu
    image: ubuntu
    command:
    - sleep
    args:
    - infinity
    tty: true
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
        SONAR_HOST_URL = 'http://sonar.tuselis.lt'
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
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                        container('ubuntu') {
                            dir('K3S_Manifests/Mod3_Task5/flask_app') {
                                withEnv([
                                    "SONAR_HOST_URL=${env.SONAR_HOST_URL}",
                                    "SONAR_TOKEN=${env.SONAR_TOKEN}"
                                ]) {
                                    sh '''
                                    apt-get update && apt-get install -y wget unzip openjdk-11-jre

                                    export SONAR_SCANNER_VERSION=5.0.1.3006
                                    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
                                    unzip sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
                                    mv sonar-scanner-$SONAR_SCANNER_VERSION-linux /opt/sonar-scanner
                                    export PATH=$PATH:/opt/sonar-scanner/bin
                                    
                                    sonar-scanner \
                                        -Dsonar.projectKey=Flask-App \
                                        -Dsonar.sources=. \
                                        -Dsonar.host.url=$SONAR_HOST_URL \
                                        -Dsonar.token=$SONAR_TOKEN
                                    '''
                                }
                            }
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

        stage('Deploy with Helm') {
            steps {
                container('docker') {
                    sh '''
                    if ! command -v helm > /dev/null; then
                      wget https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
                      tar -zxvf helm-v3.14.4-linux-amd64.tar.gz
                      mv linux-amd64/helm /usr/local/bin/helm
                    fi
                    if ! command -v kubectl > /dev/null; then
                      wget https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl
                      chmod +x kubectl
                      mv kubectl /usr/local/bin/
                    fi
                    '''
                    dir('K3S_Manifests/Mod3_Task5/flask_app_HelmChart') {
                        sh '''
                        helm upgrade --install flask-app . \
                          --namespace default \
                          --set image.repository=$REGISTRY \
                          --set image.tag=$IMAGE_TAG
                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                container('ubuntu') {
                    sh '''
                    if ! command -v curl > /dev/null; then
                      apt-get update && apt-get install -y curl
                    fi

                    echo "Verifying deployment at http://flask-app.tuselis.lt ..."
                    for i in {1..10}; do
                      if curl -sf http://flask-app.tuselis.lt; then
                        echo "Deployment verified!"
                        exit 0
                      else
                        echo "Waiting for app to become available... ($i/10)"
                        sleep 10
                      fi
                    done

                    echo "ERROR: Application not reachable at http://flask-app.tuselis.lt"
                    exit 1
                    '''
                }
            }
        }
    }
    post {
        success {
            emailext (
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Good news! Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' succeeded.\nCheck details at: ${env.BUILD_URL}",
                to: "${env.NOTIFY_EMAIL}"
            )
        }
        failure {
            emailext (
                subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Unfortunately, job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' failed.\nCheck details at: ${env.BUILD_URL}",
                to: "${env.NOTIFY_EMAIL}"
            )
        }
    }
}


