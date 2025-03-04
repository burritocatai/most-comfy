#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

cd /comfyui

TARGET_DIR="/comfyui/ComfyUI/custom_nodes"

clone_repo() {
    repo_url=$1
    
    # Extract repo name from URL (works with both HTTPS and SSH URLs)
    if [[ $repo_url =~ .*/.*/(.*)\.git$ ]]; then
        repo_name=${BASH_REMATCH[1]}
    elif [[ $repo_url =~ .*/(.*)$ ]]; then
        repo_name=${BASH_REMATCH[1]}
    else
        # If we can't extract a name, use a timestamp
        repo_name="custom_repo_$(date +%s)"
    fi
    
    echo "Cloning repository: $repo_url to $TARGET_DIR/$repo_name"
    
    # Clone the repository
    if git clone "$repo_url" "$TARGET_DIR/$repo_name"; then
        echo "Successfully cloned $repo_url"
    else
        echo "Failed to clone $repo_url"
    fi
}

# Check if COMFYUI_VERSION environment variable is set
if [ -z "$COMFYUI_VERSION" ]; then
    echo "No version of Comfy UI specified (COMFYUI_VERSION environment variable is empty)"
    exit 0
fi

git clone --branch ${COMFYUI_VERSION} https://github.com/comfyanonymous/ComfyUI

cd /comfyui/ComfyUI

pip3 install -r "requirements.txt"

echo "checking missing nodes requirements"

# Check if COMFYUI_VERSION environment variable is set
if [ -z "$COMFYUI_NODE_MANAGER" ]; then
    echo "Node Manager not specified. Not installing"
else 
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
fi

# Create custom_nodes directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# First check if a repository list URL is provided
if [ -n "$NODES_REPOS" ]; then
    echo "Downloading repository list from $NODES_REPOS"
    TEMP_REPOS_FILE="/tmp/repos.txt"
    
    # Download the file
    if curl -s -o "$TEMP_REPOS_FILE" "$NODES_REPOS"; then
        echo "Successfully downloaded repository list"
        
        # Process each line in the downloaded file
        while IFS= read -r repo || [ -n "$repo" ]; do
            # Skip empty lines and comments
            if [ -z "$repo" ] || [[ "$repo" =~ ^# ]]; then
                continue
            fi
            # Trim whitespace
            repo=$(echo "$repo" | xargs)
            if [ -n "$repo" ]; then
                clone_repo "$repo"
            fi
        done < "$TEMP_REPOS_FILE"
    else
        echo "Failed to download repository list from $NODES_REPOS"
    fi
# Fallback to CUSTOM_NODES_REPOS environment variable if NODES_REPOS is not provided
elif [ -n "$CUSTOM_NODES_REPOS" ]; then
    echo "Using repositories from CUSTOM_NODES_REPOS environment variable"
    # Split the comma-separated list and process each repository
    IFS=',' read -ra REPOS <<< "$CUSTOM_NODES_REPOS"
    for repo in "${REPOS[@]}"; do
        # Trim whitespace
        repo=$(echo "$repo" | xargs)
        if [ -n "$repo" ]; then
            clone_repo "$repo"
        fi
    done
else
    echo "No custom nodes specified (neither NODES_REPOS nor CUSTOM_NODES_REPOS are set)"
fi

for dir in /comfyui/ComfyUI/custom_nodes/*/; do
    if [ -f "$dir/requirements.txt" ]; then
        echo "Installing requirements in $dir"
        pip3 install -r "$dir/requirements.txt"
    fi
done

echo "Starting comfyui"

python3 main.py \
    --listen 0.0.0.0 \
    --port ${COMFY_UI_PORT:-8082}
sleep infinity