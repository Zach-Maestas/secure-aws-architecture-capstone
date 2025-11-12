# Secure AWS Architecture Capstone

![Architecture Diagram](./docs/architecture.png)

> ⚠️ **Status**: _In Progress_  
> This project is actively being built and iterated on as part of a portfolio-quality infrastructure architecture. Expect changes and additions over time.

---

## 📘 Overview

This is a **production-grade, secure AWS infrastructure** built with **Terraform**, designed to showcase modern cloud architecture best practices. It's a portfolio capstone project intended to demonstrate real-world skills in infrastructure-as-code (IaC), AWS networking, and scalable service design.

---

## ✅ Current Features (As of Now)

- 🏗️ VPC with public and private subnets across two Availability Zones  
- 🌐 Internet Gateway and NAT Gateway setup for secure internet access  
- 🔐 S3 Gateway VPC Endpoint (for secure access to S3 from private subnets)  
- ⚡ Application Load Balancer with HTTP to HTTPS redirect  
- 🔒 AWS ACM Certificate provisioning with Route 53 DNS validation  
- 🔧 Security groups for ALB and EC2 instances  
- 📁 Modular Terraform directory structure  

---

## 🔧 Services Being Used

- Amazon VPC  
- Amazon EC2 (coming soon)  
- Application Load Balancer (ALB)  
- AWS ACM (Certificate Manager)  
- Amazon Route 53  
- Amazon S3  
- Amazon RDS (planned)  
- Auto Scaling (planned)  
- IAM  

---

## 🧠 Goals

- Follow AWS Well-Architected Framework  
- Use only infrastructure-as-code (Terraform)  
- Design with modularity and reusability in mind  
- Harden security and isolate resources by subnet and role  
- Eventually deploy a sample application and database  

---

## 🔜 Planned Next Steps

- [ ] Define compute layer using EC2 and launch templates  
- [ ] Create Auto Scaling Group  
- [ ] Provision Amazon RDS  
- [ ] Add CI/CD pipeline (GitHub Actions or CodePipeline)  
- [ ] Improve observability with CloudWatch  

---

## 📁 Project Structure

```shell
.
├── modules/
│   ├── app/
│   ├── network/
│   └── acm/
├── terraform.tfvars
├── variables.tf
├── main.tf
├── outputs.tf
└── assets/
    └── architecture.png
