#!/bin/bash

export user="debian"                           # Beaglebone user
export password="temppwd"                      # Beagleboen sudo password
export ip="192.168.7.2"                        # Beaglebone IP
export driver_path="/home/${user}/driver/"     # Installation path for the driver
export server_path="/home/${user}/server/"
export server_pid_path="/tmp/cotti_server_id"
export module_name="temp_sensor"

source scripts/menu_options.sh

echo "What to do?"
echo "1. Compile kernel module"
echo "2. Install kernel module"
echo "3. Remove kernel module"
echo "4. Read temperature"
echo "5. Give internet to the BBB"
echo "6. Open an interative terminal on the beaglebone"
echo "7. Compile server"
echo "8. Execute server"
echo "9. Modify server's config file"
echo "a. Full install and run server"
echo "q. Quit"

read -p "Select option: " -r -n 1 option
echo ""

case $option in
1) {
    compile_driver
};;
2) {
    install_module
};;
3) {
    remove_module
};;
4) {
    read_temperature
};;
5) {
    internet_over_usb
};;
6) {
    interactive_terminal
};;
7) {
    compile_server
};;
8) {
    execute_server
};;
9) {
    modify_config_file
};;
a) {
    full_install_and_exe
};;
*) {
    echo "Leaving"
    exit 0
};;
esac
