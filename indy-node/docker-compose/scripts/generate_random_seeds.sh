#!/bin/bash

echo -e "[...]\t storing random seeds in .node.env"
echo "INDY_NODE_SEED=$(head -c 32 /dev/random | base64 | head -c 32)" > .node.env
echo -e "[OK]\t done"
