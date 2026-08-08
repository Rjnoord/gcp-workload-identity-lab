resource "google_service_account" "github_deployer" {
  account_id   = "github-deployer"
  display_name = "GitHub OIDC Deployer"

}

resource "google_service_account_iam_member" "github_deployer_workload_identity_user" {
  service_account_id = google_service_account.github_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-pool.name}/attribute.repository/${var.github_repository}"

}
resource "google_project_iam_member" "cloudrun_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"

}

resource "google_service_account" "github_runner" {
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"

}

resource "google_service_account_iam_member" "github_wif" {
  service_account_id = google_service_account.github_runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-pool.name}/attribute.repository/${var.github_repository}"

}
