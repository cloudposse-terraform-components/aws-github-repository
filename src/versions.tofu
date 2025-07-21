terraform {
  required_version = ">= 1.7.0, < 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.6.0"
    }
  }
}
