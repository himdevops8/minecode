terraform {
  backend "s3" {
    bucket = "plido-tf-state-global" // Your existing bucket
    // IMPORTANT: Use a new key for this refactored deployment, or ensure the old one is empty/destroyed
    key    = "plume-module/gitlab-runner/terraform.tfstate"
    region = "us-east-1"
    # dynamodb_table = "your-lock-table" # Uncomment and set if you use one
    encrypt        = true
  }
}
