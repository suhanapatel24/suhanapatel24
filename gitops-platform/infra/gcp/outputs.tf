output "cluster_name" {
  description = "GKE Autopilot cluster name."
  value       = google_container_cluster.platform.name
}

output "cluster_location" {
  description = "GKE cluster region."
  value       = google_container_cluster.platform.location
}

output "artifact_registry_repository" {
  description = "Fully qualified Artifact Registry repository name."
  value       = google_artifact_registry_repository.containers.name
}

output "artifact_registry_image_prefix" {
  description = "Prefix for images pushed to Artifact Registry."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.containers.repository_id}"
}

output "github_actions_service_account" {
  description = "Service account used by GitHub Actions when OIDC is enabled."
  value       = var.enable_github_oidc ? google_service_account.github_actions[0].email : null
}

output "github_workload_identity_provider" {
  description = "Workload Identity Provider resource for GitHub Actions auth."
  value       = var.enable_github_oidc ? google_iam_workload_identity_pool_provider.github[0].name : null
}
