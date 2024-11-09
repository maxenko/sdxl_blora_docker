## What does this do?
It helps you train B-LoRAs in a docker container. B-LoRAs are a method to split style from content of a stable diffusion network. To read more about it visit:

https://b-lora.github.io/B-LoRA/

https://github.com/yardenfren1996/B-LoRA

https://github.com/ThereforeGames/blora_for_kohya (base for this repo)


## Purpose of this repo

This repo is a based of original https://github.com/ThereforeGames/blora_for_kohya with some additional scripts that make it easier to train using Docker. I've modified Dockerfile that came with https://github.com/bmaltais/kohya_ss, and added FileBrowser service (handy for cloud hosted training). I've also changed the structure of how the projects are laid out. Other than that, if you used kohya with scripts before, there isn't anything new here.

#### Contributions

If you want to add something to this repo via pull request, please stick with the idiomacy of existing system, don't change it. If you need to change it just roll your own fork.

## Directions (localhost)

```
git clone --recursive https://github.com/bmaltais/kohya_ss.git
```

```
git clone https://github.com/maxenko/sdxl_blora_docker
```

Copy contents of `sdxl_blora_docker` to your `kohya_ss` (root) dir.

Direct your terminal to kohya_ss dir, and build the Docker image:
```
docker build -t kohya_blora:latest .
```

Start the container:
```
docker run --gpus all -p 7860:7860 -p 8081:8081 --name blora_trainer --shm-size=1g -v c:/my_training_data:/dataset kohya_blora
```

Modify `c:/my_training_data` to point to your data dir.

Kohya interface is on:
http://localhost:7860

Filebrowser is on:
http://localhost:8081 (and points to root)

You can manage your data in `/dataset` mount.

The layout of the dataset dir is:

```
base_models/
    sd_xl_base_1.0.safetensors
projects/
    my_project/
        output_01/
            my_project_01-000001.safetensors
            my_project_01-000002.safetensors
            ...
            my_project_01-100000.safetensors
        set_01/
            img01.png
            img02.png
            ...
            imgXX.png
        config.toml
        train.sh
```

You'll need to download the base SDXL model.

https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/blob/main/sd_xl_base_1.0.safetensors

Examine config.toml, you'll need to modify it for your project.
`train.sh` also has some settings you can modify (like Rank) per project.


## Directions (cloud)

Just run `docker-extra/install_and_run.sh`, pico and paste, then chmod +x.

#### To train:

Terminal into the container:

```
docker exec -it blora_trainer /bin/bash
```

Navigate to your project (assuming you've uploaded it through Filebrowser)

```
cd /dataset/projects/my_project
chmod +x train.sh
./train.sh
```

or if you want to run detached:

```
docker exec -d blora_trainer /bin/bash -c /dataset/projects/my_project/train.sh
```

#### After training
After you've trained your LoRA for sufficient amount of steps, you still need to split it into either Style or Content (or other) type. Original repo (https://github.com/ThereforeGames/blora_for_kohya) has directions on how to do this.
But in short, modify an existing split.sh file to your needs and run it on your LoRA checkpoint.

```
todo: need to make .sh versions of slicer .bat files and locilize to project dir
```

## Performance expectations / Tips
The biggest speed limitation is the VRAM IO. Watch your GPU stats for Copy operations, ideally you want these at 0.

I am getting 1.01s/it on an overclocked RTX3090 with 86 images and network rank of 256, with 50% of VRAM usage. Increasing the rank will increase VRAM usage and output lora file size, as well as potentially slowing the training down to a crawl due to constantly copying data in/out of VRAM if you exceed your capacity.

Training takes a while, but depends on your parameters and dataset size. If you're not seeing any effect from your style LoRA, try upping the LoRA weight to something like 2.5. If you have to do this, you probably want to train longer.
Use `DPM++ SDE Karras` to test. This is the only sampler and scheduler combo I've used.
These LoRAs work well with Turbo and Lightning models, so 4-7 steps with Scale of 1.0-3.0 are good starting points.
