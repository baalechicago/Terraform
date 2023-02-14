terraform {
  cloud {
    organization = "nobleadmin"

    workspaces {
      name = "example-workspace-update"
    }
  }
}

provider "aws" {
  region = "us-east-2"

}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu"

}



