#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Create a downloads directory
mkdir -p ~/downloads
cd ~/downloads

# Download and install Anaconda
ANACONDA_INSTALLER=Anaconda3-2024.06-1-Linux-x86_64.sh
wget https://repo.anaconda.com/archive/$ANACONDA_INSTALLER
bash $ANACONDA_INSTALLER -b -p $HOME/anaconda3

# Initialize Anaconda
eval "$($HOME/anaconda3/bin/conda shell.bash hook)"

# Reload shell
source ~/.bashrc

conda init

# Create a new Conda environment named 'torch' with Python 3.10
conda create -n torch python=3.10 -y

# Activate the new environment
conda activate torch

# Install PyTorch with CUDA support
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia


# Create a test script to verify GPU support
cat <<EOF > test_torch_gpu.py
import torch

def main():
    if torch.cuda.is_available():
        print("CUDA is available. PyTorch version:", torch.__version__)
        print("GPU:", torch.cuda.get_device_name(0))
        x = torch.rand(5, 3).cuda()
        print("Tensor on GPU:", x)
    else:
        print("CUDA is not available. Please check your CUDA installation.")

if __name__ == "__main__":
    main()
EOF

# Run the test script
python test_torch_gpu.py

echo "Deep learning environment setup is complete."
echo "To activate the 'torch' environment, use: conda activate torch"


# Install duf
ARCHITECTURE=$(lscpu | grep Architecture | awk '{print $2}')
DUF_VERSION="0.6.2"

if [ "$ARCHITECTURE" == "x86_64" ]; then
    DUF_PACKAGE="duf_${DUF_VERSION}_linux_amd64.deb"
elif [ "$ARCHITECTURE" == "i386" ] || [ "$ARCHITECTURE" == "i686" ]; then
    DUF_PACKAGE="duf_${DUF_VERSION}_linux_386.deb"
else
    DUF_PACKAGE="duf_${DUF_VERSION}_linux_${ARCHITECTURE}.deb"
fi

curl -LO https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/${DUF_PACKAGE}
sudo dpkg -i ${DUF_PACKAGE}

# Verify duf installation
duf --version

echo "duf has been installed. Run 'duf' to view disk usage information."
