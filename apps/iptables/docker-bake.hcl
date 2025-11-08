target "docker-metadata-action" {}

variable "APP" {
  default = "iptables"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_22/iptables versioning=loose
  default = "1.8.11-r1"
}

variable "SOURCE" {
  default = "https://www.netfilter.org/projects/iptables/index.html"
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