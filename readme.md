```markdown
# 🚀 Enterprise DevSecOps Platform — Spring PetClinic

## 🧭 Overview

This project is a **full Enterprise DevSecOps Platform** built around the Spring PetClinic application.  
It goes far beyond a traditional CI/CD pipeline by integrating **Infrastructure as Code, Security Automation, Blue-Green Deployment, and Observability** into a single automated ecosystem.

The goal of this platform is to simulate a **real production-grade DevSecOps architecture** where application delivery is secure, automated, and continuously monitored.

Instead of focusing only on application deployment, this project demonstrates how modern organizations build **secure, scalable, and zero-downtime delivery pipelines**.

---

## 🏗️ Enterprise Architecture

```

GitHub Repository
↓
Jenkins CI/CD Pipeline
↓
Code Quality & Security (SonarQube + OWASP ZAP)
↓
Docker Image Build & Versioning
↓
Kubernetes Deployment (Helm)
↓
Blue-Green Traffic Switching
↓
Monitoring & Observability (Prometheus + Grafana)

```

This architecture reflects real-world DevSecOps workflows used in modern cloud-native environments.

---

## 💼 Key Value Proposition

✔ Enterprise-grade DevSecOps automation  
✔ Infrastructure fully described as code  
✔ Integrated security scanning pipeline  
✔ Zero-downtime Blue-Green deployment strategy  
✔ Real monitoring stack with alerts and metrics  
✔ Fully reproducible local DevOps environment

This project demonstrates not only technical implementation but also **DevOps architecture design thinking**.

---

## 🧱 Infrastructure as Code (IaC)

The entire platform is defined through code:

- Docker Compose for DevOps infrastructure
- Kubernetes manifests for application orchestration
- Helm charts for versioned deployments

Core services deployed automatically:

- Jenkins
- SonarQube
- PostgreSQL
- Kubernetes cluster (Minikube)

This ensures:

- Reproducibility
- Environment consistency
- Automated provisioning

---

## 🔁 Continuous Integration & Delivery (CI/CD)

The Jenkins pipeline automates the full software lifecycle:

### CI Phase
- Source code checkout from GitHub
- Maven build and tests
- Static code analysis with SonarQube
- Dependency vulnerability scanning

### CD Phase
- Docker image creation
- Deployment using Helm
- Canary validation
- Automated Blue-Green traffic switching
- Rollback-ready deployment strategy

---

## 🔐 DevSecOps Integration

Security is embedded directly into the delivery pipeline:

- Static Application Security Testing (SAST) via SonarQube
- Dynamic Application Security Testing (DAST) via OWASP ZAP
- Automated scan execution after deployment readiness
- Security validation before traffic switching

This transforms the pipeline into a true **DevSecOps workflow** rather than a simple CI/CD pipeline.

---

## 🔵 Blue-Green Deployment Strategy

Two application versions run simultaneously:

```

BLUE  → Stable production version
GREEN → Newly deployed version under validation

```

Traffic switching is performed at the Kubernetes Service level, enabling:

- Zero downtime releases
- Safe production updates
- Instant rollback capability

---

## 📊 Observability & Monitoring

The platform includes a full monitoring stack:

- Prometheus for metrics collection
- Grafana dashboards for visualization
- ServiceMonitor for automated scraping
- Alertmanager for operational alerts

Application health, Kubernetes metrics, and deployment status are continuously monitored.

---

## 📁 Project Structure

```

SpringPetClinique/
│
├── infra/                # DevOps infrastructure (Docker Compose)
├── k8s/                  # Kubernetes manifests
├── helm/petclinic/       # Helm chart for deployments
├── Jenkinsfile           # DevSecOps pipeline
└── README.md

```

---

## ⚙️ Core Technologies

- Java Spring Boot
- Jenkins Pipeline
- Docker
- Kubernetes (Minikube)
- Helm
- SonarQube
- OWASP ZAP
- Prometheus
- Grafana

---

## 🚀 Getting Started

### Start DevOps Infrastructure

```

cd infra
docker compose up -d --build

```

### Build Application

```

mvn clean package

```

### Build Docker Image

```

docker build -t petclinic:v1 .

```

### Deploy to Kubernetes

```

minikube image load petclinic:v1
kubectl apply -f k8s/

```

### Deploy with Helm

```

helm install petclinic-release ./helm/petclinic

```

---

## 🔄 Blue-Green Deployment Example

Deploy new GREEN version:

```

helm install petclinic-green ./helm/petclinic --set versionLabel=green

```

Switch traffic:

```

kubectl patch svc petclinic-release -p '{"spec":{"selector":{"app":"petclinic","version":"green"}}}'

```

---

## 🎯 DevOps Engineering Skills Demonstrated

- Infrastructure as Code Design
- CI/CD Pipeline Engineering
- Secure Software Delivery (DevSecOps)
- Kubernetes Deployment Strategies
- Helm-Based Release Management
- Observability Engineering
- Zero-Downtime Deployment Architecture

---

## 👨‍💻 Author

**Moetez Cherni**  
DevOps & Cloud Engineering — Berlin University of Applied Sciences (BHT)

---
```
