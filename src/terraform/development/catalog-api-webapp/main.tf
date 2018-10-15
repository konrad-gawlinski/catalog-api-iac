variable "build-version" {}
variable "environment" {}
variable "composer-update" {}
variable "init-database" {}
variable "catalogapi_dbhost" {}
variable "catalogapi_dbport" {}
variable "catalogapi_database" {}
variable "catalogapi_dbschema" {}
variable "catalogapi_dbuser" {}
variable "catalogapi_dbpassword" {}

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

  volumes {
    host_path = "/var/catalog-api-webapp"
    container_path = "/var/catalog-api"
  }

  provisioner "local-exec" {
    command = "${var.composer-update == "yes" ? "docker exec -t ${self.name} sh -c \"/var/catalog-api/bin/composer.phar --working-dir=/var/catalog-api update && chown -R www-data:www-data /var/catalog-api\"" : "echo 'Skipping composer install'"}"
  }

  provisioner "local-exec" {
    command =<<ENV
docker exec -t ${self.name} /bin/bash -c 'echo "\
PG_BIN=\"/usr/bin/psql\"
CATALOG_API_DBHOST=\"${var.catalogapi_dbhost}\"
CATALOG_API_DBPORT=\"${var.catalogapi_dbport}\"
CATALOG_API_DATABASE=\"${var.catalogapi_database}\"
CATALOG_API_DBSCHEMA=\"${var.catalogapi_dbschema}\"
CATALOG_API_DBUSER=\"${var.catalogapi_dbuser}\"
CATALOG_API_DBPASSWORD=\"${var.catalogapi_dbpassword}\"" | tee -a /etc/environment'
ENV
  }

  provisioner "local-exec" {
    command = "docker exec -t ${self.name} sh -c \"APP_ENV=${var.environment} /var/catalog-api/tasks/robo --load-from /var/catalog-api/tasks/tools run:build-config\""
  }

  provisioner "local-exec" {
    command = "${var.init-database == "yes" ? "docker exec -t ${self.name} sh -c \"cd /var/catalog-api/tasks && PG_BIN=/usr/bin/psql ./robo --load-from=./database/RoboFile.php database:init\"" : "echo 'Skipping database init'"}"
  }

  provisioner "local-exec" {
    command = "${var.init-database == "yes" ? "docker exec -t ${self.name} sh -c \"cd /var/catalog-api/tasks && PG_BIN=/usr/bin/psql ./robo --load-from=./database_product/ product:create-tables\"" : "echo 'Skipping product database init'"}"
  }

}
