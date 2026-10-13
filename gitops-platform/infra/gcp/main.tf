locals {
  services = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])
}

resource "google_project_service" "required" {
  for_each           = local.services
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "platform" {
  name                    = "gitops-platform-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "platform" {
  name          = "gitops-platform-${var.region}"
  ip_cidr_range = "10.20.0.0/20"
  region        = var.region
  network       = google_compute_network.platform.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.24.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.28.0.0/20"
  }
}

resource "google_artifact_registry_repository" "containers" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_repository_id
  description   = "Container images for the GitOps Release Platform"
  format        = "DOCKER"
  labels        = var.labels

  depends_on = [google_project_service.required]
}

resource "google_container_cluster" "platform" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = false
  network             = google_compute_network.platform.id
  subnetwork          = google_compute_subnetwork.platform.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = var.labels
  depends_on      = [google_project_service.required]
}

resource "google_iam_workload_identity_pool" "github" {
  count                     = var.enable_github_oidc ? 1 : 0
  project                   = var.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "OIDC identities for the GitHub Actions workflow"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  count                              = var.enable_github_oidc ? 1 : 0
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Actions OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository == '${var.github_repository}'"
}

resource "google_service_account" "github_actions" {
  count        = var.enable_github_oidc ? 1 : 0
  project      = var.project_id
  account_id   = "github-actions"
  display_name = "GitHub Actions Artifact Registry publisher"
}

resource "google_project_iam_member" "github_artifact_writer" {
  count   = var.enable_github_oidc ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions[0].email}"
}

resource "google_service_account_iam_member" "github_wi_user" {
  count              = var.enable_github_oidc ? 1 : 0
  service_account_id = google_service_account.github_actions[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/attribute.repository/${var.github_repository}"
}
