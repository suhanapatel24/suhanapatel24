# Deployment evidence — GitOps Release Platform

Updated: 2026-10-13

This is an evidence log, not a claim of production deployment. It records what is verified in the repository and identifies the cloud-side evidence still required.

## Status

| Area | Status | Evidence |
|---|---|---|
| Flask API | Verified locally | `pytest -q` — 2 tests passed in milestone validation |
| Dockerfile | Repository present | Non-root user, read-only root filesystem, dropped capabilities |
| GitHub Actions | Configured | `.github/workflows/ci.yaml` runs tests and builds/publishes a GHCR image on `main` |
| Kubernetes manifests | Static configuration present | `k8s/base/` and dev/prod Kustomize overlays |
| Argo CD | Static configuration present | `gitops/application-dev.yaml` |
| GKE Terraform | Added in this milestone | `infra/gcp/` |
| Live GCP resources | Pending | No GCP project or authenticated `gcloud` session was available during validation |
| Live Argo CD sync | Pending | Requires a live cluster, Argo CD installation, and image pull access |
| Rollback evidence | Pending | Requires a deployed revision and controlled Git revert |

## Required cloud evidence after apply

Run the following from the repository root and save the output in your portfolio notes. Redact tokens and secrets.

```bash
cd infra/gcp
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output

gcloud container clusters get-credentials gitops-release-platform \
  --region us-west1 --project YOUR_PROJECT_ID

kubectl apply -f gitops/application-dev.yaml
kubectl -n gitops-dev rollout status deployment/gitops-release-api --timeout=180s
kubectl -n gitops-dev get deployment,pods,service -o wide
kubectl -n gitops-dev get events --sort-by=.lastTimestamp

argocd app get gitops-release-api-dev
argocd app wait gitops-release-api-dev --health --sync --timeout 180
```

Capture these minimum artifacts:

1. Terraform plan/apply summary showing the GKE cluster and Artifact Registry repository.
2. `kubectl` output showing the deployment available and pods Ready.
3. Argo CD output showing `Synced` and `Healthy`.
4. Successful requests to `/healthz`, `/readyz`, and `/api/v1/release` through the deployed Service.
5. A rollback commit/revert, the resulting Argo CD sync, and a second successful health check.

## Resume-claim gate

Do not write “deployed to GKE,” “implemented GitOps rollback,” or similar claims until the corresponding live evidence above has been captured. Until then, accurate wording is: “Built and locally validated a Terraform/GKE and Argo CD deployment path.”
