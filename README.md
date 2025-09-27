# Islamic App - Complete CI/CD Pipeline

## Overview

This repository implements a comprehensive end-to-end CI/CD pipeline for the Islamic App, combining modern DevOps practices with cloud-native technologies. The pipeline automates the entire software delivery lifecycle from code commit to production deployment using GitHub Actions, Terraform, Kubernetes, and ArgoCD.

## 🏗️ Complete Architecture Overview

<!-- TODO: Add Complete CI/CD Architecture Diagram -->
![Complete CI/CD Architecture](./images/full%20architecture.png)

```mermaid
graph TB
    subgraph "Development"
        DEV[Developer]
        GIT[Git Repository]
        DEV --> GIT
    end
    
    subgraph "CI Pipeline (GitHub Actions)"
        TEST[Run Tests]
        BUILD[Docker Build]
        SCAN[Trivy Security Scan]
        PUSH[Docker Push to ECR]
        UPDATE[Update K8s Manifests]
        
        GIT --> TEST
        TEST --> BUILD
        BUILD --> SCAN
        SCAN --> PUSH
        PUSH --> UPDATE
    end
    
    subgraph "CD Infrastructure (Terraform)"
        VPC[VPC & Networking]
        EKS[EKS Cluster]
        R53[Route 53]
        ACM[Certificate Manager]
        PS[Parameter Store]
        
        VPC --> EKS
        EKS --> R53
        R53 --> ACM
        EKS --> PS
    end
    
    subgraph "GitOps Deployment (ArgoCD)"
        ARGO[ArgoCD Controller]
        EBS[EBS CSI Driver]
        LBC[Load Balancer Controller]
        EDNS[External DNS]
        ESO[External Secrets]
        APP[Islamic App]
        
        UPDATE --> ARGO
        ARGO --> EBS
        ARGO --> LBC
        ARGO --> EDNS
        ARGO --> ESO
        ARGO --> APP
    end
    
    subgraph "Production"
        USERS[End Users]
        DOMAIN[shebl22.me]
        
        APP --> DOMAIN
        DOMAIN --> USERS
    end
```

## 🚀 Pipeline Components

### 1. **Continuous Integration (CI)**
- **Source**: GitHub Repository
- **Trigger**: Code push/pull request
- **Tools**: GitHub Actions, Docker, Trivy
- **Output**: Tested and scanned container images


### 2. **Infrastructure as Code (IaC)**
- **Source**: Terraform configurations
- **Management**: Remote state in S3 with DynamoDB locking
- **Resources**: Complete EKS infrastructure on AWS
- **Output**: Production-ready Kubernetes cluster


### 3. **Continuous Deployment (CD)**
- **Source**: GitOps with ArgoCD
- **Trigger**: Kubernetes manifest changes
- **Tools**: ArgoCD, Helm, External Secrets
- **Output**: Deployed and running applications

## 🔄 End-to-End Workflow

### Phase 1: Code Development & Integration

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as GitHub
    participant CI as GitHub Actions
    participant ECR as Container Registry
    
    Dev->>Git: Push Code
    Git->>CI: Trigger Pipeline
    CI->>CI: Run Tests
    CI->>CI: Build Images
    CI->>CI: Security Scan
    CI->>ECR: Push Images
    CI->>Git: Update Manifests
```

#### **1. Code Commit**
- Developer pushes code to GitHub repository
- Automated triggers activate CI pipeline
- Branch protection rules enforce code review

#### **2. Automated Testing**
- Unit tests for frontend and backend
- Integration tests for API endpoints
- Code quality and security analysis

#### **3. Container Build & Scan**
- Multi-stage Docker builds for optimization
- Trivy vulnerability scanning
- Image signing and verification

#### **4. Registry Push**
- Secure push to Amazon ECR
- Image tagging with commit SHA
- Automated cleanup of old images

#### **5. Manifest Updates**
- Automatic update of Kubernetes manifests
- GitOps commit with new image tags
- Version tracking and rollback capability

### Phase 2: Infrastructure Provisioning

```mermaid
sequenceDiagram
    participant TF as Terraform
    participant AWS as AWS Services
    participant S3 as State Storage
    participant DDB as DynamoDB
    
    TF->>S3: Read State
    TF->>DDB: Acquire Lock
    TF->>AWS: Provision Infrastructure
    TF->>S3: Update State
    TF->>DDB: Release Lock
```


#### **1. State Management**
- Remote state stored in S3 bucket
- State locking with DynamoDB
- Cross-region state replication

#### **2. Network Infrastructure**
- Custom VPC with public/private subnets
- NAT Gateway for secure outbound access
- Security groups and NACLs

#### **3. EKS Cluster**
- Custom EKS cluster (not using modules)
- Worker node groups with auto-scaling
- OIDC provider for IRSA integration

#### **4. Supporting Services**
- Route 53 hosted zone management
- SSL certificates via Certificate Manager
- Parameter Store for secrets management

### Phase 3: Application Deployment

```mermaid
sequenceDiagram
    participant Argo as ArgoCD
    participant Git as Git Repository
    participant K8s as Kubernetes
    participant AWS as AWS Services
    
    Argo->>Git: Monitor Changes
    Git-->>Argo: Manifest Updates
    Argo->>K8s: Deploy Infrastructure Components
    Argo->>AWS: Configure IRSA Roles
    Argo->>K8s: Deploy Application
    K8s->>AWS: Provision Load Balancers
```

---

*For detailed information about specific components, please refer to the individual README files for CI and CD pipelines.*