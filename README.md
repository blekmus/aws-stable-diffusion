## Running SD Automatic1111 on AWS

The recommended EC2 instance to run SD Automatic1111 WebUI is the g4dn.xlarge instance, which offers a good balance between performance and cost at $0.52 per hour. It provides approximately 1.5 times the inference speed of Google Colab. While not extremely fast, it is sufficient for most purposes. For instance, you can generate a non-hires-fix image at 800x800 resolution in around 10 seconds and a hires-fix image with 2x upscaling for the same resolution in around 2-3 minutes.

### Step 1: Request Quota Increase

1. Go to the [AWS Service Quota](https://us-east-1.console.aws.amazon.com/servicequotas/home/services/ec2/quotas) dashboard (check region).
3. Search for `Running On-Demand G and VT instances` and click on it.
4. Click on `Request Quota Increase` and enter the value `4` into the input box.
5. Click "Request" to submit your quota increase request.

If you plan to use EC2 Spot Instances, you will also need to request a quota increase for "All G and VT Spot Instance Requests" using the same process. Using Spot Instances can be significantly cheaper, however, it comes with the risk of being terminated out of nowhere, there by loosing all of your data.

This quota increase request is necessary because the default maximum number of vCPUs your account can have is 0. By requesting an increase to 4, you can run the g4dn.xlarge instance, which has 4 vCPUs. Just so you know, it may take some time for AWS to review and accept your request. In some cases, they may require additional information or clarification.

### Step 2: Wait for Quota Increase Approval

After submitting your quota increase request, you will need to wait until AWS accepts your request. The approval process may take some time, and you may receive back-and-forth communication from AWS requesting additional information to ensure the request is legitimate. If your request is denied, reply with more information to the support ticket created for the quota increase.

For me personally, this took almost a week of back and forth. AWS repeatedly declined my requests citing "For my safety".

### Step 3: Launching the Instance

Once your quota increase request is approved, you can proceed with launching the g4dn.xlarge instance. You can launch it using one of these two types of instances. I would recommend going with on-demand if you want your generated images to persist indefinitely on the instance.

#### On-Demand

1. Go to the AWS EC2 dashboard and click on "Instances".
2. Click on "Launch Instance" to start the EC2 instance creation process.
3. In the Quick Start section select `Ubuntu` as the AMI.
4. From the dropdown select a `Deep Learning AMI` with the most recent version of `PyTorch`.
5. Choose `g4dn.xlarge` as the instance type.
6. Set the storage to `80gb` (increase if needed).
7. Configure other instance settings such as network, security groups, and key pairs according to your requirements.
8. Proceed to review the configuration and click "Launch" to start the instance.

#### Spot Instance

1. Same as steps 1 to 7 above.
2. Expand into the "Advanced Details" and check `Request Spot Instances`.
3. Click "Customize" next to it and choose `Persistent` from the "Request Type" dropdown.
4. Proceed to review the configuration and click "Launch" to start the instance.

>By default, Spot Instances are launched in `one time` mode. They cannot be stopped when we're done using it. Running them in `Persistent` mode makes it possible to manually boot and stop when necessary.
<br><br>It is recommended to back up Spot instances periodically by selecting the instance from the EC2 dashboard then Actions → Images and Templates → Create Image. This process may take some time (15-30mins). If the instance is now interrupted, you can create a new one without the installation hassle. Keep in mind that you will lose all your data from the previous instance when it is interrupted.

The steps above will launch a g4dn.xlarge instance with the Deep Learning AMI. This AMI is recommended because it already includes the necessary graphics drivers (CUDA) preinstalled. The allocated storage of 80 GB provides sufficient space for installing Stable Diffusion WebUI and the storage cruncher that is ControlNet, with around 15 GB of extra space available.

Attaching a static IP to this instance is recommended. Or else the IP address changes every time the instance is restarted.
    
### Step 4: Installing and Running SD WebUI

Once the instance is launched and running, you can connect to it and install the necessary dependencies to run SD Automatic1111.

``` sh
# install dependencies
sudo apt update && sudo apt upgrade
sudo apt install aria2
sudo apt install python3.8-venv # change python version
```

Next, run the automatic Linux installation script from the [official repo](https://github.com/AUTOMATIC1111/stable-diffusion-webui#automatic-installation-on-linux).

Install themes, extensions, embeddings, models and ControlNet. These are all __optional__.

``` sh
# generation complete sound
aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://cdn.pixabay.com/download/audio/2022/03/24/audio_2c8cd2cdbd.mp3?filename=wheep-wheep-101146.mp3 -d stable-diffusion-webui -o notification.mp3

# theme
git clone "https://github.com/canisminor1990/sd-web-ui-kitchen-theme" stable-diffusion-webui/extensions/kitchen-theme

# extensions
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
```

### Extra Storage

The g4dn.xlarge instance comes with an additional high-performance SSD volume mounted at `/mnt/ephemeral`, providing 125GB (115GB) of temporary storage. Please note that the contents of this volume will be wiped every time the EC2 instance is stopped or restarted. You can run the script below to make use of this temporary storage. This script needs to be run every time the instance is started to keep using the ephemeral volume.

``` bash
#!/bin/bash

/usr/sbin/mkfs.ext4 /dev/nvme1n1
/usr/bin/mkdir -p /mnt/ephemeral
/usr/bin/mount /dev/nvme1n1 /mnt/ephemeral
/usr/bin/chmod 777 /mnt/ephemeral
dd if=/dev/zero of=/mnt/ephemeral/swapfile bs=1G count=8
chmod 600 /mnt/ephemeral/swapfile
mkswap /mnt/ephemeral/swapfile
swapon /mnt/ephemeral/swapfile
```

### Connecting

To establish a secure connection to the WebUI, you can use an SSH tunnel. Run the following command, replacing `ipaddress` with the static IP address of your AWS EC2 instance. This command creates an SSH tunnel that forwards local port 7860 to port 7860 on the remote instance. Adjust the port numbers as necessary based on your configuration. By default, the WebUI runs on port 7860. If you don't see any output from this command don't worry. Unless it fails, it's running.

``` sh
ssh -N -L 7860:127.0.0.1:7860 ubuntu@ipaddress
```

Once the SSH tunnel is established, you can access it by visiting `http://localhost:7860`. Please note that you need to keep the terminal window open with the SSH tunnel running to maintain the connection. If you close the terminal the tunnel will be closed.

### Troubleshooting

If you get `Cannot locate TCMalloc`, at times when changing the current active model. Installing `google-perftools` should solve it.

``` bash
sudo apt install --no-install-recommends google-perftools
```

### Contributions

Inspired by [stable-diffusion-aws](https://github.com/mikeage/stable-diffusion-aws) by [@mikeage](https://github.com/mikeage)

Spot Instance details by [@talyaniv](https://github.com/talyaniv)

