provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      owner    = "robert.strzepka@outlook.com"
      project  = var.app_name
      environment = terraform.workspace
    }
  }
}