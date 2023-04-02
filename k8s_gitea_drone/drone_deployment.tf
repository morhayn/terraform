resource "kubernetes_deployment" "drone" {
  metadata {
    name = "drone-deployment"
    namespace = kubernetes_namespace.gitea.metadata.0.name
    labels = {
        app = "drone-deploy"
    }
  }
  spec {
    replicas = 1
    selector {
        match_labels = {
            app =  "drone"        
        }
    }
    template {
        metadata {
            labels = {
                app = "drone"
            }
        }
        spec {
            container {
                image = "drone/drone:0.8.5"
                name = "drone"
                port {
                    container_port = 8000
                }
                env = [
                    {
                      name = "DRONE_SERVER_ADDR"
                      value = ":8000"
                    },
                    {
                      name = "DRONE_HOST"
                      value = "http://drone-server:30567"
                    },
                    {
                      name = "DRONE_GITEA"
                      value = "http://gitea-server:30080"
                    },
                    {
                      name = "DRONE_GITEA_GIT_USERNAME"
                      value = "user"
                    },
                    {
                      name = "DRONE_GITEA_PASSWORD"
                      value = "pass##21"
                    },
                    {
                        name = "DRONE_SECRET"
                        value_from = {
                            secret_key_ref = {
                                name = drone-secret
                                key = server.secret
                            }
                        }
                    },
                    {
                        name = "DRONE_DATABASES_DRIVER"
                        value_from = {
                            config_map_key_ref = {
                                name = "drone-config"
                                key = "server.database.driver"
                            }
                        }
                    },
                    {
                        name = "DRONE_DATABASES_DATASOURCE"
                        value_from = {
                            config_map_key_ref = {
                                name = "drone-config"
                                key = "server.database.config"
                            }
                        }
                    },
                    {
                        name = "DRONE_ADMIN"
                        value_from = {
                            config_map_key_ref = {
                                name = "drone-config"
                                key = "server.admin.list"
                            }
                        }
                    }
                ]
                volume {
                    name = drone-volume
                    mount_path = "/var/lib/drone"
                }
                resources {
                    limits = {
                       cpu = "40m"
                       memory = "1G"
                    }
                }
            }
            volume {
                name = drone-volume
                host_path = "/var/tmp/drone"
            }
        }
    }
  }
}
resource "kubernetes_service" "drone" {
    metadata {
        name = "gitea-service"
        namespace = kubernetes_namespace.gitea.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment.drone.spec.0.template.0.metadata.0.labels.app
        }
        type = "NodePort"
        port {
            name = drone
            node_port = 30567
            port = 8000
            target_port = 8000
        }
    } 
}