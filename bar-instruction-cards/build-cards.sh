#!/bin/bash
# Batch export instruction cards to 3MF format
# Usage: ./build-cards.sh

# Exit on error
set -e

# Find OpenSCAD executable (macOS or Linux/PATH)
if [ -f "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" ]; then
    OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
elif command -v openscad &> /dev/null; then
    OPENSCAD="openscad"
else
    echo "Error: OpenSCAD not found"
    echo "Install OpenSCAD.app or add openscad to your PATH"
    exit 1
fi

echo "Using OpenSCAD at: $OPENSCAD"

# Create output directory
mkdir -p output

# Find and export all card-*.scad files
card_count=0
for card_file in card-*.scad; do
    if [ -f "$card_file" ]; then
        # Extract base name without extension
        base_name="${card_file%.scad}"
        output_name="${base_name#card-}"
        
        echo "Exporting ${output_name}..."
        "$OPENSCAD" -o "output/${output_name}.3mf" \
            -O export-3mf/color-mode=model \
            -O export-3mf/material-type=color \
            "$card_file"
        ((card_count++))
    fi
done

if [ $card_count -eq 0 ]; then
    echo "No card-*.scad files found"
    exit 1
fi

echo "Done! Exported $card_count card(s) to output/ directory"
