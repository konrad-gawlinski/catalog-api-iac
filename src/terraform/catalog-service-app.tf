variable "tag-version" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_network" "cs_network" {
  name = "catalog-service-network"
}

resource "docker_container" "catalog-api--webapp" {
  image = "private/catalog-api:${var.tag-version}"
  name  = "catalog-api--${var.tag-version}"
  ports {
    internal = 80
    external = 80
  }

  networks = ["${docker_network.cs_network.id}"]
  command = ["supervisord", "-n"]
}

resource "docker_container" "catalog-api--database" {
  image = "private/postgres:${var.tag-version}"
  name  = "catalog-api--postgres--${var.tag-version}"
  ports {
    internal = 5432
    external = 5432
  }
  networks = ["${docker_network.cs_network.id}"]
  command = ["supervisord", "-n"]
}