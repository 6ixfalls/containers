target "docker-metadata-action" {}

variable "APP" {
  default = "spamassassin"
}

variable "VERSION" {
  // renovate: datasource=repology depName=alpine_3_23/spamassassin versioning=loose
  default = "4.0.2-r0"
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
