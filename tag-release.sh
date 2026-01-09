#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <tag>"
    echo "Example: $0 veza-v0.1.24"
    exit 1
fi

TAG="$1"

# Submodule paths for Go modules
SUBMODULES=(
    ""
    "darwin-amd64"
    "darwin-arm64"
    "linux-amd64"
    "linux-arm64"
    "windows-amd64"
)

echo "Creating and pushing tags for version: $TAG"
echo ""

for submod in "${SUBMODULES[@]}"; do
    if [ -z "$submod" ]; then
        # Root module - tag is just the version
        full_tag="$TAG"
        echo "Processing tag: $full_tag (root module)"
    else
        # Submodule - tag is prefixed with submodule path
        full_tag="${submod}/${TAG}"
        echo "Processing tag: $full_tag"
    fi

    # Delete remote tag if exists
    if git ls-remote --tags veza | grep -q "refs/tags/${full_tag}$"; then
        echo "  Deleting remote tag: $full_tag"
        git push veza --delete "$full_tag" || true
    fi

    # Delete local tag if exists
    if git tag -l | grep -q "^${full_tag}$"; then
        echo "  Deleting local tag: $full_tag"
        git tag -d "$full_tag"
    fi

    echo "  Creating tag: $full_tag"
    git tag "$full_tag"
done

echo ""
echo "All tags created. Pushing to veza remote..."
echo ""

for submod in "${SUBMODULES[@]}"; do
    if [ -z "$submod" ]; then
        full_tag="$TAG"
    else
        full_tag="${submod}/${TAG}"
    fi

    echo "Pushing: $full_tag"
    git push veza "$full_tag"
done

echo ""
echo "Done! All tags pushed successfully."