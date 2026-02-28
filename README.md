# Pregnant App – Modular Pregnancy Platform

Pregnant App is a modular, service-oriented pregnancy support platform.

The repository is structured as a monorepo containing multiple domain-specific services,
each developed as an independent Flask-based application with its own documentation,
configuration, and deployment strategy.

The system is designed to evolve toward distributed deployment in Kubernetes environments.

## Table of Contents

* [Overview](#overview)
* [Architecture Focus](#architecture-focus)
* [Technology Stack](#technology-stack)
* [Previews](#Previews)
* [Deployment Strategies](#deployment-Sstrategies)
* [Deployment Variants](#deployment_variants)
* [Setup](#setup)
* [Project Status](#project-status)
* [Future Improvements](#future-improvements)
* [Contact](#contact)
* [License](#license)

---

# Repository Structure
```
apps/
├── preg-health-service/
├── preg-nutri-service/
├── preg-baby-service/
├── preg-org-service/
└── preg-memo-service/
infra/
docs/
```
Each service contains:
- Application source code
- Internal README
- Configuration
- Tests
- Containerization files (if applicable)

---

# Services Overview

## Health Modules - Pregnant Pills App

Pregnant Pills is a web application designed to help pregnant women track 
and manage medications taken during pregnancy.

The system allows users to register, maintain a personalized list of pills, 
categorize them, specify pregnancy week, and generate a downloadable 
PDF report for medical consultations.

**Pregnant Pills Features:**
- Register and manage an account
- Track medications taken during pregnancy
- Categorize pills (routine / special)
- Store dosage, dates, and pregnancy week
- Generate a PDF report for medical visits

### Weight & Measurements  
Monitor pregnancy body changes.

**Size monitor Features:**
- Weight gain tracking
- Belly measurements
- Charts and trends

→ See module documentation:  
`/apps/preg-health-app/README.md`

### Nutrition Module - Pregnant Food App 
Monitor diet and ensure safe nutritional intake.

**Features:**
- Safe / unsafe foods database
- Calorie and nutrient calculator
- Vitamin reminders (folic acid, iron)

→ See module documentation:  
`/apps/preg-nutri-app/README.md`

## Baby Development Modules - Pregnant Baby App

### Fetal Movement Tracker  
Track baby activity and movement patterns.

**Features:**
- Kick counter
- Baby activity journal
- Alerts for decreased movement
- What's happening with mom and baby each week
- Baby size comparisons (fruits / objects)
- Developmental milestones

→ See module documentation:  
`/apps/preg-baby-app/README.md`

## Organizational Modules - Pregnant Org App

### Birth Preparation  
Plan for delivery and hospital stay.

**Features:**
- Hospital bag checklist
- Birth plan creator
- Important contacts (doctor, hospital, midwife)
- Baby room 


### Financial Planner  
Plan financial aspects of pregnancy and newborn care.

**Features:**
- Baby cost calculator
- Newborn shopping list
- Pregnancy expense tracker


→ See module documentation:  
`/apps/preg-org-app/README.md`

## Memory Keeper  - Pregnant Memo App
Capture pregnancy journey.

**Features:**
- Belly photo timeline (timelapse)
- Pregnancy journal
- Ultrasound photo storage

→ See module documentation:  
`/apps/preg-memo-app/README.md`

## Architecture Focus

This repository is not only about a Flask application — it demonstrates:

- Infrastructure as Code (Terraform)
- Kubernetes deployment patterns
- Environment separation (dev/test/prod)
- DNS + Elastic IP management (Route 53)
- Ingress configuration
- Multiple cluster strategies (k3s, EKS, future Fargate)

The goal of the project is to evolve from a simple web application into a production-oriented, cloud-deployable system.

## Technology Stack

### Application Layer
- Python 3.11
- Flask 2.2.2
- SQLAlchemy 1.4.45
- WTForms 3.0.1
- Bootstrap 5.2.3
- SQLite (dev environment)
- PostgreSQL (test/prod environments)

### Infrastructure & Cloud
- AWS (EC2, Route 53, Elastic IP)
- Kubernetes (k3s / EKS)
- Terraform
- Kustomize
- Helm (EKS branch)
- Traefik Ingress (k3s)
- AWS Load Balancer Controller (EKS)

## Previews

### Home Page

![Home Page Preview](pregnant_pills_app/static/files/img/previews/preview_pregnant_pills.jpg)

### Register user page
![Register user page](pregnant_pills_app/static/files/img/previews/preview_pregnant_pills_add_user.jpg)

### Admin page - all users

![Admin page - all users](pregnant_pills_app/static/files/img/previews/preview_pregnant_pills_users_list..jpg)


## Deployment Strategies

This project includes multiple infrastructure and deployment strategies:

### Traditional VM-based Kubernetes
- **EC2 (spot) + k3s + Kustomize** – main branch  
→[EC2 + k3s + Kustomize)](docs/deployment/1.ec2_kustomization/Deployment_Spot_EC2.md)

### Managed Kubernetes
- **EKS + Helm** – eks branch  
→ [EKS Deployment Guide](docs/deployment/2.eks_helm/Deployment_EKS_Helm.md)

### Serverless container workloads
- **(Planned) EKS + Fargate** – future extension  
→ [Serverless container workloads](docs/deployment/2.eks_helm/Deployment_Fargate.md)

Detailed documentation can be found in the `/docs/deployment` directory.

## Deployment Variants

This project demonstrates multiple Kubernetes deployment approaches:

| Variant | Infrastructure | Deployment Tool | Ingress | DNS | Scaling |
|----------|---------------|----------------|---------|------|---------|
| EC2 + k3s | Terraform | Kustomize | Traefik | Route53 | Manual / HPA |
| EKS | Terraform | Helm | ALB | Route53 | Managed Node Groups |
| Fargate (planned) | Terraform | Helm | ALB | Route53 | Serverless Pods |

## Project Status

Project is: _in progress_

The ecosystem is expanding toward:
- Modular service separation
- Improved security
- Production-grade Kubernetes infrastructure
- CI/CD automation

## Future Improvements


## Application
- Central authentication across modules
- API gateway layer
- Role-based access control
- Cross-module integration

### Infrastructure
- Horizontal Pod Autoscaler (HPA)
- Production-grade PostgreSQL (RDS)
- TLS automation (cert-manager)
- CI/CD pipeline (GitHub Actions)
- Monitoring & logging (Prometheus + Grafana)

## Contact

- Created by [@RockPiryt Github](https://github.com/RockPiryt)
- My Resume [@RockPiryt Resume](https://resume.paulinakimak.com)

Feel free to contact me!

## License

This project is open source and available under the [MIT License]
