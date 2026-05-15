# Flask-app CI/CD with AWS ECR

[![CI/CD Pipeline](https://github.com/<YOUR_USER>/<YOUR_REPO>/actions/workflows/main.yml/badge.svg)](https://github.com/<YOUR_USER>/<YOUR_REPO>/actions)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

This repository features a production-ready CI/CD pipeline that automates code quality checks, security auditing, and container deployment to **Amazon Elastic Container Registry (ECR)**.

---

## Features

*   **Automated Linting:** Code quality enforced via `Ruff` and `Hadolint`.
*   **Security First:** Every build is scanned by `Trivy` for vulnerabilities.
*   **Immutable Deployments:** Images are tagged with `github.sha` for 100% traceability.
*   **Infrastructure as Code:** AWS resources managed via Terraform.
*   **Path Filtering:** Documentation changes (README/docs) bypass the Docker build process to save CI minutes.

---

## 🏗 Pipeline Architecture

The GitHub Actions workflow is divided into two logical stages:

### 1. Quality & Security (CI)
Runs on every Pull Request and Push to `main`.
- **Lints** Python code and Dockerfiles.
- **Tests** application logic using `pytest`.
- **Scans** the container filesystem for CVEs.

### 2. AWS Deployment (CD)
Runs only on pushes to `main` after CI passes.
- Authenticates to AWS via OIDC/Access Keys.
- Logs into Amazon ECR.
- Builds and pushes the image using the **Git Commit SHA** as the unique identifier.

---

## Deployment Traceability

We avoid using only the `:latest` tag to prevent "deployment drift." Every image in ECR corresponds to a specific commit:

| Tag Type | Value | Purpose |
| :--- | :--- | :--- |
| **SHA Tag** | `${{ github.sha }}` | Production stability & Rollbacks |
| **Latest Tag** | `latest` | Developer convenience |

---

## Configuration

### GitHub Secrets & Variables
To run this pipeline, configure the following in your repository settings:

| Name | Type | Description |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | **Secret** | AWS IAM User Access Key |
| `AWS_SECRET_ACCESS_KEY` | **Secret** | AWS IAM User Secret Key |
| `AWS_REGION` | **Variable** | The AWS Region (e.g., `us-east-1`) |
| `ECR_REPO_NAME` | **Variable** | The name of your ECR Repository |

### Infrastructure (Terraform)
The ECR repository is provisioned with:
- **Scan on Push:** Enabled for continuous security monitoring.
- **Tag Immutability:** Enabled to prevent accidental overwriting of versioned images.

---

## Local Development

```bash
# Build the image locally
docker build -t flask-app:local .

# Run the container
docker run -p 8080:8080 flask-app:local