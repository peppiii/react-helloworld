#!/usr/bin/env bash

set -e
set -o pipefail

if [ $# -eq 0 ]
  then
    echo "Usage: build.sh [branch]"
    exit 1
fi

npm install && npm run build $1 && ls -all 

#before running gsutil
export BOTO_CONFIG=/dev/null 

## to folder bucket
cd build && ls -all && gsutil cp -r * gs://project-app-$1

## perfomance 
gsutil -m setmeta -h "Cache-Control:public, max-age=31536000, no-cache" -h "Content-Type: text/css" -h "Content-Encoding:application/gzip" -r gs://project-app-$1/static/css/*

gsutil -m setmeta -h "Cache-Control:public, max-age=31536000, no-cache" -h "Content-Type: application/javascript" -h "Content-Encoding:application/gzip" -r gs://project-app-$1/static/js/*

gsutil -m setmeta -h "Cache-Control:public, max-age=31536000, no-cache" -h "Content-Type: image/png" -h "Content-Encoding:application/gzip" -r gs://project-app-$1/static/media/*.png

gsutil -m setmeta -h "Cache-Control:public, max-age=31536000, no-cache" -h "Content-Type: image/jpg" -h "Content-Encoding:application/gzip" -r gs://project-app-$1/static/media/*.jpg 
 

