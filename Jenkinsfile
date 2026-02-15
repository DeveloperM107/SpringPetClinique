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
                url: 'https://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@github.com/sghaiershaima/SpringPetClinique.git'
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
                sh '''
                echo "Building Docker Image..."
                docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        // ✅ CORRECTION ICI
        stage('Load Image into Minikube') {
            steps {
                sh '''
                echo "Loading image into Minikube..."
                minikube image load ${IMAGE_NAME}
                '''
            }
        }
        stage('Fix Minikube Context') {
            steps {
                sh '''
                echo "Fixing Minikube context..."
                minikube update-context
                '''
            }
        }
        stage('DEBUG KUBECONFIG') {
    steps {
        sh '''
        echo "Listing kube folder"
        ls -la /root/.kube || true
        ls -la /var/jenkins_home/.kube || true
        '''
    }
}

stage('Test Kubernetes') {
    steps {
        sh '''
        echo "Checking Kubernetes cluster..."

        export KUBECONFIG=/root/.kube/config

        kubectl get nodes
        '''
    }
}




        stage('Deploy Kubernetes') {
            steps {
                sh '''
                echo "Applying Kubernetes manifests..."
                minikube kubectl -- apply -f k8s/deployment.yaml
                minikube kubectl -- apply -f k8s/service.yaml
                '''
            }
        }

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
