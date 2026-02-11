pipeline{
    agent{
        label ''
    }
    tools{
        maven 'M3'
    }
      environment {
        LOG_FILE = "pipeline-report.txt"
        SONAR_PROJECT_KEY = "SonarTestProject"
        SONAR_HOST_URL = "http://localhost:9002/"
    }
    stages{
        stage('Checkout'){
            steps{
                git branch: 'master', url: 'https://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@github.com/sghaiershaima/SpringPetClinique.git'
            }
        }
        stage('Build'){
            steps{
                bat 'mvn compile'
            }
        }
        stage('Test'){
            steps{
                bat 'mvn test'
            }
        }
              stage('SonarQube Analysis') {
            steps {
                echo "Lancement de l'analyse SonarQube..."
                bat """
                    mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=squ_11fa45440ad1afe61606a1c1a6eac09d139ac8a4 >> %LOG_FILE% 2>&1
                    if ERRORLEVEL 1 (
                        echo [✖] Erreur lors de l'analyse SonarQube >> %LOG_FILE%
                        exit /b 1
                    ) else (
                        echo [✔] Analyse SonarQube terminée >> %LOG_FILE%
                    )
                """
            }
        }
          stage('OWASP Dependency Check') {
    steps {
        echo "Démarrage de OWASP Dependency Check..."
        dependencyCheck additionalArguments: '--scan target/ --format HTML --out target', odcInstallation: 'owasp'
        echo "Rapport OWASP généré."
        bat 'dir target /s'
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
        echo "Rapport HTML OWASP publié."
    }
}
        stage('Package'){
            steps{
                bat 'mvn package'
            }
        }
         post {
        success {
            emailext(
                subject: "✅ Build réussi - Microservices",
                body: """\
Bonjour,

Le pipeline Jenkins s’est terminé avec succès.

Vous trouverez en pièce jointe :
- Le rapport complet du pipeline (pipeline-report.txt)
- Le rapport OWASP (dependency-check-report.html)

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

Merci de consulter le fichier pipeline-report.txt ci-joint pour les détails.

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
        stage('Deploy'){
            steps{
                bat 'java -jar target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar'
         
            }
        }
    }
}
