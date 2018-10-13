variable "build-version" {}

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
    command =<<INITDB
docker exec -t ${self.name} /bin/bash -c '\
TIMEOUT=10; while [[ $$TIMEOUT > 0 && `/usr/lib/postgresql/10/bin/pg_isready -d postgres` != 0 ]]; do sleep 1; ((--TIMEOUT)); done;\
echo "CREATE DATABASE catalog_api ENCODING '"'"'UTF-8'"'"' LC_COLLATE '"'"'C.UTF-8'"'"' LC_CTYPE '"'"'C.UTF-8'"'"' TEMPLATE template0;
CREATE USER catalogapi_user WITH ENCRYPTED PASSWORD '"'"'123456'"'"';
GRANT ALL PRIVILEGES ON DATABASE catalog_api TO catalogapi_user;"\
 | su -m postgres_admin -c "/usr/lib/postgresql/10/bin/psql postgres"'
INITDB
  }
}
