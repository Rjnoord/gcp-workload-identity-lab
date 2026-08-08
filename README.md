# GCP Workload Identity Federation Lab

A small lab that sets up [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) so GitHub Actions can authenticate to GCP without a long-lived service account key, then uses it to deploy from a CI pipeline.

## What this builds

- A **Workload Identity Pool** (`github-actions-pool`) and **OIDC provider** (`github-actions-provider`) trusting `token.actions.githubusercontent.com`.
- An `attribute_condition` that restricts the trust relationship to a single GitHub repository (`assertion.repository == "<owner>/<repo>"`).
- Two service accounts:
  - `github-deployer` — granted `roles/run.admin` on the project, impersonated by the deploy workflow.
  - `github-actions` — a general-purpose runner identity bound to the same pool.
- IAM bindings (`roles/iam.workloadIdentityUser`) that let the matching GitHub repo's OIDC token impersonate each service account via `principalSet`.
- A GitHub Actions workflow (`.github/workflows/deploy.yml`) that authenticates using [`google-github-actions/auth`](https://github.com/google-github-actions/auth) and no static credentials.

## Repository layout

```
terraform/
  provider.tf            # google provider + required version
  variable.tf             # project_id, region, github_repository
  service_account.tf      # deployer + runner service accounts, IAM bindings
  workload_identity.tf    # WIF pool + OIDC provider
  output.tf                # exported identifiers used by the workflow
  terraform.tfvars         # project-specific values (not secret)
.github/workflows/
  deploy.yml               # OIDC-based deploy pipeline
```

## Prerequisites

- A GCP project with the following APIs enabled: `iam.googleapis.com`, `iamcredentials.googleapis.com`, `sts.googleapis.com`, `run.googleapis.com`.
- Terraform >= 1.5 and the `hashicorp/google` provider (`~> 7.0`).
- A GitHub repository to trust — its `owner/repo` name (case-sensitive) goes into `github_repository`.

## Deploying the lab

```bash
cd terraform
terraform init
terraform apply
```

Key variables (see `variable.tf`):

| Variable | Description | Default |
|---|---|---|
| `project_id` | GCP project to create resources in | *(required)* |
| `region` | Default region | `us-central1` |
| `github_repository` | `owner/repo` allowed to assume the WIF identities | `Rjnoord/gcp-workload-identity-lab` |

After `apply`, note the outputs — the workflow's `workload_identity_provider` and `service_account` inputs must match `workload_identity_pool_provider_name` and `deployer_service_account_email`.

## How the pipeline authenticates

`.github/workflows/deploy.yml` requests an OIDC token (`permissions: id-token: write`) and exchanges it for short-lived GCP credentials:

```yaml
- uses: google-github-actions/auth@v3
  with:
    project_id: <project_id>
    workload_identity_provider: projects/<num>/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider
    service_account: github-deployer@<project_id>.iam.gserviceaccount.com
```

No JSON key is ever stored in GitHub. Access is scoped two ways:

1. The pool provider's `attribute_condition` rejects tokens whose `assertion.repository` claim doesn't exactly match `github_repository` (case-sensitive — GitHub's claim uses the org's actual casing).
2. The `principalSet://.../attribute.repository/<repo>` binding on each service account only grants `workloadIdentityUser` to that same repo.

## Troubleshooting

**`unauthorized_client: The given credential is rejected by the attribute condition.`**
The `assertion.repository` claim from GitHub didn't match the `attribute_condition`. Check that `github_repository` matches your repo's `owner/repo` exactly, including case — verify with `gh repo view --json nameWithOwner`.

**`permission_denied` on impersonation**
Confirm the `google_service_account_iam_member` binding's `principalSet` repo segment matches the calling repo, and that the pool/provider IDs in the workflow match Terraform's outputs.

## Cleaning up

```bash
cd terraform
terraform destroy
```
<img width="1470" height="956" alt="Screenshot 2026-08-08 at 4 10 46 PM" src="https://github.com/user-attachments/assets/c4f54b5d-51bf-4148-997b-544fbb9738a4" />
<img width="1470" height="956" alt="Screenshot 2026-08-08 at 4 10 58 PM" src="https://github.com/user-attachments/assets/c003f8cb-4ff5-486a-ac5f-615e7151cc2d" />
<img width="1470" height="956" alt="Screenshot 2026-08-08 at 4 13 02 PM" src="https://github.com/user-attachments/assets/824b5643-4314-42c7-9625-1fa5652e25b2" />
<img width="1470" height="956" alt="Screenshot 2026-08-04 at 8 42 40 PM" src="https://github.com/user-attachments/assets/9906d1c1-9c80-461a-bf20-f83adf3cfefb" />
<img width="1470" height="956" alt="Screenshot 2026-08-08 at 4 11 54 PM" src="https://github.com/user-attachments/assets/4da15d2d-f786-41b4-9359-2a880961b916" />
<img width="1470" height="956" alt="Screenshot 2026-08-08 at 4 11 07 PM" src="https://github.com/user-attachments/assets/c6bf50bc-688d-4857-b588-4fa3f5fa5c83" />
<img width="1470" height="956" alt="Screenshot 2026-08-08 at 4 13 24 PM" src="https://github.com/user-attachments/assets/d1cf267c-bc41-4079-81f4-025ecbf2846e" />
