pipeline {
    agent {
        node {
            label 'docker-agent'
        }
    }
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.${BUILD_NUMBER}', description: 'Docker image version')
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
            steps {
                dir('app42') {
                    environment {
                        DB_PASSWORD = credentials('db_password')
                    }
                    script {
                        writeFile(
                            file: 'app42/db_password',
                            text: "${DB_PASSWORD}"
                        )
                        def image = docker.build(
                            "abegorov/app42:$VERSION",
                            "--build-arg=\"DB_HOST=${DB_HOST}\" " +
                            "--build-arg=\"DB_NAME=${DB_NAME}\" " +
                            "--build-arg=\"DB_USER=${DB_USER}\" "
                        )
                        docker.withRegistry('', 'dockerhub_credentials') {
                            image.push()
                        }
                    }
                }
            }
        }
    }
}
