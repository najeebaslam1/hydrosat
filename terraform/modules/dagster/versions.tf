terraform {
  required_version = ">= 1.0.6"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2" # or the latest version
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    # template = {
    #   source  = "hashicorp/template"
    #   version = ">= 2.3.0"
    # }
  }
}
