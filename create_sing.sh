# Choose writable locations (home directory is usually safe)
export SINGULARITY_CACHEDIR="$HOME/.singularity_cache"
export SINGULARITY_TMPDIR="$HOME/.singularity_tmp"

# Create the directories if they don't exist
mkdir -p "$SINGULARITY_CACHEDIR" "$SINGULARITY_TMPDIR"

# Now build the container
singularity build --fakeroot test.sif gaussian_splatting.def
