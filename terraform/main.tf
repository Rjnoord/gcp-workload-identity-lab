resource "google_service_account" "github" {
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"

}
