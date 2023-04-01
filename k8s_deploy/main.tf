terraform {
  required_providers {
    kubernetes = {
      source = "kubernetes"
      version = ">= 2.19.0"
    }
    helm = {
        source = "helm"
        version = ">= 2.9.0"
    }
  }
}
variable "helm_registry_user" {
  description = "Username for HELM registry"
  type = string
}
variable "helm_registry_password" {
  description = "Password for HELM registry"
  type = string
}

provider "kubernetes" {
  config_path = "~/kube/config"
  config_context = var.cluster-context
}
provider "helm" {
    kubernetes {
      config_path = "~/kube/config"
      config_context = var.cluster-context
    }
    registry {
      url = "oci://registry.local:5000"
      username = var.helm_registry_user
      password = var.helm_registry_password
    }
}
resource "helm_release" "giaginfra" {
  name = "diaginfra"
  namespase = "diag"
  repository = "oci://registry.local:5000"
  version = "0.1.0"
  chart = "diaginfra"
}
date "helm_template" "diaginfra" {
  name = "diaginfra"
  namespace = "diag"
  repository = "oci://registry.local:5000"
  chart = "diaginfra"
  version = "0.1.0"
  set {
    name = "service.port"
    value = "3000"
  }
  set_sensitive {
    name = "tomcat.password"
    value = "test21^"
  }
}
resourece "local_file" "diaginfra_manifests" {
  for_each = data.helm_template.diaginfra.manifests
  filename = "./${each.key}"
  content = each.value
}
output "diaginfra_manifest" {
  value = data.helm_template.diaginfra.manifest
}
output "diaginfra_notes" {
  value = data.helm_template.diaginfra.notes
}