# GitOps Release Platform

A cloud-ready release workflow for a small Flask API. The repository demonstrates a practical delivery path:

```text
Pull request → tests → container image → Git → Argo CD → Kubernetes
```

The platform is designed around one operational problem: keeping the deployed application state reviewable, reproducible, and recoverable instead of relying on manual cluster edits.

## What is implemented

- Flask service with health, readiness, and release-metadata endpoints
- Non-root, read-only-container Docker image
- Pytest checks executed by GitHub Actions
- GHCR image publishing on pushes to `main`
- Kubernetes Deployment, Service, ServiceAccount, probes, resource limits, and NetworkPolicy
- Kustomize overlays for development and production
- Argo CD Application with automated sync, pruning, and self-healing
- Terraform foundation for a GKE Autopilot cluster, Artifact Registry, and optional GitHub OIDC publishing identity

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
pytest -q
python -m app.main
curl http://localhost:8080/api/v1/release
```

## Local container test

```bash
docker build -t gitops-release-api:local .
docker run --rm -p 8080:8080 gitops-release-api:local
```

## GitOps flow

1. A pull request runs tests and validates the proposed change.
2. A merge to `main` builds and publishes an immutable SHA-tagged image plus the `dev` tag.
3. The environment overlay records the desired image and configuration in Git.
4. Argo CD observes the repository and reconciles the Kubernetes namespace.
5. A Git revert provides a reviewable application rollback path.

This project currently lives under `suhanapatel24/suhanapatel24` in the `gitops-platform/` folder. The GHCR image name is `ghcr.io/suhanapatel24/gitops-release-api`.

## Evidence to collect before adding resume claims

- CI run showing passing tests and image publication
- `kubectl` output showing the Deployment, readiness, and rollout status
- Argo CD application showing `Synced` and `Healthy`
- A controlled rollback commit and successful recovery
- Optional: GCP cost estimate and monitoring screenshot

## Next build milestones

1. Apply the Terraform foundation and collect live deployment evidence.
2. Add a staging-to-production promotion workflow based on image digests.
3. Add Prometheus metrics and a Grafana dashboard.
4. Add vulnerability scanning and a signed-image verification step.
