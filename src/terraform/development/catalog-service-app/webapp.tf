variable "build-version" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_network" "cs_network" {
  name = "catalog-service-network"
}

module "catalog-webapp" {
  source = "../../modules/docker-container"

  image = "private/catalog-api:${var.build-version}"
  container-name = "catalog-api:${var.build-version}:001"
  docker-network-id = "${docker_network.cs_network.id}"
  internal-port = 80
  external-port = 80
}
