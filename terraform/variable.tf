variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
}

variable "region" {
  description = "The region in which to create resources."
  type        = string
  default     = "us-central1"
}

variable "github_repository" {
  description = "The GitHub repository for which to create the Workload Identity Pool."
  type        = string
  default     = "Rjnoord/gcp-workload-identity-lab"
}
