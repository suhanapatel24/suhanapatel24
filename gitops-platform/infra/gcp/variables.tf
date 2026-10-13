variable "project_id" {
  description = "Existing GCP project ID where the platform will be deployed."
  type        = string
}

variable "region" {
  description = "Regional location for the GKE Autopilot cluster and Artifact Registry."
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "Default zone used by the Google provider."
  type        = string
  default     = "us-west1-a"
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster."
  type        = string
  default     = "gitops-release-platform"
}

variable "artifact_repository_id" {
  description = "Artifact Registry repository ID for container images."
  type        = string
  default     = "gitops-release"
}

variable "github_repository" {
  description = "GitHub repository in owner/name form for optional OIDC federation."
  type        = string
  default     = "suhanapatel24/suhanapatel24"
}

variable "enable_github_oidc" {
  description = "Create a least-privilege GitHub Actions identity for Artifact Registry publishing."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default = {
    owner       = "suhana"
    environment = "dev"
    workload    = "gitops-release-platform"
  }
}
