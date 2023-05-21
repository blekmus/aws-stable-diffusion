sudo apt update && sudo apt upgrade
sudo apt install aria2

===== ephemeral.sh
#!/bin/bash

/usr/sbin/mkfs.ext4 /dev/nvme1n1
/usr/bin/mkdir -p /mnt/ephemeral
/usr/bin/mount /dev/nvme1n1 /mnt/ephemeral
/usr/bin/chmod 777 /mnt/ephemeral
dd if=/dev/zero of=/mnt/ephemeral/swapfile bs=1G count=8
chmod 600 /mnt/ephemeral/swapfile
mkswap /mnt/ephemeral/swapfile
swapon /mnt/ephemeral/swapfile
=====

# setup working storage
sudo ./ephemeral.sh

# not needed for Deep Learning AMI
# setup CUDA drivers
# https://developer.nvidia.com/cuda-downloads
# wget https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda_12.1.1_530.30.02_linux.run

sudo apt install python3.8-venv

# not sure if this is needed
# sudo apt install python3-virtualenv

# install SD webui
bash <(wget -qO- https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh)

# generation complete sound
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://cdn.pixabay.com/download/audio/2022/03/24/audio_2c8cd2cdbd.mp3?filename=wheep-wheep-101146.mp3 -d stable-diffusion-webui -o notification.mp3

# themes
git clone "https://github.com/canisminor1990/sd-web-ui-kitchen-theme" stable-diffusion-webui/extensions/kitchen-theme

# extensions
#git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser stable-diffusion-webui/extensions/images-browser
git clone https://github.com/zanllp/sd-webui-infinite-image-browsing stable-diffusion-webui/extensions/infinite-image-browser
git clone https://github.com/alemelis/sd-webui-ar stable-diffusion-webui/extensions/aspect-ratio
git clone https://github.com/ilian6806/stable-diffusion-webui-state stable-diffusion-webui/extensions/state
git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git stable-diffusion-webui/extensions/tag-autocomplete
git clone https://github.com/richrobber2/canvas-zoom stable-diffusion-webui/extensions/canvas-zoom
git clone https://github.com/Coyote-A/ultimate-upscale-for-automatic1111 stable-diffusion-webui/extensions/ultimate-upscale

# embeddings
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://civitai.com/api/download/models/49129 -d stable-diffusion-webui/embeddings/ -o AID28.pt
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://civitai.com/api/download/models/60938 -d stable-diffusion-webui/embeddings/ -o NegativeHand.pt
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/datasets/gsdf/EasyNegative/resolve/main/EasyNegative.pt -d stable-diffusion-webui/embeddings/ -o EasyNegative.pt
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://civitai.com/api/download/models/20068 -d stable-diffusion-webui/embeddings/ -o badhandv4.pt
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://civitai.com/api/download/models/66043 -d stable-diffusion-webui/embeddings/ -o BadPictures.pt

# models
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://civitai.com/api/download/models/46137 -d stable-diffusion-webui/models/Stable-diffusion -o meinamix_meinaV9.safetensors

# ControlNet v1.1
git clone https://github.com/Mikubill/sd-webui-controlnet stable-diffusion-webui/extensions/controlnet
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11e_sd15_ip2p.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11e_sd15_ip2p.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11e_sd15_shuffle.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11e_sd15_shuffle.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11f1e_sd15_tile.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11f1p_sd15_depth.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_canny.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_inpaint.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_lineart.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_mlsd.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_mlsd.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_normalbae.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_normalbae.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_openpose.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_scribble.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_scribble.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_seg.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_seg.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_softedge.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15_softedge.pth
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15s2_lineart_anime.pth -d stable-diffusion-webui/extensions/controlnet/models -o control_v11p_sd15s2_lineart_anime.pth
