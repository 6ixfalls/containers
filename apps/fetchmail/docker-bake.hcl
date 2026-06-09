target "docker-metadata-action" {}

variable "APP" {
  default = "fetchmail"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/fetchmail versioning=loose
  default = "6.6.1-r0"
}

variable "OPENSSL_VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/openssl versioning=loose
  default = "3.5.6-r0"
}

variable "LOGROTATE_VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/logrotate versioning=loose
  default = "3.22.0-r0"
}

variable "TINI_VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/tini versioning=loose
  default = "0.19.0-r3"
}

variable "SOURCE" {
  default = "https://www.fetchmail.info/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    OPENSSL_VERSION = "${OPENSSL_VERSION}"
    LOGROTATE_VERSION = "${LOGROTATE_VERSION}"
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
