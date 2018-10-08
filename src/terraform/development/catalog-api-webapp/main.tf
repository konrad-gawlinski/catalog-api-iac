variable "build-version" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_network" "cs_network" {
  name = "catalog-service-network"
}

resource "docker_container" "webapp_container" {
  image = "private/catalog-api-webapp"
  name  = "catalog-api-webapp_dev:01-${var.build-version}"
  hostname = "catalog-api-webapp_01-${var.build-version}.dev"
  ports {
    internal = "80"
    external = "80"
  }

  networks = ["${docker_network.cs_network.id}"]
  command = ["supervisord", "-n"]
}
