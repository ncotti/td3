#!/bin/bash

if [ $# -lt 1 ]; then
    echo "No arguments. Using default path."
    install_path=/home/debian/server
else
    install_path="$1"
fi

cd "${install_path}" || exit
make compile
