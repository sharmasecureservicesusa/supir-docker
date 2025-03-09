variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "sharmasecureservicesusa"
}

variable "APP" {
    default = "supir"
}

variable "RELEASE" {
    default = "1.0.0"
}


target "supir" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}"]
  args = {
        RELEASE = "${RELEASE}"
        XFORMERS_VERSION = "0.0.27"
        SUPIR_COMMIT = "4f35aec759de3176fd4675db61ea986c846c1ddf"
        LLAVA_MODEL = "liuhaotian/llava-v1.5-7b"
    }
}
