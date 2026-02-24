# Deployment Strategy for the “Pregnant Pills” Web Application on Kubernetes (AWS)

**Author:** Paulina Kimak  
**Mentor:** Adam Stenka  

---

## 1. Environment Strategy (dev / test / prod)

The application is deployed on an AWS EC2 instance running a k3s Kubernetes cluster.  
Three separate environments are defined, each serving a different purpose and using distinct configurations.

---

## 2. Test Environment – `test`

**Purpose:** Functional and integration testing in a Kubernetes-based setup closely resembling production.

### Configuration

- **Database:** PostgreSQL deployed as a Kubernetes Deployment inside the cluster  
- **Log level:** `debug`  
- **Application replicas:** 1  
- **Database replicas:** 1  
- **Ingress Controller:** Traefik  
- **Service exposure:** Ingress (HTTP routing)  
- **Elastic IP:** Configured and associated with the EC2 instance  
- **DNS:** Domain connected via AWS Route 53  

In this environment:

- An **Elastic IP** is provisioned using Terraform.
- The Elastic IP is associated with the EC2 instance.
- A **Route 53 A record** is created to map the domain to the Elastic IP.
- The application is accessible via a public domain.

This setup allows realistic end-to-end testing of networking, DNS resolution, and ingress routing while maintaining controlled resource usage.

### Traditional VM-based Kubernetes diagram 
- **EC2 (spot) + k3s + Kustomize** – main branch  
![Test env](img/test_arch.jpg)

---

## 3. Development Environment – `dev`

**Purpose:** Feature development and rapid testing with simplified infrastructure.

### Configuration

- **Database:** SQLite  
- **Log level:** `info`  
- **Application replicas:** 1  
- **Service exposure:** NodePort  

In this environment:

- The application is exposed via a **NodePort service**.
- Access is restricted using Security Groups (only developer IP).
- No domain or load balancer is configured.

This setup prioritizes simplicity and fast iteration during development.

---

## 4. Production Environment – `prod`

**Purpose:** Public-facing, highly available deployment.

### Configuration

- **Database:** PostgreSQL (production-grade configuration)  
- **Log level:** `warning`  
- **Application replicas:** Minimum 2, scalable up to 5  
- **Database replicas:** 2  
- **Service exposure:** AWS LoadBalancer  
- **Ingress type:** LoadBalancer (AWS)  

This environment is designed for:

- High availability  
- Horizontal scalability  
- Stable external access  

The application is exposed through an AWS LoadBalancer, enabling scalable and reliable traffic distribution.

---

## 5. Architecture Overview

All environments are deployed using:

- **AWS EC2**
- **k3s Kubernetes cluster**
- **Terraform** for infrastructure provisioning
- **Kustomize overlays** for environment-specific configuration

### Environment separation is achieved through:

- Kubernetes namespaces  
- Kustomize overlays  
- Separate ConfigMaps and Secrets per environment  

---


---

## 7. Infrastructure as Code

Infrastructure components are provisioned using Terraform:

- VPC
- Subnet
- Internet Gateway
- Route Tables
- Security Groups
- EC2 Spot Instance
- Elastic IP
- Route 53 DNS Records

Kubernetes manifests are deployed using:

- `kubectl apply -k`
- Environment-specific Kustomize overlays

---

