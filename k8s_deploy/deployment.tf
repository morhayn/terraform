resource "kubernetes_namespace" "diaginfra" {
    metadata {
        name = "diaginfra"
    }
}
resource "kubernetes_deployment" "diaginfra" {
  metadata {
    name = "diaginfra-deployment"
    namespace = kubernetes_namespace.diaginfra.metadata.0.name
    labels = {
        app = "diag-deploy"
    }
  }
  spec {
    replicas = 1
    selector {
        match_labels = {
            app =  "diag"        
        }
    }
    template {
        metadata {
            labels = {
                app = "diag"
            }
        }
        spec {
            container {
                image = "diaginfra:0.1.0"
                name = "diaginfra"
                port {
                    cpntainer_port = 3000
                }
            }
            resources {
                limits = {
                    cpu = "0.6"
                    memory = "256Mi"
                }
            }
            liveness_probe {
                http_get {
                    path = "/live"
                    port = 80
                }
                http_header {
                    name = "X-Live"
                    value = "OK"
                }
                initial_delay_seconds = 2
                period_seconds = 5
            }
        }
    }
  }
}
resource "kubernetes_service" "diaginfra" {
    metadata {
        name = "diag-service"
        namespace = kubernetes_namespace.diaginfra.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment.diaginfra.spec.0.template.0.metadata.0.labels.app
        }
        type = "NodePort"
        port {
            node_port = 6000
            port = 3000
            target_port = 3000
        }
    } 
}