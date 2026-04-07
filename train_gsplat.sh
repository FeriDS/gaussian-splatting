#!/bin/bash
#SBATCH --job-name=gsplat_train
#SBATCH --output=logs/train_%j.out
#SBATCH --error=logs/train_%j.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --gpus=1
#SBATCH --partition=normal-a100-40        # Use production partition
#SBATCH --account=F202500006HPCVLABUALGG
#SBATCH --qos=gpu

mkdir -p logs

echo "========================================="
echo "Job started at: $(date)"
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "========================================="

# Paths
CONTAINER="/projects/F202500006HPCVLABUALG/fuwuri/gauss/gaussian-splatting/gaussian_v2.sif"
PROJECT="/projects/F202500006HPCVLABUALG/fuwuri/gauss/gaussian-splatting"
DATASET="/projects/F202500006HPCVLABUALG/fuwuri/gauss/gaussian-splatting/data/tandt/train"
OUTPUT="/projects/F202500006HPCVLABUALG/fuwuri/gauss/gaussian-splatting/output/tandt_output"
VENV="/projects/F202500006HPCVLABUALG/fuwuri/.venv"

mkdir -p $OUTPUT

singularity exec --nv \
    --bind $PROJECT:/gaussian-splatting \
    --bind $DATASET:/dataset \
    --bind $OUTPUT:/output \
    --bind $VENV:/venv \
    $CONTAINER \
    bash -c "
        # Activate virtual environment
        source /venv/bin/activate
        
        # Quick verification (optional)
        python -c '
import numpy, cv2, torch
print(f\"NumPy: {numpy.__version__}\")
print(f\"OpenCV: {cv2.__version__}\")
print(f\"PyTorch: {torch.__version__}\")
print(f\"CUDA: {torch.cuda.is_available()}\")
from diff_gaussian_rasterization import GaussianRasterizer
print(\"All modules ready!\")
'
        
        cd /gaussian-splatting
        
        echo 'Starting training...'
        python train.py \
            -s /dataset \
            -m /output \
            --eval \
            --iterations 30000 \
            --save_iterations 7000 30000 \
            --checkpoint_iterations 7000 30000 \
            --lambda_dssim 0.2
    "

echo "========================================="
echo "Job completed at: $(date)"
echo "========================================="
