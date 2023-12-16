#!/bin/bash

nano /home/debian/server/config.cfg
echo "temppwd" | sudo -S kill -s SIGUSR1 "$(cat /tmp/cotti_server_id)"
