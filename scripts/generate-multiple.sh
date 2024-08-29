#!/bin/bash

# Directory containing the files
directory="./assets/flows"

# Initialize the command variable
#command="go run ./ validate"
command="go run ./ generate -o ./testoutput"

# Loop through all files in the directory
for file in "$directory"/*.json; do
  # Add each file as a parameter
  command+=" -e \"$file\""
done

# Execute the command
eval $command