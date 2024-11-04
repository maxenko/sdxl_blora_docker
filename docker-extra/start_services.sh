#!/bin/bash

# Start File Browser on port 8081 in the background
filebrowser -r / --port 8081 & -a 0.0.0.0

# Start the main application
python3 kohya_gui.py --listen 0.0.0.0 --server_port 7860 --headless 