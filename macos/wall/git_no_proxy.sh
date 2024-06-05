#!/bin/bash

echo "unset git global proxy"
git config --global --unset http.proxy 
git config --global --unset https.proxy
echo "unset git done"