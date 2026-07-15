# Smart-Uni Infrastructure (AWS + Terraform) 🏗️

This repository manages the cloud infrastructure and automated provisioning for the **Smart-Uni** university residence management system.

The core application code is maintained in a decoupled, source-only repository:
**[Smart-Uni Application Code](https://github.com/Mohamine2/Smart-Uni)**

---

## 🗺️ Architecture Overview

The infrastructure is built on AWS using Terraform to guarantee standard, repeatable, and secure environments.

### 🛡️ Network and Security Isolation
* **Virtual Private Cloud (VPC)**: Custom isolated network setup to run all computing resources safely.
* **Public & Private Subnets**: Dual-tier segregation ensuring that backend logic and databases are hidden from the open internet, while load balancers or edge entry points handle external ingress.
* **Security Groups**: Tight firewalls operating at the instance level with strict ingress/egress rules (e.g., HTTP, HTTPS, internal DB connectivity).
* **AWS Systems Manager (SSM)**: Configured with the Session Manager plugin to allow safe SSH-less access to the cloud environment without opening public ports.

---

## 🔄 CI/CD & Deployment Strategy

### 🚀 Automated VM Configuration
The project includes an automated deployment pipeline linked directly to the application repository. **On every code push** to the `Smart-Uni` source repository, the pipeline automatically syncs with the AWS virtual machine to:

    1. Re-create the required directory trees and system layouts.
    2. Install and update all configuration dependencies.
    3. Keep the runtime environment strictly aligned with the latest commit.

### 🔒 Access Control & Cost Optimization
* **Restricted Deployment**: Due to access token restrictions and infrastructure security policies, **only the repository owner (myself) has the clearance to deploy and trigger updates** onto the environment.
* **Financial Constraints & Up-time**: To avoid unnecessary cloud billing and stay within financial boundaries, **the AWS EC2 instance is kept stopped/turned off by default**. It is spun up exclusively during active demonstration windows.

---

## 📁 Repository Structure

```text
├── .terraform.lock.hcl  # Locks provider plugin versions
├── main.tf              # Entry point establishing global resources & orchestrations
├── network.tf           # Provisions VPC, subnets, route tables, and gateways
├── security.tf          # Configures AWS Security Groups and IAM permissions
├── providers.tf         # Declares cloud providers (AWS) and required versions
├── variables.tf         # Defines configurable environment arguments
└── outputs.tf           # Declares values to expose after deployment
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

* **Zero Public Management Ports:** No raw SSH ports are exposed to the wild internet; environment access leverages native AWS secure tunneling (SSM).

* **Network Segmentation:** Compute instances run detached from public routers, isolating potential blast radiuses.
