target "docker-metadata-action" {}

variable "APP" {
  default = "m3u-editor"
}

variable "VERSION" {
  // renovate: datasource=docker depName=sparkison/m3u-editor
  default = "0.11.69"
}

variable "SOURCE" {
  default = "https://github.com/m3ue/m3u-editor"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
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
