# Secure-by-Default-IaC-Deployment
Apply secure configuration baselines across AWS... integrating them into IaC workflows and CI/CD pipelines.

🚀 Secure-by-Default IaC Deployment with Terraform and Checkov

🎯 Project Goal

The primary objective of this project is to implement a Secure-by-Default Infrastructure-as-Code (IaC) baseline in AWS using Terraform and demonstrate the proactive enforcement of security policies using the Checkov static analysis tool.

This demonstrates the core DevSecOps principle of "shifting left" security—finding and fixing misconfigurations before deployment.

🛠️ Key Skills Demonstrated

- IaC Development: Building complex, multi-resource cloud infrastructure using Terraform.

- Secure Configuration Baseline: Implementing AWS security best practices (Least Privilege, Encryption, Network Segmentation).

- Policy-as-Code (PaC): Integrating Checkov to validate infrastructure against security standards (e.g., CIS Benchmarks).

- CI/CD Simulation: Simulating a pre-deployment security gate using a command-line scanner.

💻 Tools & Technologies
| **Tool**      | **Purpose** |
|---------------|---------|
| AWS           | Target Cloud Provider (VPC, RDS, ALB, IAM).      | 
| Terraform     | Infrastructure-as-Code language for provisioning.      |
| Checkov       | Open-source security static analysis scanner.      |
| Git/GitHub    | Version control and professional documentation.      |

# Methodology: Step-by-Step Implementation
The project is broken into three phases: Setup, Vulnerability Discovery (The Test), and Remediation/Deployment.

## Phase 1: Local Environment Setup
1. Install Prerequisites: Ensure Terraform, Python 3, and the AWS CLI are installed and added to your system's PATH.
2. Install Checkov: Install the policy scanner via Python:
```Bash
pip install checkov
```
3. Configure AWS: Configure your AWS IAM user credentials (ensure they are non-root) for Terraform deployment:
```Bash
aws configure
```
> Recommendation: Utilize IAM Identity Center authentication with the AWS CLI

4. Initialize Project Structure: Create the file structure for the Terraform code (.tf files) in the src/ directory.

## Phase 2: Secure Code Baseline and Policy Enforcement
All Terraform files were written in the src/ directory to provision the following secure resources:

|Resource |	Security Feature Enforced |
|VPC & Subnets |	Separate Public Subnets (for ALB) and Private Subnets (for RDS). |
|Security | Groups (SGs)	Least Privilege: SG for RDS only permits traffic from the ALB's SG, not from broad CIDR ranges. |
|RDS Database |	Encryption at Rest: storage_encrypted = true. Forced deployment into Private Subnets. |
|IAM Role |	Least Privilege: Custom policy that grants only necessary access to the application layer. |

The Security Gate Test (Vulnerability Discovery)
To prove the value of the security scanner, the RDS resource was intentionally configured insecurely (e.g., setting storage_encrypted = false).

Run Checkov Scan:

```Bash
checkov -d src/
Result: Failed Check ❌
```
(Artifact to include: Screenshot 1 of Checkov FAIL output, showing the specific Checkov ID (e.g., CKV_AWS_157) failing the unencrypted RDS check.)

Remediation and Validation
The insecure configuration was remediated by changing storage_encrypted back to true in the RDS resource block.

Re-Run Checkov Scan:
```Bash
checkov -d src/
Result: Passed Checks ✅
```
(Artifact to include: Screenshot 2 of Checkov PASS output, confirming the code is now compliant with best practices.)

## Phase 3: Deployment and Cleanup
Initialize & Validate:

Bash

terraform init
terraform validate
Deploy Final Infrastructure: The secure baseline is deployed to AWS.

Bash

terraform apply --auto-approve
Cleanup (Crucial): All deployed resources are destroyed to prevent recurring AWS charges.

Bash

terraform destroy --auto-approve
2. GitHub Workflow and Artifacts
The following steps ensured the project is professionally presented:

Git Initialization:

Bash

git init
Secure .gitignore: A .gitignore file was created to prevent committing sensitive files, most importantly the Terraform state file (*.tfstate) and local credentials.

# .gitignore content:
.terraform/
*.tfstate*
.terraform.lock.hcl
credentials.csv
Commit and Push: The final, secure Terraform code and documentation were committed and pushed to this repository.

# Project Artifacts (Evidence)
The following files serve as verifiable evidence of project completion:

src/main.tf: The final, secure Terraform code for the VPC, RDS, and ALB.

docs/: Contains screenshots of the Checkov FAIL and Checkov PASS results, demonstrating the successful implementation of the security gate.

README.md (This file): Outlines the full methodology, objectives, and findings.

# ⭐ Lessons Learned
The greatest takeaway was demonstrating that implementing security controls as code is faster and more reliable than manual review. By integrating Checkov as a mandatory local step, a security engineer can ensure that critical controls—like storage encryption and least privilege networking—are enforced automatically, preventing the cost and risk associated with deploying misconfigured infrastructure.
