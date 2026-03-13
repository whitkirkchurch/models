// Parametric tape measure holder for IKEA SKÅDIS pegboard
// All dimensions in mm

$fn = 50;

/* [Holder Dimensions] */
// Internal width of the holder cavity
measure_width = 100;
// Internal depth of the holder cavity
measure_depth = 55;

/* [Wall and Structure] */
// Thickness of side and back walls
wall_thickness = 1.6;
// Thickness of the base plate
base_thickness = 2;
// Radius of rounded corners on holder
corner_radius = 1;

/* [Height Settings] */
// Height of front wall
front_height = 20;
// Height of back wall (minimum 54mm for SKÅDIS)
back_height = 54;

/* [Base Slot] */
// Width of measurement tape slot in base
slot_width = 8;
// Enable slot on right side of base
slot_right = true;
// Enable slot on left side of base
slot_left = false;

/* [Pegboard Specifications] */
// Width of pegboard holes
pegboard_hole_width = 5;
// Height of pegboard holes
pegboard_hole_height = 15;
// Radius of rounded ends on pegboard holes
pegboard_hole_radius = 2.5;
// Horizontal spacing between pegboard holes (center to center)
pegboard_horizontal_spacing = 40;
// Vertical spacing between pegboard holes (center to center)
pegboard_vertical_spacing = 40;
// Depth of pegboard material
pegboard_depth = 5;

/* [Print Tolerance] */
// Clearance for pegboard pins (smaller = tighter fit)
pegboard_tolerance = 0.5;

// Calculated dimensions
width = measure_width + 2*wall_thickness;   // X axis
depth = measure_depth + 2*wall_thickness;   // Y axis

// Main assembly
tape_measure_holder();

module tape_measure_holder() {
    wedge_depth = back_height - front_height;
    
    union() {
        difference() {
            // Outer cuboid
            rounded_cuboid(width, depth, back_height, corner_radius);
            
            // Inner cavity (full height)
            rounded_cuboid(measure_width, measure_depth, back_height, corner_radius);
            
            // Wedge to create slope from front to back
            rotate([90, 0, 90])
                linear_extrude(width, center = true)
                    polygon([
                        [-depth/2, back_height/2],
                        [depth/2-wall_thickness, back_height/2],
                        [-depth/2, back_height/2 - (back_height - front_height)]
                    ]);
        }
        
        // Base plate with slot
        
        base_plate_width = width - 2*corner_radius;
        base_plate_depth = depth - 2*corner_radius;
        
        difference() {
            translate([0, 0, -back_height/2 + base_thickness/2])
                cube([base_plate_width, base_plate_depth, base_thickness], center = true);
            
            // Right side slot
            if (slot_right) {
                translate([base_plate_width/2 - slot_width/2, 0, -back_height/2 + base_thickness/2])
                    cube([slot_width, base_plate_depth + 1, base_thickness + 1], center = true);
            }
            
            // Left side slot
            if (slot_left) {
                translate([-base_plate_width/2 + slot_width/2, 0, -back_height/2 + base_thickness/2])
                    cube([slot_width, base_plate_depth + 1, base_thickness + 1], center = true);
            }
        }
        
        // Locking pins for pegboard
        translate([-pegboard_horizontal_spacing/2, depth/2, -back_height/2 + pegboard_hole_height/2 - pegboard_tolerance])
            pegboard_connector();
        
        translate([pegboard_horizontal_spacing/2, depth/2, -back_height/2 + pegboard_hole_height/2 - pegboard_tolerance])
            pegboard_connector();
    }
}

// Pegboard connector pin
module pegboard_connector() {
    pin_radius = pegboard_hole_radius - pegboard_tolerance;
    bottom_pin_z = -(pegboard_hole_height/2 - pegboard_hole_radius);
    top_pin_z = pegboard_vertical_spacing + pegboard_hole_height/2 - pegboard_hole_radius;

    // Bottom pin
    translate([0, 0, bottom_pin_z])
        rotate([-90, 0, 0])
            cylinder(r = pin_radius, h = pegboard_depth + pegboard_tolerance, center = false);
    
    // Top pin
    translate([0, 0, top_pin_z])
        rotate([-90, 0, 0])
            cylinder(r = pin_radius, h = pegboard_depth + pegboard_tolerance, center = false);
    
    // Vertical locking oblong
    oblong_width = 2*pegboard_hole_radius - 2*pegboard_tolerance;
    oblong_depth = 2*pegboard_hole_radius;
    oblong_height = 3*pegboard_hole_radius;
    
    translate([0, pegboard_depth + pegboard_tolerance + pegboard_hole_radius, top_pin_z + oblong_height/2])
        cube([oblong_width, oblong_depth, oblong_height], center = true);
    
    // Support wedge for oblong
    support_height = pegboard_hole_height - 2*pegboard_hole_radius;
    support_depth = pegboard_depth + pegboard_tolerance + oblong_depth;
    
    rotate([90, 0, 90])
        linear_extrude(oblong_width, center = true)
            polygon([
                [0, top_pin_z],
                [0, top_pin_z - support_height],
                [support_depth, top_pin_z]
            ]);
}

// Reusable module for rounded cuboid
module rounded_cuboid(w, d, h, r) {
    hull() {
        translate([-(w/2 - r), -(d/2 - r), -h/2])
            cylinder(r = r, h = h);
        translate([(w/2 - r), -(d/2 - r), -h/2])
            cylinder(r = r, h = h);
        translate([-(w/2 - r), (d/2 - r), -h/2])
            cylinder(r = r, h = h);
        translate([(w/2 - r), (d/2 - r), -h/2])
            cylinder(r = r, h = h);
    }
}
