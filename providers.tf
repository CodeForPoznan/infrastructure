terraform {
  backend "s3" {
    bucket  = "codeforpoznan-tfstate"
    key     = "codeforpoznan.tfstate"
    profile = "codeforpoznan"
    region  = "eu-west-1"
  }

  # backend "local" {
  #   path = "./state.tfstate"
  # }

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "4.8.0"
      configuration_aliases = [aws.north_virginia]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.15.0"
    }
  }

  required_version = ">= 1.1.8"
}

provider "aws" {
  region  = "eu-west-1"
  profile = "codeforpoznan_awscli"
}

provider "aws" {
  region  = "us-east-1"
  profile = "codeforpoznan_awscli"
  alias   = "north_virginia"
}

