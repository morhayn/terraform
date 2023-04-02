resource "kubernetes_namespace" "gitea" {
    metadata {
        name = "gitea"
    }
}
resource "kubernetes_deployment" "gitea" {
  metadata {
    name = "gitea-deployment"
    namespace = kubernetes_namespace.gitea.metadata.0.name
    labels = {
        app = "gitea-deploy"
    }
  }
  spec {
    replicas = 1
    selector {
        match_labels = {
            app =  "gitea"        
        }
    }
    template {
        metadata {
            labels = {
                app = "gitea"
            }
        }
        spec {
            container {
                image = "gitea/gitea:1.19.0"
                name = "gitea"
                port {
                    container_port = 22
                }
                port {
                    container_port = 3000
                }
                env {
                    name = DRONE_SERVER_ADDR
                    value = ":8000"
                }
                volume {
                    name = gitea-volume
                    mount_path = "/var/tmp/gitea"
                }
                resources {
                    limits = {
                       cpu = "1"
                       memory = "1G"
                    }
                }
            }
            volume {
                name = gitea-volume
                host_path = "/var/tmp/gitea"
            }
        }
    }
  }
}
resource "kubernetes_service" "gitea" {
    metadata {
        name = "gitea-service"
        namespace = kubernetes_namespace.gitea.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment.gitea.spec.0.template.0.metadata.0.labels.app
        }
        type = "NodePort"
        port {
            name = web
            node_port = 30080
            port = 30080
            target_port = 3000
            }
        port {
            name = ssh
            node_port = 30022
            port = 30022
            target_port = 22
        }
    } 
}