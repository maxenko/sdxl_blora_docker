#!/bin/bash

NAME="my_project"
REVISION="01"
PROJECT="${NAME}_${REVISION}"
RANK=128

# Launch the training script
accelerate launch --num_cpu_threads_per_process 8 /app/sd-scripts/sdxl_train_network.py \
    --pretrained_model_name_or_path="/dataset/base_models/sd_xl_base_1.0.safetensors" \
    --dataset_config="/dataset/projects/${NAME}/config.toml" \
    --output_dir="/dataset/projects/${NAME}/output_${REVISION}" \
    --output_name="${PROJECT}" \
    --network_args="preset=/app/lycoris_presets/blora_content_style.toml" \
    --resolution="1024,1024" \
    --save_model_as="safetensors" \
    --network_module="lycoris.kohya" \
    --max_train_steps=60000 \
    --save_every_n_steps=2000 \
    --save_every_n_epochs=1 \
    --network_dim=${RANK} \
    --network_alpha=${RANK} \
    --no_half_vae \
    --gradient_checkpointing \
    --persistent_data_loader_workers \
    --enable_bucket \
    --random_crop \
    --bucket_reso_steps=32 \
    --min_bucket_reso=512 \
    --mem_eff_attn \
    --mixed_precision="fp16" \
    --caption_extension=".txt" \
    --lr_scheduler="cosine" \
    --lr_warmup_steps=500 \
    --network_train_unet_only \
    --prior_loss_weight=0 \
    --optimizer_type="prodigy" \
    --max_grad_norm=1.0 \
    --learning_rate=1.0 \
    --seed=0 \
    --optimizer_args weight_decay=1e-04 betas="(0.9,0.999)" eps=1e-08 decouple=True use_bias_correction=True safeguard_warmup=True beta3=None

# Wait for user input before closing (optional)
read -p "Press enter to continue"
