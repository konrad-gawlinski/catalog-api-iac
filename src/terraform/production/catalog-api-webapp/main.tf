variable "build-version" {}
variable "environment" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_network" "cs_network" {
  name = "catalog-service-network"
}

resource "docker_container" "webapp_container" {
  image = "private/catalog-api-webapp:${var.build-version}"
  name  = "catalog-api-webapp_prod_01-${var.build-version}"
  hostname = "catalog-api-webapp_01-${var.build-version}.prod"
  ports {
    internal = "80"
    external = "80"
  }

  networks = ["${docker_network.cs_network.id}"]
  command = ["supervisord", "-n"]

  provisioner "local-exec" {
    command = "docker exec -it ${self.name} sh -c \"APP_ENV=${var.environment} /var/catalog-api/tasks/robo --load-from /var/catalog-api/tasks/tools run:build-config\""
  }
}
