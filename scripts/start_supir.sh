#!/usr/bin/env bash

echo "Starting SUPIR without GPU Optimization"

source /venv/bin/activate
export HF_HOME="/workspace"
export PYTHONUNBUFFERED=1
cd /workspace/SUPIR

nohup python3 gradio_demo.py \
            --ip 0.0.0.0 \
            --port 3001 \
            --use_image_slider > /workspace/logs/supir.log 2>&1 &

deactivate
