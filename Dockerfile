ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create and use the Python venv
RUN python3 -m venv --system-site-packages /venv

# Clone the git repo of SUPIR
ARG SUPIR_COMMIT
WORKDIR /
RUN git clone https://github.com/ashleykleynhans/SUPIR.git

# Install the dependencies for SUPIR
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
WORKDIR /SUPIR
ENV TORCH_INDEX_URL=${INDEX_URL}
ENV TORCH_COMMAND="pip install torch==${TORCH_VERSION} torchvision --index-url ${TORCH_INDEX_URL}"
ENV XFORMERS_PACKAGE="xformers==${XFORMERS_VERSION} --index-url ${TORCH_INDEX_URL}"
RUN source /venv/bin/activate && \
    ${TORCH_COMMAND} && \
    pip3 install -r requirements.txt && \
    pip3 install ${XFORMERS_PACKAGE} &&  \
    deactivate

# Create model directory
RUN mkdir -p /SUPIR/models

# Add SDXL CLIP2 model
ADD https://huggingface.co/laion/CLIP-ViT-bigG-14-laion2B-39B-b160k/resolve/main/open_clip_pytorch_model.bin /SUPIR/models/open_clip_pytorch_model.bin

# Add Base SDXL model - Juggernaut has issues with eyes
ADD https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0_0.9vae.safetensors /SUPIR/models/sd_xl_base_1.0_0.9vae.safetensors

# Add SUPIR F model
ADD https://huggingface.co/ashleykleynhans/SUPIR/resolve/main/SUPIR-v0F.ckpt /SUPIR/models/SUPIR-v0F.ckpt

# Add SUPIR Q model
ADD https://huggingface.co/ashleykleynhans/SUPIR/resolve/main/SUPIR-v0Q.ckpt /SUPIR/models/SUPIR-v0Q.ckpt

# Download additional models
ARG LLAVA_MODEL
ENV LLAVA_MODEL=${LLAVA_MODEL}
ENV HF_HOME="/"
COPY --chmod=755 scripts/download_models.py /download_models.py
RUN source /venv/bin/activate && \
    pip3 install huggingface_hub && \
    python3 /download_models.py && \
    deactivate

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
