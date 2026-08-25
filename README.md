# Smart-Uni Infrastructure (AWS + Terraform) 🏗️

This repository manages the cloud infrastructure and automated provisioning for the **Smart-Uni** university residence management system.

The core application code is maintained in a decoupled, source-only repository:
**[Smart-Uni Application Code](https://github.com/Mohamine2/Smart-Uni)**

---

## 🗺️ Architecture Overview

The infrastructure is built on AWS using Terraform to guarantee standard, repeatable, and secure environments.

Visual layout of the infrastructure components and network boundaries:

<img width="850" height="1100" alt="image" src="https://github.com/user-attachments/assets/17a9e002-e98c-47c9-b1cf-ab56a1b7aed9" />

### 🖧 Network

* **Virtual Private Cloud (VPC)**: Custom isolated network setup `10.0.0.0/16` to run computing resources.
* **Public Subnet**: A single public tier `10.0.1.0/24` with automatic public IP translation where the instance is deployed.
* Current topology is single-tier: no private subnet, NAT Gateway, or managed database (RDS) is provisioned. The application stack (Nginx, Django, MySQL) runs as three Docker containers on the same EC2 host. Database isolation is therefore enforced at the Docker network level (`smart_network`, internal bridge — MySQL is never exposed outside the host), not at the AWS network-tier level.
* A private-subnet, multi-tier layout (e.g. RDS in an isolated subnet) is a natural next step but is not implemented yet, see [Roadmap](#roadmap).
  
### 🛡️ Security

* **Security Groups**: ingress restricted to ports 80 (HTTP) and 443 (HTTPS), open to 0.0.0.0/0; egress unrestricted (required for Docker Hub pulls and package updates). **No SSH port (22) is ever opened.**
* ⚠️ Port 443 is currently open at the network level but not yet used: the Nginx configuration only listens on port 80, no TLS certificate is configured. This is a known gap, HTTPS is not yet actively configured.
* **AWS IAM + Systems Manager (SSM)**: Configured via IAM roles and policies `AmazonSSMManagedInstanceCore` to allow safe SSH-less access to the cloud environment without opening public management ports.

---

## 🔄 CI/CD & Deployment Strategy

### Automated Continuous Deployment (GitHub Actions & AWS SSM)
The workflow `.github/workflows/cd-deploy.yml` is triggered automatically via `repository_dispatch` from `smart-uni-api` on successful CI completion (or manually via `workflow_dispatch`):

- **Targeted AWS Authentication:** Authenticates securely via dedicated IAM credentials scoped to Amazon EC2 Systems Manager execution.
- **Agentless Execution (AWS SSM):** Transmits production configurations (`compose.prod.yaml`, Nginx reverse proxy configs, and environment variables) to the targeted EC2 instance without opening inbound SSH ports.
- **Zero-Downtime Container Lifecycle:** Pulls the newly verified Docker Hub image artifact and executes `docker compose up -d --force-recreate` to refresh production services.

### 🔒 Access Control & Cost Optimization
* **Restricted Deployment**: Due to access token restrictions and infrastructure security policies, **only the repository owner (myself) has the clearance to deploy and trigger updates** onto the environment.
* **Financial Constraints & Up-time**: To avoid unnecessary cloud billing and stay within financial boundaries, **the AWS EC2 instance is kept stopped/turned off by default**. It is spun up exclusively during active demonstration windows.

---

## 📁 Repository Structure

```text
smart-uni-infra/
├── .github/
│   └── workflows/
│       └── cd-deploy.yml          # CD Pipeline (AWS SSM)
│
├── docker/
│   ├── docker-compose.prod.yml    # (Nginx, DRF API, MySQL)
│   └── nginx/
│       └── default.conf           # Reverse proxy config & staticfiles
│
├── terraform/                     
│   ├── main.tf                    # Entry point establishing global resources & orchestrations
│   ├── network.tf                 # Provisions VPC, subnets, route tables, and gateways
│   ├── security.tf                # Configures AWS Security Groups and IAM permissions
│   ├── providers.tf               # Declares cloud providers (AWS) and required versions
│   ├── variables.tf               # Defines configurable environment arguments
│   └── outputs.tf                 # Declares values to expose after deployment
│
├── .terraform.lock.hcl            # Locks provider plugin versions
├── .gitignore
└── README.md
```

---

## 🚀 Getting Started

### 📋 Prerequisites

    1. Install Terraform (v1.0.0+ recommended).

    2. Configure your AWS CLI credentials locally.

---

## 🛠️ Deployment Steps

**1. Initialize the working directory**
```bash
terraform init
```

 **2. Verify changes before applying:**

Review the execution plan to see exactly what infrastructure will be created or modified on AWS:
```bash
terraform plan
```

 **3. Provision the Infrastructure:**

Apply the configuration to spin up the entire isolated live environment:
```bash
terraform apply
```

 **4. Tear Down Infrastructure:**

When the resources are no longer needed, gracefully destroy everything to prevent unexpected cloud billing:
```bash
terraform destroy
```

---

## 🔒 Security Best Practices Implemented

* **Zero Public Management Ports:** No raw SSH ports (Port 22) are exposed to the wild internet; environment access leverages native AWS secure tunneling (Systems Manager).

* **Network Segmentation:** The instance only accepts web traffic (HTTP/HTTPS), actively dropping all other unauthorized external requests.

---

<a name="roadmap"></a>
## 🧭 Known Limitations & Roadmap
Documented transparently so the current state isn't confused with the target design:
* No private subnet / no multi-tier network isolation yet, MySQL runs as a container on the same host as the app, isolated only via the Docker bridge network.
* No managed database (RDS), MySQL persistence relies on an EBS-backed Docker volume on a single instance (no automated backups, no multi-AZ).
* Port 443 is open in the Security Group but Nginx does not yet terminate TLS (no certificate configured).
* Single EC2 instance, no load balancer, no auto-scaling, no failover.

Planned improvements: move MySQL to RDS in a private subnet, add a TLS certificate, and re-evaluate network segmentation.
