#!/bin/bash
#SBATCH --job-name=install_gsplat
#SBATCH --output=logs/install_%j.out
#SBATCH --error=logs/install_%j.err
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gpus=1
#SBATCH --partition=dev-a100-40
#SBATCH --account=F202500006HPCVLABUALGG
#SBATCH --qos=gpu

mkdir -p logs

echo "========================================="
echo "Installation started at: $(date)"
echo "========================================="

# Paths
CONTAINER="/projects/F202500006HPCVLABUALG/fuwuri/gauss/gaussian-splatting/gaussian_v2.sif"
PROJECT="/projects/F202500006HPCVLABUALG/fuwuri/gauss/gaussian-splatting"
VENV="/projects/F202500006HPCVLABUALG/fuwuri/.venv"

# Remove old venv
rm -rf $VENV
mkdir -p $VENV

# Run the installation inside the container
singularity exec --nv \
    --bind $PROJECT:/gaussian-splatting \
    --bind $VENV:/venv \
    $CONTAINER \
    bash << 'EOF'
set -e  # exit on error

echo "Creating virtual environment..."
python -m venv /venv --system-site-packages

source /venv/bin/activate

# Upgrade pip
pip install --upgrade pip

echo "Installing NumPy 1.x..."
pip install --no-cache-dir numpy==1.26.4

echo "Installing opencv-python 4.8.1 (compatible with NumPy 1.x)..."
pip install --no-cache-dir opencv-python==4.8.1.78

echo "Installing other dependencies..."
pip install --no-cache-dir pillow==10.0.0 tqdm==4.66.1

echo "Installing Gaussian Splatting submodules..."
cd /gaussian-splatting-inria

pip install --no-cache-dir --no-deps --no-build-isolation submodules/diff-gaussian-rasterization
pip install --no-cache-dir --no-deps --no-build-isolation submodules/simple-knn
pip install --no-cache-dir --no-deps --no-build-isolation submodules/fused-ssim

echo "Verifying installed versions..."
python << 'PYEOF'
import numpy
import cv2
print(f"NumPy version: {numpy.__version__}")
print(f"OpenCV version: {cv2.__version__}")
PYEOF

echo "Testing imports..."
python << 'PYEOF'
import numpy
import torch
print(f"✓ NumPy: {numpy.__version__}")
print(f"✓ PyTorch: {torch.__version__}")
print(f"✓ CUDA: {torch.cuda.is_available()}")

from diff_gaussian_rasterization import GaussianRasterizer
import simple_knn
import fused_ssim
print("✓ All Gaussian Splatting modules loaded!")
PYEOF

echo ""
echo "Installed packages:"
pip list | grep -E "numpy|opencv|pillow|tqdm"

touch /venv/.full_installed
echo "Installation complete!"
EOF

echo "========================================="
echo "Installation completed at: $(date)"
echo "========================================="
