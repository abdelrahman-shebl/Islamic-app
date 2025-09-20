#!/bin/bash

sudo apt-get install -y curl tar


sudo apt-get install -y curl tar

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"

tar -xvzf eksctl_$(uname -s)_amd64.tar.gz
sudo mv eksctl /usr/local/bin


eksctl create cluster \
  --name eks-cluster \
  --nodegroup-name eks-nodegroup \
  --node-type t3.micro \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 3 \
  --version 1.31 \
  --region us-east-1