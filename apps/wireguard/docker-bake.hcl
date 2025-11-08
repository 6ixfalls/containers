target "docker-metadata-action" {}

variable "APP" {
  default = "wireguard"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_22/wireguard-tools versioning=loose
  default = "1.0.20250521-r0"
}

variable "IPTABLES_VERSION" {
  // renovate: datasource=repology depName=alpine_3_22/iptables versioning=loose
  default = "1.8.11-r1"
}

variable "SOURCE" {
  default = "https://www.wireguard.com/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    IPTABLES_VERSION = "${IPTABLES_VERSION}"
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