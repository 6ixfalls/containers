target "docker-metadata-action" {}

variable "APP" {
  default = "snmpd"
}

variable "VERSION" {
  // renovate: datasource=repology depName=ubuntu_24_04/net-snmp versioning=loose
  default = "5.9.4+dfsg-1.1ubuntu3.2"
}

variable "SOURCE" {
  default = "https://github.com/net-snmp/net-snmp"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}