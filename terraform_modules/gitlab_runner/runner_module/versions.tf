terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Match your existing or use a recent one
    }
  }
  required_version = ">= 1.3"
}