pipeline {
    agent {
        node {
            label 'docker-agent'
        }
    }
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Docker image version')
    }
    stages {
        stage('Build and Push docker image') {
            agent {
                docker {
                    image 'docker:cli'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                dir('app42') {
                    script {
                        def image = docker.build("abegorov/app42:$VERSION")
                        docker.withRegistry('', 'dockerhub_credentials') {
                            image.push()
                        }
                    }
                }
            }
        }
    }
}
