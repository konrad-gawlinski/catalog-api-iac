variable "build-version" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_network" "cs_network" {
  name = "catalog-service-network"
}

resource "docker_container" "database_container" {
  image = "private/catalog-api-database:${var.build-version}"
  name  = "catalog-api-database_dev_01-${var.build-version}"
  hostname = "catalog-api-db_01-${var.build-version}.dev"
  ports {
    internal = "5432"
    external = "5432"
  }

  networks = ["${docker_network.cs_network.id}"]
  command = ["supervisord", "-n"]
}
