terraform {
  backend "gcs" {
    bucket = "itp-terraform-test"
    prefix = "gcp-security-foundation/state"
  }
}
