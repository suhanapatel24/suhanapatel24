# GCP infrastructure

This Terraform root module creates a small GCP foundation for the GitOps Release Platform:

- a custom VPC and regional subnet with secondary ranges for GKE pods and services;
- a regional GKE Autopilot cluster;
- a Docker Artifact Registry repository; and
- an optional GitHub Actions OIDC identity with only `roles/artifactregistry.writer`.

No project IDs, state files, credentials, or secrets belong in Git. Use a remote state backend before a shared or production deployment.

## Prerequisites

1. An existing GCP project with billing enabled.
2. An identity allowed to enable APIs and create the resources in this module.
3. Terraform 1.6+ and Google Cloud CLI installed locally.
4. Application Default Credentials: `gcloud auth application-default login`.

## Plan and apply

```bash
cd infra/gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set project_id.
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

The cluster and registry are billable resources. Review the plan before applying and destroy the lab when finished:

```bash
terraform destroy
```

## Configure kubectl

```bash
gcloud container clusters get-credentials gitops-release-platform \
  --region us-west1 \
  --project YOUR_PROJECT_ID
kubectl get nodes
```

When `enable_github_oidc` is true, use the `github_workload_identity_provider` and `github_actions_service_account` outputs as GitHub repository variables. The current workflow still publishes to GHCR; switching the image destination to Artifact Registry should be a separate, verified change after the first Terraform apply.
