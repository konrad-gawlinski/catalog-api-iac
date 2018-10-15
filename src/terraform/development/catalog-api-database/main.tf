variable "build-version" {}
variable "catalogapi_database" {}
variable "catalogapi_dbschema" {}
variable "catalogapi_dbuser" {}
variable "catalogapi_dbpassword" {}

provider "docker" {
  host = "tcp://127.0.0.1:2375"
}

resource "docker_container" "database_container" {
  image = "private/catalog-api-database:${var.build-version}"
  name  = "catalog-api-database_dev_01-${var.build-version}"
  hostname = "catalog-api-db_01-${var.build-version}.dev"
  ports {
    internal = "5432"
    external = "5432"
  }

  networks = ["catalog-service-network"]
  command = ["supervisord", "-n"]

  provisioner "local-exec" {
    command =<<ENV
docker exec -t ${self.name} /bin/bash -c 'echo "\
CATALOG_API_DATABASE=\"${var.catalogapi_database}\"
CATALOG_API_DBSCHEMA=\"${var.catalogapi_dbschema}\"
CATALOG_API_DBUSER=\"${var.catalogapi_dbuser}\"
CATALOG_API_DBPASSWORD=\"${var.catalogapi_dbpassword}\"" | tee -a /tmp/db.env'
ENV
  }

  provisioner "local-exec" {
    command = "docker cp ./scripts/init_database ${self.name}:/tmp/"
  }

  provisioner "local-exec" {
    command = "docker exec -t ${self.name} /bin/bash -c 'chmod ug+x /tmp/init_database && /tmp/init_database && rm /tmp/db.env && rm /tmp/init_database'"
  }
}
