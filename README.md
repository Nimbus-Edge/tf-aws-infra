# AWS Infrastructure as Code with Terraform

A comprehensive Infrastructure as Code (IaC) solution for deploying a multi-tier application infrastructure on AWS using Terraform. This project sets up a complete networking stack, auto-scaling application servers, load balancer, database infrastructure, S3 storage, and serverless components following AWS best practices.

## Table of Contents
- [AWS Infrastructure as Code with Terraform](#aws-infrastructure-as-code-with-terraform)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Prerequisites](#prerequisites)
  - [Directory Structure](#directory-structure)
  - [Module Description](#module-description)
    - [Networking Module](#networking-module)
    - [ALB Module](#alb-module)
    - [ASG Module](#asg-module)
    - [RDS Module](#rds-module)
    - [S3 Module](#s3-module)
    - [IAM Module](#iam-module)
    - [SNS Module](#sns-module)
    - [Lambda Module](#lambda-module)
    - [KMS Module](#kms-module)
    - [Secrets Module](#secrets-module)
    - [ACM Module](#acm-module)
    - [DNS Module](#dns-module)
  - [Infrastructure Components](#infrastructure-components)
    - [Auto Scaling Configuration](#auto-scaling-configuration)
    - [Database Configuration](#database-configuration)
  - [Security Features](#security-features)
    - [KMS Encryption](#kms-encryption)
    - [Secrets Management](#secrets-management)
    - [Network Security](#network-security)
  - [Configuration](#configuration)
  - [SSL Certificate Setup](#ssl-certificate-setup)
    - [Dev Environment](#dev-environment)
    - [Demo Environment](#demo-environment)
  - [Usage](#usage)
  - [CI/CD Integration](#cicd-integration)
  - [Logging and Monitoring](#logging-and-monitoring)
    - [CloudWatch Integration](#cloudwatch-integration)
    - [Application Logging](#application-logging)
  - [Serverless Components](#serverless-components)
    - [Lambda Function](#lambda-function)
    - [Email Verification Flow](#email-verification-flow)

## Overview

This Terraform project creates a production-ready AWS infrastructure with:
- Multi-AZ VPC setup with public and private subnets
- Application Load Balancer (ALB) with SSL/TLS termination
- Auto Scaling Group with customizable scaling policies
- RDS PostgreSQL database in private subnets
- S3 bucket for application assets with server-side encryption
- SNS topic for user verification emails
- Lambda function for email processing using SendGrid
- Route 53 DNS configuration
- IAM roles with least-privilege access
- CloudWatch monitoring and metrics collection
- KMS keys for encryption at rest
- AWS Secrets Manager for sensitive data

## Architecture

```plaintext
├── VPC (10.0.0.0/16)
│   ├── Public Subnets
│   │   ├── 10.0.1.0/24 (us-east-1a)
│   │   ├── 10.0.2.0/24 (us-east-1b)
│   │   └── 10.0.3.0/24 (us-east-1c)
│   └── Private Subnets
│       ├── 10.0.4.0/24 (us-east-1a)
│       ├── 10.0.5.0/24 (us-east-1b)
│       └── 10.0.6.0/24 (us-east-1c)
├── Application Load Balancer (HTTPS:443)
├── Auto Scaling Group
│   └── EC2 Instances (t2.small)
│       └── CloudWatch Agent
├── RDS PostgreSQL (db.t3.medium)
├── S3 Bucket
├── SNS Topic
├── Lambda Function
├── KMS Keys
│   ├── EC2 Encryption
│   ├── RDS Encryption
│   ├── S3 Encryption
│   └── Secrets Encryption
└── Secrets Manager
    ├── Database Password
    └── SendGrid API Key
```

## Prerequisites

- Terraform >= 1.9.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions
- Domain name configured in Route 53
- SSL certificate for your domain
- SendGrid account and API key for email notifications
- Node.js >= 18.x
- Git for version control
- PostgreSQL client for database management
- Text editor or IDE for configuration management

## Directory Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml          # CI/CD pipeline
├── environments/
│   └── dev/
│       ├── main.tf                   # Main configuration
│       ├── variables.tf              # Variable definitions
│       ├── terraform.tfvars          # Variable values
│       ├── outputs.tf                # Output definitions
│       └── user_data.tpl             # EC2 user data template
├── modules/
│   ├── ASG/                          # Auto Scaling Group resources
│   ├── Certificate/                  # ACM certificate management
│   ├── CloudWatch_Alarm/            # CloudWatch alarms for scaling
│   ├── EC2/                          # EC2 IAM roles and instance setup
│   ├── ELB/                          # Application Load Balancer config
│   ├── KMS/                          # KMS encryption key resources
│   ├── Lambda/                       # Lambda function configuration
│   ├── Launch_Template/             # EC2 launch templates
│   ├── PG/                           # PostgreSQL parameter group
│   ├── RDS/                          # RDS instance configuration
│   ├── Route53/                      # Route 53 DNS records
│   ├── S3/                           # S3 bucket setup and policies
│   ├── Secrets_Manager/             # Secrets Manager configurations
│   ├── SG/                           # Security Groups
│   ├── SNS/                          # SNS topic setup
│   └── VPC/                          # VPC and subnet resources
└── ssl-certificates/                # SSL certificate files
```

## Module Description

### Networking Module
- Creates VPC with configurable CIDR block
- Sets up public and private subnets across multiple AZs
- Configures Internet Gateway and routing
- Implements network isolation
- Manages route tables and subnet associations

### ALB Module
- Configures Application Load Balancer in public subnets
- Implements health checks and routing rules
- Manages security groups for load balancer access
- Supports HTTPS traffic on port 443
- Handles SSL certificate integration
- Configures target groups
- Sets up listener rules

### ASG Module
- Manages Auto Scaling Group with configurable capacity
- Configures launch templates for EC2 instances
- Implements CPU-based scaling policies
- Sets up CloudWatch alarms for scaling triggers

### RDS Module
- Deploys PostgreSQL RDS instance in private subnets
- Configures security groups for database access
- Manages parameter groups and subnet groups
- Supports automated backups
- Configures encryption at rest

### S3 Module
- Creates S3 bucket with encryption
- Implements lifecycle policies
- Blocks public access
- Configures server-side encryption

### IAM Module
- Creates EC2 instance roles
- Configures policies for CloudWatch, S3, and SNS access
- Implements least-privilege access
- Manages service-linked roles
- Sets up cross-account access

### SNS Module
- Creates topic for user verification emails
- Configures access policies
- Integrates with Lambda function

### Lambda Module
- Deploys email verification function
- Configures SendGrid integration
- Sets up SNS trigger

### KMS Module
- Creates encryption keys for various services
- Manages key policies
- Configures key rotation
- Sets up key aliases

### Secrets Module
- Manages sensitive configuration values
- Configures encryption
- Sets up access policies
- Handles secret versioning

### ACM Module
- Manages SSL/TLS certificates

### DNS Module
- Configures Route 53 hosted zones
- Manages DNS records

## Infrastructure Components

### Auto Scaling Configuration
- Minimum instances: 3
- Maximum instances: 5
- Scale up threshold: 5% CPU utilization
- Scale down threshold: 3% CPU utilization
- Instance type: t2.small
- Health check grace period: 300 seconds
- Default cooldown: 60 seconds
- Desired capacity: 3
- Termination policies: Default
- Instance refresh: Enabled

### Database Configuration
- Engine: PostgreSQL 14.13
- Instance class: db.t3.medium
- Storage: GP2 (General Purpose SSD)
- Allocated storage: 10 GB
- Multi-AZ: Disabled
- Automated backups: Enabled
- Backup retention period: 7 days
- Performance Insights: Enabled
- Enhanced monitoring: Enabled
- Auto minor version upgrade: Enabled

## Security Features

### KMS Encryption
- Separate KMS keys for EC2, RDS, S3, and Secrets Manager
- Automatic key rotation enabled
- Granular access control through key policies
- Key usage monitoring
- Cross-region key replication disabled
- Custom key store: Disabled

### Secrets Management
- Database credentials stored in AWS Secrets Manager
- SendGrid API key secured in Secrets Manager
- Automatic secret rotation capability
- KMS encryption for secrets
- Secret versioning enabled

### Network Security
- Security groups with minimal required access
- Private subnets for database and application layers
- VPC endpoint policies
- SSL/TLS termination at load balancer
- VPC endpoints for AWS services

## Configuration

Create a `terraform.tfvars` file in your environment directory:

```hcl
# Region and Environment
aws_region  = "us-east-1"
environment = "demo"

# Domain Configuration
domain_name = "csye6225webapp.me"

# Availability Zones
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# VPC Configuration
vpcs = {
  main-vpc = {
    cidr_block           = "10.0.0.0/16"
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
}

# EC2 Configuration
ami_id           = "ami-055b7f1f42c061230"
instance_type    = "t2.small"
application_port = 3000
key_name         = "demo-ssh-key"

# Database Configuration
database_port             = 5432
db_parameter_group_family = "postgres14"
db_engine                = "postgres"
db_engine_version        = "14.13"
db_instance_class        = "db.t3.medium"
db_name                  = "csye6225"
db_username              = "csye6225"

# Auto Scaling Configuration
min_size             = 3
max_size             = 5
desired_capacity     = 3
scale_up_threshold   = "5"
scale_down_threshold = "3"

# Lambda Configuration
sendgrid_api_key = "your-sendgrid-api-key"
lambda_zip_path  = "serverless/user-verification.zip"
```

## SSL Certificate Setup

### Dev Environment

For the development environment, use AWS Certificate Manager (ACM) to provision your SSL certificate:

1. Request a certificate through ACM:
```bash
aws acm request-certificate \
  --domain-name dev.csye6225webapp.me \
  --validation-method DNS \
  --region us-east-1
```

2. Add the provided CNAME records to your DNS configuration for validation.

3. Verify the certificate status:
```bash
aws acm list-certificates --region us-east-1
```

### Demo Environment

For the demo environment, you must use a third-party SSL certificate (e.g., Namecheap) and import it into ACM:

1. Create a directory for your SSL certificates in your project root:
```bash
mkdir ssl-certificates
cd ssl-certificates
```

2. Place your purchased SSL certificate files in this directory:
   - `demo_csye6225webapp_me.crt` (Your SSL certificate)
   - `demo_csye6225webapp_me.ca-bundle` (Certificate chain/bundle)
   - `private.key` (Private key)

3. Verify your certificate files:
```bash
# List files to ensure they're in place
ls -la
```

4. Import the certificate into AWS Certificate Manager:
```bash
aws acm import-certificate \
  --certificate fileb://demo_csye6225webapp_me.crt \
  --private-key fileb://private.key \
  --certificate-chain fileb://demo_csye6225webapp_me.ca-bundle \
  --region us-east-1
```

5. Verify the import was successful:
```bash
aws acm describe-certificate \
  --certificate-arn <certificate-arn-from-previous-command> \
  --region us-east-1
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. To destroy the infrastructure:
```bash
terraform destroy
```

## CI/CD Integration

GitHub Actions workflow includes:

1. Terraform Format Check:
```yaml
- name: Terraform Format
  run: terraform fmt -check -recursive
```

2. Terraform Initialization:
```yaml
- name: Terraform Init
  run: terraform init -backend=false
```

3. Terraform Validation:
```yaml
- name: Terraform Validate
  run: terraform validate
```

## Logging and Monitoring

### CloudWatch Integration
- Custom metrics for application monitoring
- CPU utilization tracking
- Memory usage monitoring
- Disk I/O tracking
- Network traffic monitoring
- Custom metric dimensions

### Application Logging
- Centralized logging with CloudWatch Logs
- Log retention policies
- Log group organization
- Structured logging format
- Log streaming enabled

## Serverless Components

### Lambda Function
- Node.js 18.x runtime
- SendGrid integration for email sending
- SNS topic subscription
- CloudWatch Logs integration

### Email Verification Flow
1. User registration triggers SNS notification
2. Lambda function processes SNS message
3. SendGrid API sends verification email
4. User clicks verification link
5. Application verifies user account
6. Account status updated in database
7. Success/failure logging
8. Metrics collection