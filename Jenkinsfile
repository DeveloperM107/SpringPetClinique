pipeline {
    agent any

    tools {
        maven 'M3'
    }

    environment {
        LOG_FILE = "pipeline-report.txt"
        SONAR_PROJECT_KEY = "SonarTestProject"
        SONAR_HOST_URL = "http://host.docker.internal:9003"
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master',
                credentialsId: 'GITHUB_TOKEN',
                url: 'https://github.com/sghaiershaima/SpringPetClinique.git'
            }
        }

        stage('Build') {
            steps {
                bat 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                bat 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                bat """
                mvn sonar:sonar ^
                -Dsonar.projectKey=%SONAR_PROJECT_KEY% ^
                -Dsonar.host.url=%SONAR_HOST_URL% ^
                -Dsonar.login=%SONAR_TOKEN%
                """
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                    dependencyCheck additionalArguments: """
                        --scan target/ 
                        --format HTML 
                        --out target 
                        --nvdApiKey ${NVD_API_KEY}
                    """, odcInstallation: 'owasp'
                }
            }
        }

        stage('Package') {
            steps {
                bat 'mvn package -DskipTests'
            }
        }

        // 🔥 DOCKER BUILD AUTOMATIQUE
        stage('Docker Build') {
            steps {
                bat 'docker build -t petclinic:v1 .'
                bat 'minikube image load petclinic:v1'
            }
        }

        // ☸️ HELM DEPLOY
        stage('Deploy Helm') {
            steps {
                bat 'helm upgrade --install petclinic-release ./helm/petclinic'
            }
        }

        // 🔵🟢 BLUE GREEN SWITCH
        stage('Blue-Green Switch') {
            steps {
                bat '''
                kubectl patch svc petclinic-release -p "{\\"spec\\":{\\"selector\\":{\\"app\\":\\"petclinic\\",\\"version\\":\\"blue\\"}}}"
                '''
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ Build réussi - Petclinic DevOps",
                body: "Pipeline Jenkins terminé avec succès.",
                to: 'sghaiershaima4@gmail.com',
                attachLog: true
            )
        }

        failure {
            emailext(
                subject: "❌ Build échoué - Petclinic DevOps",
                body: "Pipeline Jenkins a échoué.",
                to: 'sghaiershaima4@gmail.com',
                attachLog: true
            )
        }
    }
}
