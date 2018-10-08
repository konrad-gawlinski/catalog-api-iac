variable "image" {}
variable "container-name" {}
variable "docker-network-id" {}
variable "internal-port" {}
variable "external-port" {}

resource "docker_container" "dcontainer" {
  image = "${var.image}"
  name  = "${var.container-name}"
  ports {
    internal = "${var.internal-port}"
    external = "${var.external-port}"
  }

  networks = ["${var.docker-network-id}"]
  command = ["supervisord", "-n"]
}
