target "docker-metadata-action" {}

variable "APP" {
  default = "bird2"
}

variable "VERSION" {
  // renovate: datasource=repology depName=debian_13/bird2 versioning=loose
  default = "2.17.1-1"
}

variable "SOURCE" {
  default = "https://github.com/CZ-NIC/bird"
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