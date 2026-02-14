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
                url: 'https://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@github.com/sghaiershaima/SpringPetClinique.git'
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
                '''
            }
        }

        // ==========================
        // LOAD IMAGE INTO MINIKUBE
        // ==========================
        stage('Load Image') {
            steps {
                sh '''
                echo "Loading image into Minikube Docker..."
                docker save ${IMAGE_NAME} | (eval $(minikube docker-env) && docker load)
                '''
            }
        }

        // ==========================
        // TEST CLUSTER
        // ==========================
        stage('Test Kubernetes') {
            steps {
                sh '''
                echo "Checking Kubernetes cluster..."
                kubectl get nodes
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
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
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
