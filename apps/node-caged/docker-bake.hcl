target "docker-metadata-action" {}

variable "APP" {
  default = "node-caged"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=nodejs/node versioning=node extractVersion=^v(?<version>.+)$
  default = "25.7.0"
}

variable "YARN_VERSION" {
  // renovate: datasource=github-tags depName=yarnpkg/yarn extractVersion=^v(?<version>.+)$
  default = "1.22.22"
}

variable "SOURCE" {
  default = "https://github.com/nodejs/node"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION      = "${VERSION}"
    YARN_VERSION = "${YARN_VERSION}"
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
