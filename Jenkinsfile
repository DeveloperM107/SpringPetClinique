pipeline{
    agent{
        label ''
    }
    tools{
        maven 'M3'
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
        stage('Package'){
            steps{
                bat 'mvn package'
            }
        }
        stage('Deploy'){
            steps{
                bat 'java -jar target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar'
         
            }
        }
    }
}
