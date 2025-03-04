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

variable "CU_VERSION" {
    default = "126"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "runpod/base"
}

variable "BASE_IMAGE_VERSION" {
    default = "0.6.2"
}

variable "CUDA_VERSION" {
    default = "12.6.2"
}

variable "TORCH_VERSION" {
    default = "2.3.1"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        BASE_IMAGE = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-cuda${CUDA_VERSION}-torch${TORCH_VERSION}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "${TORCH_VERSION}+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.27"
        SUPIR_COMMIT = "4f35aec759de3176fd4675db61ea986c846c1ddf"
        LLAVA_MODEL = "liuhaotian/llava-v1.5-7b"
    }
}
