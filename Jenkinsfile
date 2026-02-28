pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30'))
    timeout(time: 45, unit: 'MINUTES')
  }

  tools { maven 'M3' }

  triggers {
    pollSCM('* * * * *')
  }

  parameters {
    choice(name: 'PIPELINE_MODE', choices: ['CI_CD', 'CI_ONLY', 'CD_ONLY'], description: 'Run CI only, CD only, or CI+CD')
    booleanParam(name: 'GENERATE_REPORT', defaultValue: true, description: 'Publish ZAP HTML report')
    booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: true, description: 'Switch service to GREEN after deployment')
  }

  environment {
    IMAGE_REPO        = "petclinic"
    IMAGE_TAG         = "v1"
    IMAGE_NAME        = "${IMAGE_REPO}:${IMAGE_TAG}"

    SONAR_PROJECT_KEY = "petCliniqueProj"
    SONAR_HOST_URL    = "http://host.docker.internal:9003"
    SONAR_TOKEN       = credentials('SONAR_TOKEN')

    KUBECONFIG        = "/var/jenkins_home/.kube/config"
    RELEASE_BLUE      = "petclinic-blue"
    RELEASE_GREEN     = "petclinic-green"
    SERVICE_NAME      = "petclinic-release"
    NAMESPACE_APP     = "default"
    DOCKER_NET        = "infra_devops-net"
    APP_PORT          = "8085"
    JENKINS_IP        = "172.18.0.4"
  }

  stages {

    stage('Checkout') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        withCredentials([string(credentialsId: 'GITHUB_CRED', variable: 'GIT_TOKEN')]) {
          checkout([$class: 'GitSCM',
            branches: [[name: '*/main']],
            userRemoteConfigs: [[
              url: "https://${GIT_TOKEN}@github.com/DeveloperM107/SpringPetClinique.git"
            ]]
          ])
        }
      }
    }

    stage('Build') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh 'mvn -B clean package -DskipTests'
      }
    }

    stage('Tests') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh 'mvn -B test'
      }
    }

    stage('SonarQube Analysis') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh """
          mvn -B sonar:sonar \
            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
            -Dsonar.host.url=${SONAR_HOST_URL} \
            -Dsonar.login=${SONAR_TOKEN}
        """
      }
    }

    stage('Docker Build Image') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh """
          docker build -t ${IMAGE_NAME} .
          docker images | grep ${IMAGE_REPO} || true
        """
      }
    }

    stage('Load Image into Minikube') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh "minikube image load ${IMAGE_NAME}"
      }
    }

    stage('Prepare Kubeconfig') {
      when { expression { params.PIPELINE_MODE != 'CI_ONLY' } }
      steps {
        sh '''
          mkdir -p /var/jenkins_home/.kube

          if [ ! -f /root/.kube/config ]; then
            echo "❌ /root/.kube/config not found."
            exit 1
          fi

          cp /root/.kube/config /var/jenkins_home/.kube/config
          sed -i 's#C:\\Users\\moetez\\.minikube#/root/.minikube#g' /var/jenkins_home/.kube/config

          PORT=$(docker port minikube 8443 | cut -d: -f2)

          kubectl config set-cluster minikube \
            --server=https://host.docker.internal:$PORT \
            --insecure-skip-tls-verify=true

          kubectl config set-credentials minikube \
            --client-certificate=/root/.minikube/profiles/minikube/client.crt \
            --client-key=/root/.minikube/profiles/minikube/client.key

          kubectl config use-context minikube
          kubectl get nodes
        '''
      }
    }

    stage('Ensure Namespace') {
      when { expression { params.PIPELINE_MODE != 'CI_ONLY' } }
      steps {
        sh '''
          kubectl get ns ${NAMESPACE_APP} >/dev/null 2>&1 || kubectl create ns ${NAMESPACE_APP}
        '''
      }
    }

    stage('Deploy BLUE (Helm)') {
      when { expression { params.PIPELINE_MODE != 'CI_ONLY' } }
      steps {
        sh '''
          helm upgrade --install ${RELEASE_BLUE} ./helm/petclinic \
            --namespace ${NAMESPACE_APP} \
            --set versionLabel=blue \
            --set image.repository=${IMAGE_REPO} \
            --set image.tag=${IMAGE_TAG} \
            --set service.enabled=false \
            --set ingress.enabled=false

          kubectl -n ${NAMESPACE_APP} rollout status deploy \
            -l app=petclinic,version=blue --timeout=180s
        '''
      }
    }

    stage('Deploy GREEN (Helm)') {
      when { expression { params.PIPELINE_MODE != 'CI_ONLY' } }
      steps {
        sh '''
          helm upgrade --install ${RELEASE_GREEN} ./helm/petclinic \
            --namespace ${NAMESPACE_APP} \
            --set versionLabel=green \
            --set image.repository=${IMAGE_REPO} \
            --set image.tag=${IMAGE_TAG} \
            --set service.enabled=true \
            --set-string rolloutTimestamp=$(date +%s) \
            --set ingress.enabled=false

          kubectl -n ${NAMESPACE_APP} rollout status deploy \
            -l app=petclinic,version=green --timeout=180s

          kubectl -n ${NAMESPACE_APP} wait --for=condition=ready pod \
            -l app=petclinic,version=green --timeout=300s
        '''
      }
    }

    stage('Switch Traffic to GREEN') {
      when { expression { params.PIPELINE_MODE != 'CI_ONLY' && params.SWITCH_TRAFFIC } }
      steps {
        sh '''
          echo "Verifying service selector..."
          kubectl -n ${NAMESPACE_APP} get svc ${SERVICE_NAME} -o jsonpath='{.spec.selector}'
          echo ""

          echo "Waiting for endpoints to be ready..."
          sleep 10
          kubectl -n ${NAMESPACE_APP} get endpoints ${SERVICE_NAME} -o wide
        '''
      }
    }

    stage('OWASP ZAP Scan') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh '''
          echo "Testing app reachability..."
          curl -s http://host.docker.internal:80 > /dev/null \
            && echo "✅ App reachable" \
            || echo "❌ App not reachable — make sure minikube tunnel is running on Windows host"

          docker run --rm \
            -u root \
            -v "$PWD:/zap/wrk" \
            --network ${DOCKER_NET} \
            ghcr.io/zaproxy/zaproxy:stable \
            zap-baseline.py \
              -t "http://host.docker.internal:80" \
              -r zap-report.html \
              -J zap-report.json \
              -I \
              --autooff
        '''
      }
    }

    stage('ZAP Security Score') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' } }
      steps {
        sh '''
          HIGH=$(grep -o '"risk":"High"'   zap-report.json | wc -l || echo 0)
          MED=$(grep  -o '"risk":"Medium"' zap-report.json | wc -l || echo 0)
          LOW=$(grep  -o '"risk":"Low"'    zap-report.json | wc -l || echo 0)

          echo "HIGH=$HIGH"   > zap-score.env
          echo "MEDIUM=$MED" >> zap-score.env
          echo "LOW=$LOW"    >> zap-score.env

          echo "ZAP => High:$HIGH | Medium:$MED | Low:$LOW"
        '''
      }
    }

    stage('Publish ZAP Report') {
      when { expression { params.PIPELINE_MODE != 'CD_ONLY' && params.GENERATE_REPORT } }
      steps {
        publishHTML(target: [
          allowMissing: true,
          alwaysLinkToLastBuild: true,
          keepAll: true,
          reportDir: '.',
          reportFiles: 'zap-report.html',
          reportName: 'OWASP ZAP Report'
        ])
      }
    }

    stage('Manual Approval') {
      when { expression { params.PIPELINE_MODE != 'CI_ONLY' } }
      steps {
        timeout(time: 30, unit: 'MINUTES') {
          input message: '🚀 Deploy to Production? Make sure minikube tunnel is running!
