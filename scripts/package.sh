#!/bin/sh
#exit on error
set -e

echo "Ensuring build dir exists"
mkdir -p build

echo "Clearing out previously built packages"
rm -rf build/*.tgz

git_revision=$(git rev-parse HEAD)
echo "git:${git_revision}" > public/version.txt

echo "Packaging...."
tar -zc -f build/aecc-full.tgz --exclude-from=scripts/files_to_exclude.txt .

echo "Done"

