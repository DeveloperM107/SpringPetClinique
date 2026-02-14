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

        // ==========================
        // CHECKOUT
        // ==========================
        stage('Checkout') {
            steps {
                git branch: 'master',
                url: 'https://github.com/sghaiershaima/SpringPetClinique.git'
            }
        }

        // ==========================
        // BUILD
        // ==========================
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        // ==========================
        // TESTS
        // ==========================
        stage('Tests') {
            steps {
                sh 'mvn test'
            }
        }

        // ==========================
        // DOCKER BUILD
        // ==========================
        stage('Docker Build') {
            steps {
                sh '''
                echo "Building Docker Image..."
                docker build -t ${IMAGE_NAME} .
                echo "Loading image into Minikube..."
                minikube image load ${IMAGE_NAME}
                '''
            }
        }

        // ==========================
        // TEST CLUSTER (🔥 IMPORTANT)
        // ==========================
        stage('Test Kubernetes') {
            steps {
                sh '''
                echo "Checking Kubernetes cluster..."
                minikube kubectl -- get nodes
                '''
            }
        }

        // ==========================
        // DEPLOY K8S
        // ==========================
        stage('Deploy Kubernetes') {
            steps {
                sh '''
                echo "Applying Kubernetes manifests..."
                minikube kubectl -- apply -f k8s/deployment.yaml
                minikube kubectl -- apply -f k8s/service.yaml
                '''
            }
        }

        // ==========================
        // HELM DEPLOY
        // ==========================
        stage('Helm Deploy') {
            steps {
                sh '''
                echo "Deploying with Helm..."
                helm upgrade --install ${RELEASE_NAME} ./helm/petclinic
                '''
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
