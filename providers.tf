terraform {
  cloud {
    organization = "nobleadmin"

    workspaces {
      name = "example-workspace"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  
}

provider "aws" {
  region = "eu-west-1"
  alias = "eu"
  
}



