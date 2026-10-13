# GCP infrastructure plan

The next infrastructure milestone is a small, reproducible GCP foundation:

1. Artifact Registry repository for the container image.
2. GKE Autopilot cluster for the Argo CD-managed workload.
3. Regional deployment with least-privilege service accounts.
4. Budget alert and labels for owner, environment, and project.

Terraform files should be added only after the target GCP project, region, and billing budget are known. No credentials or project IDs belong in this repository.
