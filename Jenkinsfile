pipeline {
    agent any

    tools {
        maven 'M3'
    }
environment {
    LOG_FILE = "pipeline-report.txt"

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
                sh 'mvn compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        

       stage('OWASP Dependency Check') {
    steps {
        withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
            dependencyCheck additionalArguments: """
                --scan target/ \
                --format HTML \
                --out target \
                --nvdApiKey ${NVD_API_KEY}
            """, odcInstallation: 'owasp'
        }
        sh 'ls -R target'
    }
}

        stage('Publish OWASP Report') {
            steps {
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'target',
                    reportFiles: 'dependency-check-report.html',
                    reportName: 'OWASP Dependency Check Report'
                ])
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Deploy') {
            steps {
                sh 'java -jar target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar'
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ Build réussi - Microservices",
                body: """\
Bonjour,

Le pipeline Jenkins s’est terminé avec succès.

Cordialement,
Le serveur CI/CD
""",
                to: 'sghaiershaima4@gmail.com',
                attachmentsPattern: "${env.LOG_FILE}, target/dependency-check-report.html",
                attachLog: true
            )
        }

        failure {
            emailext(
                subject: "❌ Build échoué - Microservices",
                body: """\
Bonjour,

Le pipeline Jenkins a échoué.

Merci de consulter le rapport joint.

Cordialement,
Le serveur CI/CD
""",
                to: 'sghaiershaima4@gmail.com',
                attachmentsPattern: "${env.LOG_FILE}, target/dependency-check-report.html",
                attachLog: true
            )
        }

        always {
            archiveArtifacts artifacts: "${env.LOG_FILE}, target/dependency-check-report.html", allowEmptyArchive: true
        }
    }
}
