pipeline {

    agent any

    tools {
        maven 'M3'
    }

    environment {
        IMAGE_NAME = "petclinic:v1"
        RELEASE_NAME = "petclinic-release"
    }

    stages {

        stage('Checkout') {
    steps {
        git branch: 'master',
            credentialsId: 'github-cred',
            url: 'https://github.com/sghaiershaima/SpringPetClinique.git'
    }
}


        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('Deploy Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }

        stage('Helm Deploy') {
            steps {
                sh 'helm upgrade --install ${RELEASE_NAME} ./helm/petclinic'
            }
        }
    }

    post {
        success {
            echo "🚀 Full DevOps Pipeline Completed"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
