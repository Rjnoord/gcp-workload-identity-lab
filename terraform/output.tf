output "service_account_email" {
  value = google_service_account.github.email

}

output "workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.github-pool.workload_identity_pool_id

}

output "workload_identity_pool_provider_id" {
  value = google_iam_workload_identity_pool_provider.github-provider.workload_identity_pool_provider_id

}

output "workload_identity_pool_provider_name" {
  value = google_iam_workload_identity_pool_provider.github-provider.name

}

