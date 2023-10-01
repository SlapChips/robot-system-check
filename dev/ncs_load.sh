#!/bin/bash

# Set the path to the CLI application and its options
APP_COMMAND="ncs_cli -C -u ncsadmin"

# Define the command you want to pass as an argument
CMD="$1"

# Run the CLI application and pass the commands
$APP_COMMAND << EOF
config terminal
load merge $CMD
commit dry-run
exit
EOF
