resource "kubernetes_config_map" "drone" {
    metadata {
        name = "drone-config"
        namespace = kubernetes_namespace.gitea.metadata.0.name
    }
    data = {
        "server.database.driver" = "sqlite3"
        "server.database.config" = "/va/lib/drone/drone.sqlite"
    }
}