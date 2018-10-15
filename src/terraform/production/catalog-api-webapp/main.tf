variable "build-version" {}
variable "environment" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_container" "webapp_container" {
  image = "private/catalog-api-webapp:${var.build-version}"
  name  = "catalog-api-webapp_dev_01-${var.build-version}"
  hostname = "catalog-api-webapp_01-${var.build-version}.dev"
  ports {
    internal = "80"
    external = "80"
  }

  networks = ["catalog-service-network"]
  command = ["supervisord", "-n"]

  provisioner "local-exec" {
    command = "docker exec -t ${self.name} sh -c \"/var/catalog-api/bin/composer.phar --working-dir=/var/catalog-api install && chown -R www-data:www-data /var/catalog-api\""
  }

  provisioner "local-exec" {
    command = "docker exec -t ${self.name} sh -c \"APP_ENV=${var.environment} /var/catalog-api/tasks/robo --load-from /var/catalog-api/tasks/tools run:build-config\""
  }
}
