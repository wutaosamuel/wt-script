#!/bin/bash

echo "set git global proxy"
git config --global http.proxy http://127.0.0.1:1087
git config --global https.proxy http://127.0.0.1:1087
echo "set git done"