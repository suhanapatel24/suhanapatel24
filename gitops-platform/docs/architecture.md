# Architecture

```text
Developer
   │ pull request
   ▼
GitHub Actions ── tests ── build ── publish image to GHCR
   │
   ▼
Git repository: Kubernetes overlays + Argo CD Application
   │ reconciliation
   ▼
Argo CD ── desired state ── Kubernetes cluster
                              │
                              ▼
                       Flask release API
```

## Design choices

- **Kustomize** keeps a shared base while allowing environment-specific image tags and namespaces.
- **Argo CD** continuously reconciles declared state and detects drift.
- **Health and readiness probes** separate process health from traffic eligibility.
- **Least privilege** is applied through a non-root container, dropped Linux capabilities, a read-only root filesystem, and a tokenless ServiceAccount.
- **Resource requests and limits** make scheduling and basic capacity behavior explicit.
