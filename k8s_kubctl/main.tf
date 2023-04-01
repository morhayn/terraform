terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      config_path = "~/kube/config"
      config_context = var.cluster-context
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = var.cluset-context
}

provider "kubectl" {
  config_path = "~/.kube/config"
  config_context = var.cluster-context
}

data "kubectl_file_documents" "file" {
  content = file("manifest.yaml")
}

resource "kubectl_manifest" "crds-test" {
  for_each  = data.kubectl_file_documents.file.manifests
  yaml_body = each.value
  wait = true
  server_side_apply = true
}