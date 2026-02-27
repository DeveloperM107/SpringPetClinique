_________________________________________________________________________________________________________________________________
================================================================                
          DEVSECOPS PLATFORM – SPRING PETCLINIC 
================================================================

1. PROJECT OVERVIEW
----------------------------------------------------------------
This project is a full-scale implementation of a DevSecOps 
pipeline for the Spring PetClinic application. My goal was to 
move beyond simple automation and build a "Security-by-Design" 
ecosystem. 

The platform handles the entire lifecycle—from the moment code 
is pushed to GitHub, through security gates and automated 
testing, ending with a high-availability deployment on 
Kubernetes. 

Key Highlights:
- Fully automated CI/CD via Jenkins.
- Security baked in (SAST with SonarQube, DAST with OWASP ZAP).
- Zero-downtime updates using a Blue-Green strategy.
- Full observability with a Prometheus/Grafana stack.


2. THE ARCHITECTURE (Infrastructure-as-Code)
----------------------------------------------------------------
I built this platform to be 100% reproducible. Everything is 
defined as code, so you can spin up the entire environment 
without manual clicking.

- Tooling Layer: Jenkins and SonarQube run in Docker containers 
  via Docker Compose. This keeps the setup portable.
- Cluster Layer: The application lives in a Kubernetes cluster 
  (Minikube). I used Helm to package the app, making it easy 
  to manage different deployment versions (Blue vs. Green).


3. THE PIPELINE WORKFLOW
----------------------------------------------------------------
The Jenkinsfile is the brain of the project. It supports 
different modes (CI_CD, CI_ONLY, CD_ONLY) depending on 
the developer's needs.

Continuous Integration (The "Shield"):
- It starts with a Maven build and unit tests.
- Then, SonarQube scans the code for security holes and bugs.
- Finally, it builds a Docker image and pushes it directly 
  into the Minikube environment.

Continuous Deployment (The "Delivery"):
- The pipeline checks if the Kubernetes namespace exists.
- It deploys both the Blue and Green versions simultaneously.
- Before switching traffic, it waits for the pods to be "Ready."
- If everything looks good, it patches the K8s service to 
  point to the new version.


4. ZERO-DOWNTIME & SAFETY
----------------------------------------------------------------
I chose a Blue-Green deployment strategy to ensure the app 
never goes offline during an update. 
- Reliability: We run at least 2 replicas for each version.
- Instant Switch: Traffic is rerouted instantly via a 
  Service Selector change.
- Rollback: If the "Green" version fails its health checks, 
  the pipeline automatically keeps the "Blue" version live 
  and stops the deployment.


5. SECURITY & MONITORING
----------------------------------------------------------------
- Security: We don't just scan the code (SAST); we also scan 
  the running app using OWASP ZAP (DAST). The reports are 
  saved as artifacts in the Jenkins build history.
- Monitoring: I integrated Prometheus to scrape metrics and 
  Grafana to visualize them. This gives us a real-time view 
  of CPU, memory, and pod health.


6. HOW TO RUN THIS LOCALLY
----------------------------------------------------------------
1. Clone the repo:
   git clone https://github.com/DeveloperM107/SpringPetClinique.git

2. Start the DevOps tools:
   docker compose up -d --build

3. Fire up the cluster:
   minikube start

4. Trigger: Push a change to GitHub or run the job in Jenkins.


7. APPLICATION ACCESS (Local FQDN Setup)
----------------------------------------------------------------
I've set it up so you can access the app via a clean URL 
instead of an IP address.

A) Update your Hosts file (Windows):
   Open C:\Windows\System32\drivers\etc\hosts as Admin.
   Add this line: 127.0.0.1   petclinic.moetez.local

B) Start the Tunnel:
   Run: kubectl port-forward svc/petclinic-release 8083:80

C) Open your browser:
   Link: http://petclinic.moetez.local:8083


8. COMPLIANCE & REQS MET
----------------------------------------------------------------
[X] IaC Approach (No manual setup)
[X] Automated CI (Webhooks)
[X] HA Scaling (Replicas >= 2)
[X] Zero Downtime (Blue-Green)
[X] Security (SAST + DAST)
[X] Monitoring (Self-hosted stack)
[X] Automated Rollbacks

9. HTTPS Configuration (TLS)
================================================================

1. Generate Keystore
Run in project root:

Bash
keytool -genkeypair -alias petclinic -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore.p12 -validity 365 -storepass password -dname "CN=petclinic.moetez.local, OU=DevSecOps, O=DevSecOps, L=Berlin, S=Berlin, C=DE"
Move keystore.p12 to: src/main/resources/

2. Spring Boot Configuration
File: src/main/resources/application.properties

Properties
server.port=8443
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=password
server.ssl.key-store-type=PKCS12
server.ssl.key-alias=petclinic
3. CI CD Pipeline

Build: JAR and Docker image

Deployment: Helm Blue/Green

Traffic: Switch to Green deployment

4. Application Access
Local port forwarding:

Bash
kubectl port-forward svc/petclinic-release 8443:80
URL: https://petclinic.moetez.local:8443
