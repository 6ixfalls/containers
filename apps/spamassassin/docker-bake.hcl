target "docker-metadata-action" {}

variable "APP" {
  default = "spamassassin"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/spamassassin versioning=loose
  default = "4.0.2-r0"
}

variable "SUPERCRONIC_VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/supercronic versioning=loose
  default = "0.2.39-r6"
}

variable "TINI_VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/tini versioning=loose
  default = "0.19.0-r3"
}

variable "SOURCE" {
  default = "https://github.com/apache/spamassassin"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SUPERCRONIC_VERSION = "${SUPERCRONIC_VERSION}"
    TINI_VERSION = "${TINI_VERSION}"
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
