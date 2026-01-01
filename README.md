# Secure AWS Architecture Capstone

![Architecture Diagram](./docs/architecture.png)

> ✅ **Status:** _Completed_  
> This project showcases a production-grade, secure AWS infrastructure built with Terraform. It follows best practices for scalability, modularity, and security, and serves as a portfolio-ready demonstration of cloud architecture design.

---

## 📘 Overview

This is a **production-grade, secure AWS infrastructure** built with **Terraform**, designed to highlight modern cloud architecture principles.  
The project demonstrates real-world skills in **infrastructure-as-code (IaC)**, **AWS networking**, and **secure service design**, with an emphasis on modularity and least privilege.

---

## ✅ Current Features

- 🏗️ **VPC** with public and private subnets across two Availability Zones  
- 🌐 **Internet Gateway** and **NAT Gateway** for controlled internet access  
- 🔐 **S3 Gateway VPC Endpoint** for secure private-subnet access to S3  
- ⚡ **Application Load Balancer** with HTTP→HTTPS redirect  
- 🔒 **AWS ACM Certificate** provisioning via Route 53 DNS validation  
- 🧱 **Security groups** for ALB and EC2 isolation  
- 📁 **Modular Terraform** directory structure  

---

## 🔧 Services Used

- Amazon VPC  
- Amazon EC2  
- Application Load Balancer (ALB)  
- AWS Certificate Manager (ACM)  
- Amazon Route 53  
- Amazon S3  
- Amazon RDS  
- Auto Scaling  
- AWS Identity and Access Management (IAM)  

---

## 🧠 Goals

- Align with the **AWS Well-Architected Framework**  
- Build entirely using **infrastructure-as-code** (Terraform)  
- Design for **modularity**, **reusability**, and **scalability**  
- Enforce **security isolation** by subnet and IAM role  
- Deploy a **sample Flask application** and **RDS database** securely  

---

## 🧩 Next Phase

This project serves as **Capstone 1** in a three-part Cloud Security Engineering portfolio.  
The next phase, **[Automated Cloud Security & Operations (CloudOps) Capstone](https://github.com/Zach-Maestas/cloudops-capstone)** (_TBD_), extends this foundation by introducing:
- Automated deployment pipelines (CI/CD)
- Infrastructure monitoring and alerting (CloudWatch)
- Auto Scaling and fault tolerance
- Security automation and incident response integration  

---

## 📂 Project Structure

```shell
.
├── application/
│   ├── backend/
│   │   ├── app.py
│   │   └── requirements.txt
│   └── frontend/
│       ├── index.html
│       ├── styles.css
│       └── app.js
│
├── infrastructure/
│   ├── scripts/
│   │   └── user_data.sh
│   └── terraform/
│       ├── main.tf
│       ├── backend.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       ├── variables.tf
│       ├── versions.tf
│       ├── .terraform.lock.hcl
│       └── modules/
│           ├── network/
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── outputs.tf
│           ├── app/
│           │   ├── data.tf
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   ├── security_groups.tf
│           │   └── outputs.tf
│           ├── data/
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── outputs.tf
│           ├── secrets/
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── outputs.tf
│           └── acm/
│               ├── data.tf
│               ├── main.tf
│               ├── variables.tf
│               ├── security_groups.tf
│               └── outputs.tf
│
└── docs/
    ├── architecture.png
    ├── deployment.md
    ├── security.md
    └── demo.md
```
