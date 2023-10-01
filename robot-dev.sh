#!/bin/bash


# Change directory to /mnt/vm-shared/robot-dev
cd /mnt/vm-shared/robot-dev


# Debugging output
echo "Current directory: $(pwd)"
echo "Activating virtual environment..."
source "./venv/bin/activate"
echo "Virtual environment activated."



# Export the ROBOT_OPTIONS environment variable
export ROBOT_OPTIONS="--outputdir /mnt/vm-shared/robot-dev/rhel-dev/results/"

# Optionally, you can print a message to indicate that the actions are done
echo "Activated virtual environment and exported ROBOT_OPTIONS."

