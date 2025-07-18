pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: ubuntu
    image: ubuntu
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

        // stage('Build Docker Image') {
        //     steps {
        //         container('docker') {
        //             dir('K3S_Manifests/Mod3_Task5/flask_app') {
        //                 sh 'docker build -t $REGISTRY:$IMAGE_TAG .'
        //             }
        //         }
        //     }
        // }

        // stage('Run Unit Tests') {
        //     steps {
        //         container('docker') {
        //             sh 'docker run --rm $REGISTRY:$IMAGE_TAG python test_main.py'
        //         }
        //     }
        // }

        stage('SonarQube Scan') {
            steps {
                container('ubuntu') {
                    dir('K3S_Manifests/Mod3_Task5/flask_app') {
                        withEnv([
                            'SONAR_HOST_URL=http://sonar.tuselis.lt',
                            'SONAR_TOKEN=sqp_bb537af4a7bf56e1ec5cac6d855ade31e747cb36'
                        ]) {
                            sh '''
                            # Install wget if not present
                            if ! command -v wget > /dev/null; then
                              apt-get update && apt-get install -y wget
                            fi

                            # Now proceed with sonar-scanner installation
                            export SONAR_SCANNER_VERSION=5.0.1.3006
                            wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
                            unzip sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
                            mv sonar-scanner-$SONAR_SCANNER_VERSION-linux /opt/sonar-scanner
                            export PATH=$PATH:/opt/sonar-scanner/bin

                            sonar-scanner \
                              -Dsonar.projectKey=Flask-App \
                              -Dsonar.sources=. \
                              -Dsonar.projectBaseDir=$(pwd) \
                              -Dsonar.inclusions=**/*.py \
                              -Dsonar.verbose=true \
                              -Dsonar.python.version=3
                            '''
                        }
                    }
                }
            }
        }

        // stage('Docker Login') {
        //     steps {
        //         container('docker') {
        //             withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        //                 sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
        //             }
        //         }
        //     }
        // }

        // stage('Push Docker Image') {
        //     steps {
        //         container('docker') {
        //             sh 'docker push $REGISTRY:$IMAGE_TAG'
        //         }
        //     }
        // }

        // stage('Deploy with Helm') {
        //     steps {
        //         container('docker') {
        //             // Install helm and kubectl if not present
        //             sh '''
        //             if ! command -v helm > /dev/null; then
        //               wget https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
        //               tar -zxvf helm-v3.14.4-linux-amd64.tar.gz
        //               mv linux-amd64/helm /usr/local/bin/helm
        //             fi
        //             if ! command -v kubectl > /dev/null; then
        //               wget https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl
        //               chmod +x kubectl
        //               mv kubectl /usr/local/bin/
        //             fi
        //             '''
        //             // Deploy with helm
        //             dir('K3S_Manifests/Mod3_Task5/flask_app_HelmChart') {
        //                 sh '''
        //                 helm upgrade --install flask-app . \
        //                   --namespace default \
        //                   --set image.repository=$REGISTRY \
        //                   --set image.tag=$IMAGE_TAG \
        //                 '''
        //             }
        //         }
        //     }
        // }

        // stage('Playing with DinD') {
        //     steps {
        //         container('docker') {
        //             // Install helm and kubectl if not present
        //             sh '''
        //             if ! command -v helm > /dev/null; then
        //               wget https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
        //               tar -zxvf helm-v3.14.4-linux-amd64.tar.gz
        //               mv linux-amd64/helm /usr/local/bin/helm
        //             fi
        //             if ! command -v kubectl > /dev/null; then
        //               wget https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl
        //               chmod +x kubectl
        //               mv kubectl /usr/local/bin/
        //             fi
        //             '''
        //             // Deploy with helm
        //             dir('K3S_Manifests/Mod3_Task5/flask_app_HelmChart') {
        //                 sh '''
        //                 helm upgrade --install flask-app . \
        //                   --namespace default \
        //                   --set image.repository=$REGISTRY \
        //                   --set image.tag=$IMAGE_TAG \
        //                 '''
        //             }
        //         }
        //     }
        // }

        // stage('Verify Deployment') {
        //     steps {
        //         container('docker') {
        //             sh '''
        //             # Install curl if not present
        //             if ! command -v curl > /dev/null; then
        //               apk add --no-cache curl
        //             fi
        //             echo "Verifying deployment at http://flask-app.tuselis.lt ..."
        //             for i in {1..10}; do
        //               if curl -sf http://flask-app.tuselis.lt; then
        //                 echo "Deployment verified!"
        //                 exit 0
        //               else
        //                 echo "Waiting for app to become available... ($i/10)"
        //                 sleep 10
        //               fi
        //             done
        //             echo "ERROR: Application not reachable at http://flask-app.tuselis.lt"
        //             exit 1
        //             '''
        //         }
        //     }
        // }
    }
}
