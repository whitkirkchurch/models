# Bar Instruction Cards

Parametric A6-sized instruction cards designed for flush-filled multi-color 3D printing. Create durable, professional-looking instruction cards with text inlaid into the surface.

## Features

- **Parametric design**: All dimensions configurable
- **Flush-filled text**: Text sits perfectly flush with the card surface
- **Multi-color support**: Exports 3MF with color information for Bambu Studio and other slicers
- **Batch processing**: Automatically export all cards with one command
- **Easy content management**: Text stored in simple `.scad` files

## Project Structure

```
bar-instruction-cards/
├── instruction-card.scad      # Template with geometry and parameters
├── card-staff-drinks.scad     # Example: Staff drinks instructions
├── card-cleaning.scad         # Example: Cleaning instructions
├── build-cards.sh             # Batch export script
└── output/                    # Generated 3MF files
```

## Quick Start

1. **Edit or create a card**:
   ```scad
   // card-mycard.scad
   card_title = "MY CARD";
   body_lines = [
       "Line 1",
       "Line 2",
       "",  // Empty line for spacing
       "Line 3"
   ];
   include <instruction-card.scad>
   ```

2. **Export all cards**:
   ```bash
   ./build-cards.sh
   ```

3. **Import to slicer**: Open the generated 3MF file in Bambu Studio (or similar)
   - Base card will be white
   - Text will be black
   - Both colors are preserved in the 3MF

## Creating New Cards

1. Create a new file following the naming pattern: `card-[name].scad`
2. Define your content using two variables:
   - `card_title` - heading text (right-aligned, top corner)
   - `body_lines` - array of strings, one per line
3. Include the template: `include <instruction-card.scad>`
4. Run `./build-cards.sh` - it automatically finds all `card-*.scad` files

### Content Example

```scad
// card-kitchen-safety.scad
card_title = "SAFETY";

body_lines = [
    "BEFORE YOU START:",
    "1. Wash your hands",
    "2. Tie back long hair",
    "3. Check equipment",
    "",
    "IN EMERGENCY:",
    "1. Use fire extinguisher",
    "2. Call supervisor"
];

include <instruction-card.scad>
```

## Parameters

All parameters are at the top of `instruction-card.scad` and can be modified to suit your needs.

## Exporting

### Batch Export (Recommended)
```bash
./build-cards.sh
```
Finds all `card-*.scad` files and exports to `output/[name].3mf` with color information.

### Single Card Export
From command line:
```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -o output/my-card.3mf \
  -O export-3mf/color-mode=model \
  -O export-3mf/material-type=color \
  card-my-card.scad
```

From OpenSCAD GUI:
1. Open `card-*.scad` in OpenSCAD
2. File → Export → Export as 3MF

## 3D Printing

### Recommended Settings
- **Material**: PLA or PETG
- **Layer height**: 0.2mm
- **Infill**: 100% (solid card)
- **Colors**: White base + Black text (or your choice)

### Printing Process

#### Option 1: Automatic Color Change (Bambu Studio/OrcaSlicer)
1. Import the 3MF file
2. The slicer should recognize the two colours
3. Assign filaments to each color
4. Print - the printer will automatically switch filaments

#### Option 2: Manual Filament Swap
1. Import the 3MF file as a single object
2. Add a pause at layer 6 (1.0mm height)
3. Start printing in white
4. When paused, swap to black filament
5. Resume printing

### Post-Processing
No post-processing needed - text is flush with the surface and cards are ready to use immediately.

## How It Works

The design uses OpenSCAD's `color()` function to create two distinct objects:

1. **Base card** (white): Full-height card with text-shaped voids carved from the top layer
2. **Text layer** (black): Text geometry that fills those voids perfectly

When exported with the correct settings (`-O export-3mf/color-mode=model -O export-3mf/material-type=color`), OpenSCAD preserves these colors in the 3MF file, which modern slicers can read and assign to different filaments.
