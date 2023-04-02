resource "kubernetes_deployment" "agent" {
  metadata {
    name = "agent-deployment"
    namespace = kubernetes_namespace.gitea.metadata.0.name
    labels = {
        app = "agent-deploy"
    }
  }
  spec {
    replicas = 1
    selector {
        match_labels = {
            app =  "agent"        
        }
    }
    template {
        metadata {
            labels = {
                app = "agent"
            }
        }
        spec {
            container {
                image = "library/docker:17.12.0-ce-bind"
                name = "bind"
                port {
                    container_port = 2375
                }
            }
            container {
                image = "drone/agent:0.8.5"
                name = "agent"
                env = [
                    {
                        name = "DRONE_HOST"
                        value = "tcp://localhost:2375"
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
                        name = "DRONE_SERVER"
                        value_from = {
                            config_map_key_ref = {
                                name = "drone-config"
                                key = "server.drone.server.url"
                            }
                        }
                    }
                ]
                resources {
                    limits = {
                       cpu = "1"
                       memory = "1G"
                    }
                }
            }
        }
    }
  }
}