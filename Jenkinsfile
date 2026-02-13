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
                url: 'https://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@github.com/sghaiershaima/SpringPetClinique.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh """
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
                sh 'mvn package -DskipTests'
            }
        }

        // 🔥 DOCKER BUILD AUTOMATIQUE
        stage('Docker Build') {
            steps {
                sh 'docker build -t petclinic:v1 .'
                sh 'minikube image load petclinic:v1'
            }
        }

        // ☸️ HELM DEPLOY
        stage('Deploy Helm') {
            steps {
                sh 'helm upgrade --install petclinic-release ./helm/petclinic'
            }
        }

        // 🔵🟢 BLUE GREEN SWITCH
        stage('Blue-Green Switch') {
            steps {
                sh '''
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
