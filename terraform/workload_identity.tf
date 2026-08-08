resource "google_iam_workload_identity_pool" "github-pool" {
  provider                  = google
  project                   = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Identity Pool"
  description               = "Workload Identity Pool for GitHub Actions"

}

resource "google_iam_workload_identity_pool_provider" "github-provider" {
  provider                           = google
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub pool"
  description                        = "Workload Identity Pool Provider for GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }

  attribute_condition = "assertion.repository == \"${var.github_repository}\""

}
