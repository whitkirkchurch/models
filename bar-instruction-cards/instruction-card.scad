// Parametric A6 Instruction Card Template
// Generates a plastic card with rounded corners and a mounting hole
//
// This file expects card_title and body_lines to be defined
// Either include this file from a card-specific file, or define them before including

// Layer and thickness parameters
layer_height = 0.2;                           // Height of one print layer in mm
text_layers = 1;                              // Number of layers for text depth
text_depth = text_layers * layer_height;      // Calculated text depth
card_layers = 6;                              // Number of layers for total card thickness
card_thickness = card_layers * layer_height;  // Total thickness/depth of card in mm

// Card dimensions (A6 = 105mm × 148mm)
card_width = 105;        // Width of card in mm
card_height = 148;       // Height of card in mm

// Corner radius
corner_radius = 6;       // Radius of rounded corners in mm

// Hole parameters
hole_diameter = 6;       // Diameter of mounting hole in mm
hole_offset_x = 8;       // Distance from left edge to hole center in mm
hole_offset_y = 8;       // Distance from top edge to hole center in mm

// Text parameters
text_font = "Liberation Sans:style=Bold";     // Font for text
heading_size = hole_diameter;                // Heading text size in mm
body_text_size = 4;                          // Body text size in mm
body_line_spacing = 10;                      // Spacing between body text lines in mm
text_margin = 8;                             // Horizontal and vertical text margin from edges in mm
body_start_y = 2 * hole_offset_y + text_margin;  // Start position for body text from top edge in mm
body_margin_x = text_margin;                 // Left margin for body text in mm

// Resolution (increase for smoother curves, decrease for faster rendering)
$fn = 50;

module rounded_rectangle(width, height, radius) {
    // Create a 2D rounded rectangle using hull of four circles at corners
    hull() {
        // Bottom left
        translate([radius, radius])
            circle(r=radius);
        // Bottom right
        translate([width - radius, radius])
            circle(r=radius);
        // Top right
        translate([width - radius, height - radius])
            circle(r=radius);
        // Top left
        translate([radius, height - radius])
            circle(r=radius);
    }
}

module add_line(text_string, line_number) {
    // Helper module to add a body text line at specified line number (0-indexed)
    translate([body_margin_x, card_height - body_start_y - (line_number * body_line_spacing)]) {
        text(text_string, size=body_text_size, font=text_font, halign="left", valign="center");
    }
}

module text_layer_2d() {
    // All text elements in 2D for the flush-filled text layer
    
    // Card title - right-aligned, same height and offset as hole
    translate([card_width - hole_offset_x, card_height - hole_offset_y]) {
        text(card_title, size=heading_size, font=text_font, halign="right", valign="center");
    }
    
    // Body text lines - iterate through array from card-content.scad
    for (i = [0 : len(body_lines) - 1]) {
        add_line(body_lines[i], i);
    }
}

module base_card() {
    // Base card with text voids for flush filling
    difference() {
        // Full height card body
        linear_extrude(height=card_thickness) {
            rounded_rectangle(card_width, card_height, corner_radius);
        }
        
        // Mounting hole in top left corner
        translate([hole_offset_x, card_height - hole_offset_y, -0.1]) {
            cylinder(h=card_thickness + 0.2, d=hole_diameter);
        }
        
        // Subtract text voids from top surface (exactly text_depth deep)
        translate([0, 0, card_thickness - text_depth]) {
            linear_extrude(height=text_depth) {
                text_layer_2d();
            }
        }
    }
}

module text_layer() {
    // Text geometry to fill the voids (exactly text_depth tall)
    linear_extrude(height=text_depth) {
        text_layer_2d();
    }
}

module instruction_card() {
    // Base card in white
    color("white") base_card();
    
    // Text layer in black (filament swap at card_thickness - text_depth)
    color("black") translate([0, 0, card_thickness - text_depth]) text_layer();
}

// Generate the card
instruction_card();
