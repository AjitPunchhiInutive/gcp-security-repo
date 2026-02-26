terraform {
  backend "gcs" {
    bucket = "itp-terraform-test"
    prefix = "gcp-security-repo/state"
  }
}
