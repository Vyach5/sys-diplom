#!/bin/bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export YC_SSH_KEY=$(cat /home/vyach/sys-diplom/keys/yc_vm_key.pub)
echo "TOKEN: $YC_TOKEN"
echo "CLOUD: $YC_CLOUD_ID"
echo "FOLDER: $YC_FOLDER_ID"
echo "SSH_KEY: $YC_SSH_KEY"
