pipeline {
    agent {
        node {
            label 'docker-agent'
        }
    }
    parameters {
        string(name: 'VERSION', defaultValue: "1.0.${BUILD_NUMBER}", description: 'Docker image version')
        string(name: 'DB_HOST', defaultValue: 'app42-db', description: 'Docker image version')
        string(name: 'DB_NAME', defaultValue: 'app42', description: 'Docker image version')
        string(name: 'DB_USER', defaultValue: 'app42', description: 'Docker image version')
    }
    stages {
        stage('Build and Push docker image') {
            agent {
                docker {
                    image 'docker:cli'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            environment {
                DB_PASSWORD = credentials('db_password')
            }
            steps {
                dir('app42') {
                    script {
                        writeFile(
                            file: 'db_password',
                            text: DB_PASSWORD
                        )
                        def image = docker.build(
                            "abegorov/app42:${VERSION}",
                            "--build-arg=\"DB_HOST=${DB_HOST}\" " +
                            "--build-arg=\"DB_NAME=${DB_NAME}\" " +
                            "--build-arg=\"DB_USER=${DB_USER}\" " +
                            "--secret id=db_password " +
                            "."
                        )
                        docker.withRegistry('', 'dockerhub_credentials') {
                            image.push()
                        }
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            environment {
                DB_PASSWORD = credentials('db_password')
            }
            steps {
                dir('app42') {
                    sh 'sed -i "s@{{VERSION}}@${VERSION}@" kube-app42.yml'
                    sh 'sed -i "s@{{DB_HOST}}@${DB_HOST}@" kube-mysql.yml'
                    sh 'sed -i "s@{{DB_NAME}}@${DB_NAME}@" kube-mysql.yml'
                    sh 'sed -i "s@{{DB_USER}}@${DB_USER}@" kube-mysql.yml'
                    sh 'sed -i "s@{{DB_PASSWORD}}@${DB_PASSWORD}@" kube-mysql.yml'
                    withKubeConfig(
                            caCertificate: '''-----BEGIN CERTIFICATE-----
    MIIBiTCCAS6gAwIBAgIBADAKBggqhkjOPQQDAjA7MRwwGgYDVQQKExNkeW5hbWlj
    bGlzdGVuZXItb3JnMRswGQYDVQQDExJkeW5hbWljbGlzdGVuZXItY2EwHhcNMjMw
    OTAzMTcyNzQyWhcNMzMwODMxMTcyNzQyWjA7MRwwGgYDVQQKExNkeW5hbWljbGlz
    dGVuZXItb3JnMRswGQYDVQQDExJkeW5hbWljbGlzdGVuZXItY2EwWTATBgcqhkjO
    PQIBBggqhkjOPQMBBwNCAAQM14zbi9NtGYwIlLJRiMvOziKO34Zia5kQwcTc39o9
    uGQAibxvMLKDfANmMn570WeFN3Pu57+uBZI/dRU5TjYloyMwITAOBgNVHQ8BAf8E
    BAMCAqQwDwYDVR0TAQH/BAUwAwEB/zAKBggqhkjOPQQDAgNJADBGAiEAgk+uk1UF
    KnlsxzstzV6+0akvftM2ERhlhh7P/1JJkLYCIQDW4BvPDBAagrwdpWARa9hBM7qM
    X5YrutqC/+V17gukmg==
    -----END CERTIFICATE-----''',
                            clusterName: 'abe',
                            contextName: 'abe',
                            credentialsId: 'kubernetes_token',
                            namespace: 'default',
                            restrictKubeConfigAccess: false,
                            serverUrl: 'https://158.160.82.49/k8s/clusters/c-8fprf') {
                        sh 'kubectl apply -f kube-app42.yml'
                        sh 'kubectl apply -f kube-mysql.yml'
                    }
                }
            }
        }
    }
}
