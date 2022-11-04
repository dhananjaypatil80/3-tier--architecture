terraform {
  # Required Terraform Version
  #required_version = "~> 0.14"
  required_version = "~> 1.1"
  # Required Providers and their Versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0" # Optional but recommended
    }

  }
}


provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAZTXZVXTP6OUGUZ5B"
  secret_key = "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"
}
