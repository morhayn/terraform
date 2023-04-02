terraform {
  required_providers {
    kubernetes = {
      source = "kubernetes"
      version = ">= 2.19.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/kube/config"
  config_context = var.cluster-context
}
