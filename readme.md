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
I've set it up so you can access the app via a clean URL instead
of an IP address.

A) Hosts file (Windows):
   Open C:\Windows\System32\drivers\etc\hosts as Admin.
   Add this line:
   127.0.0.1 petclinic.moetez.local

B) Start the Tunnel:
   Run in PowerShell:
   minikube tunnel

C) Open your browser:
   Link: https://petclinic.moetez.local


8. COMPLIANCE & REQS MET
----------------------------------------------------------------
[X] IaC Approach        (Helm Charts - Blue/Green deployments)
[X] Automated CI        (Jenkins pollSCM every minute)
[X] HA Scaling          (Replicas = 2 for Blue and Green)
[X] Zero Downtime       (Blue-Green deployment strategy)
[X] Security            (SonarQube SAST + OWASP ZAP DAST)
[X] Monitoring          (Prometheus + Grafana self-hosted)
[X] Automated Rollbacks (On failure: traffic switches back to Blue)
[X] Manual Approval     (Production deployment requires human approval)


9. HTTPS Configuration (TLS)
================================================================

A) Generate Self-Signed Certificate with SAN
   Run in WSL:
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout /mnt/c/Users/moetez/petclinic.key \
     -out /mnt/c/Users/moetez/petclinic.crt \
     -subj "/CN=petclinic.moetez.local/O=petclinic" \
     -addext "subjectAltName=DNS:petclinic.moetez.local"

B) Create Kubernetes TLS Secret
   Run in PowerShell:
   kubectl create secret tls petclinic-tls \
     --cert=C:\Users\moetez\petclinic.crt \
     --key=C:\Users\moetez\petclinic.key \
     -n default

C) Trust Certificate in Chrome (Windows)
   - Open chrome://settings/security
   - Gérer les certificats
   - Autorités de certification racines de confiance
   - Importer → petclinic.crt
   - Redémarrer Chrome


10. Ingress Configuration (NGINX)
================================================================
Ingress acts as a reverse proxy that:
  - Listens on port 443 (HTTPS)
  - Terminates SSL using petclinic-tls secret
  - Routes traffic by hostname to petclinic-release service
  - Redirects HTTP to HTTPS automatically

File: ingress.yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: petclinic-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
    - hosts:
        - petclinic.moetez.local
      secretName: petclinic-tls
  rules:
    - host: petclinic.moetez.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: petclinic-release
                port:
                  number: 80

Apply: kubectl apply -f ingress.yaml


11. CI/CD Pipeline
================================================================
Trigger:  pollSCM every minute (auto on commit)
Stages:
  Checkout → Build → Tests → SonarQube
  → Docker Build → Load into Minikube
  → Deploy BLUE (service disabled)
  → Deploy GREEN (service enabled, selector=green)
  → Switch Traffic to GREEN
  → OWASP ZAP Scan
  → ZAP Score → Publish Report
  → Manual Approval → (Approved: done / Rejected: rollback to BLUE)


12. Application Access
================================================================
  minikube tunnel must be running in PowerShell.

  URL: https://petclinic.moetez.local
