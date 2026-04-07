#!/usr/bin/env python
import sys
import os

# Add packages directory to path
packages_path = '/gauss/packages'
if os.path.exists(packages_path):
    sys.path.insert(0, packages_path)
    print(f"Added {packages_path} to Python path")

import torch
print(f"PyTorch: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"CUDA version: {torch.version.cuda}")

print("\n" + "="*50)
print("Importing Gaussian Splatting modules...")
print("="*50)

# CORRECT IMPORT NAMES:
try:
    from diff_gaussian_rasterization import GaussianRasterizer
    print("✓ diff_gaussian_rasterization imported")
except ImportError as e:
    print(f"✗ diff_gaussian_rasterization: {e}")

try:
    import simple_knn
    print("✓ simple_knn imported")
except ImportError as e:
    print(f"✗ simple_knn: {e}")

try:
    import fused_ssim
    print("✓ fused_ssim imported")
except ImportError as e:
    print(f"✗ fused_ssim: {e}")

print("\n" + "="*50)
print("Test completed successfully!")
print("="*50)
