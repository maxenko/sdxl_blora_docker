#!/bin/bash

wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors?download=true
mv sd_xl_base_1.0.safetensors?download=true sd_xl_base_1.0.safetensors

# Clone the repositories
git clone --recursive https://github.com/bmaltais/kohya_ss.git
git clone https://github.com/maxenko/sdxl_blora_docker

# Copy all contents from sdxl_blora_docker to kohya_ss, overwriting any existing files
cp -r sdxl_blora_docker/* kohya_ss/
rm -rf sdxl_blora_docker

# Change directory to kohya_ss and build the Docker image
cd kohya_ss
docker build -t kohya_blora:latest .
docker run -d --gpus all -p 7860:7860 -p 8081:8081 --name blora_trainer --shm-size=1g kohya_blora
docker cp sd_xl_base_1.0.safetensors blora_trainer:/dataset/base_models/sd_xl_base_1.0.safetensors
#rm sd_xl_base_1.0.safetensors
