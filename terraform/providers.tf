terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.0.6"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2" # or the latest version
    }
    # template = {
    #   source  = "hashicorp/template"
    #   version = ">= 2.3.0"
    # }

  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}
