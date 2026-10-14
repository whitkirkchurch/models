/*
Surface-mounted cable saddle, with two screws and no material under cables.
Units: mm. X = across cables, Y = along cables, Z = above mounting surface.

12 mm is the screw LENGTH. Measure your screws before setting shank/head sizes.
Default holes suit nominal 3 mm screws with 6 mm, 90-degree countersunk heads.

Edit cable_diameters to contain any number of cables, in left-to-right order.
diameter_allowance and compression may each be a number or a per-cable list.
At the crown, interference = compression - diameter_allowance / 2.
Start with compression = 0 for a fit check; increase gently to grip the jackets.

F6 renders the cleat. Export STL with print_on_end = true for printing with
the cable direction vertical. This avoids bridging the cable grooves; small
horizontal screw holes may still benefit from your printer's hole settings.
*/

/* [Cables] */
cable_diameters = [6, 10, 8, 14];
diameter_allowance = 0; // added to groove diameter
compression = 0.15;   // lowers the groove relative to a cable on the surface
grip_length = 20;
web = 3;
outer_wall = 4;
roof_thickness = 4;

/* [Two mounting screws] */
screw_length = 12;
screw_shank_diameter = 3;
screw_hole_clearance = 0.4; // added to shank diameter
screw_head_diameter = 6;
head_clearance = 0.4;
ear_thickness = 3;
head_edge_margin = 3; // material outside the head footprint
countersunk = true; // false: pan/button head; true: 90-degree countersink

/* [Appearance and output] */
corner_radius = 2;
print_on_end = false;
show_cables = false; // translucent reference cables, preview only

/* [Hidden] */
$fn = 96;
eps = 0.02;
n = len(cable_diameters);

function per_cable(value, i) = is_list(value) ? value[i] : value;
function prefix_sum(values, count) =
    count <= 0 ? 0 : values[count - 1] + prefix_sum(values, count - 1);

assert(n >= 1, "Supply at least one cable diameter.");
assert(!is_list(diameter_allowance) || len(diameter_allowance) == n,
       "diameter_allowance must be a number or one value per cable.");
assert(!is_list(compression) || len(compression) == n,
       "compression must be a number or one value per cable.");
assert(min(cable_diameters) > 0, "Cable diameters must be positive.");
assert(grip_length > 0 && web > 0 && outer_wall > 0 && roof_thickness > 0,
       "Body dimensions must be positive.");
assert(screw_shank_diameter > 0 && screw_hole_clearance >= 0 &&
       screw_head_diameter > screw_shank_diameter + screw_hole_clearance &&
       head_clearance >= 0 && head_edge_margin > 0 && ear_thickness > 0,
       "Check screw dimensions and mounting margins.");
assert(screw_length > ear_thickness, "Screws must extend through the ears.");

groove_diameters = [for (i = [0:n-1])
    cable_diameters[i] + per_cable(diameter_allowance, i)];
centre_heights = [for (i = [0:n-1])
    cable_diameters[i] / 2 - per_cable(compression, i)];
// Preserve spacing for actual cables as well as oversized grooves.
envelopes = [for (i = [0:n-1]) max(cable_diameters[i], groove_diameters[i])];
centres_x = [for (i = [0:n-1])
    outer_wall + prefix_sum(envelopes, i) + i * web + envelopes[i] / 2];
body_width = 2 * outer_wall + prefix_sum(envelopes, n) + (n - 1) * web;
body_height = max([for (i = [0:n-1])
    centre_heights[i] + groove_diameters[i] / 2]) + roof_thickness;
hole_diameter = screw_shank_diameter + screw_hole_clearance;
head_diameter = screw_head_diameter + head_clearance;
ear_length = head_diameter + 2 * head_edge_margin;
screw_positions = [-ear_length / 2, body_width + ear_length / 2];
sink_depth = countersunk ? (head_diameter - hole_diameter) / 2 : 0;

assert(min(groove_diameters) > 0 && min(centre_heights) > 0,
       "Allowance or compression makes a groove invalid.");
assert(min([for (i = [0:n-1]) per_cable(compression, i)]) >= 0,
       "Compression must be nonnegative; use allowance for a loose fit.");
assert(grip_length >= head_diameter + 2 * head_edge_margin,
       "Increase grip_length to leave material around the screw heads.");
assert(ear_thickness <= body_height && ear_thickness > sink_depth + 1,
       "Ears must fit the body and retain at least 1 mm below countersinks.");
assert(corner_radius >= 0 && corner_radius <= outer_wall &&
       corner_radius <= min(grip_length, ear_length) / 2,
       "Corner radius is too large.");

module rounded_box(width, depth, height) {
    linear_extrude(height = height)
        if (corner_radius > 0)
            translate([corner_radius, corner_radius])
                offset(r = corner_radius)
                    square([width - 2 * corner_radius,
                            depth - 2 * corner_radius]);
        else
            square([width, depth]);
}

module cable_axis_cylinder(x, z, diameter, length) {
    translate([x, 0, z])
        rotate([90, 0, 0])
            cylinder(d = diameter, h = length, center = true);
}

module groove(i) {
    d = groove_diameters[i];
    x = centres_x[i];
    z = centre_heights[i];
    // Circular crown with straight sides down to the mounting surface.
    // The full-width opening lets the saddle drop over existing cables.
    cable_axis_cylinder(x, z, d, grip_length + 2 * eps);
    translate([x - d / 2, -grip_length / 2 - eps, -eps])
        cube([d, grip_length + 2 * eps, z + eps]);
}

module screw_hole(x) {
    translate([x, 0, -eps])
        cylinder(d = hole_diameter, h = ear_thickness + 2 * eps);
    if (countersunk) {
        translate([x, 0, ear_thickness - sink_depth])
            cylinder(d1 = hole_diameter, d2 = head_diameter, h = sink_depth);
        translate([x, 0, ear_thickness - eps])
            cylinder(d = head_diameter, h = 2 * eps);
    }
}

module cable_roof(i) {
    // An outer arch follows each groove, rather than filling to a common roof.
    // Horizontal and vertical wall thicknesses can be adjusted independently.
    rx = groove_diameters[i] / 2 + outer_wall;
    rz = groove_diameters[i] / 2 + roof_thickness;
    x = centres_x[i];
    z = centre_heights[i];
    translate([0, grip_length / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = grip_length)
                union() {
                    translate([x - rx, 0]) square([2 * rx, z]);
                    intersection() {
                        translate([x, z]) scale([rx, rz]) circle(r = 1);
                        translate([x - rx - eps, z])
                            square([2 * rx + 2 * eps, rz + eps]);
                    }
                }
}

module cleat() {
    difference() {
        union() {
            // One continuous footprint: rounded only at the outer ear ends.
            // This removes the notches from separately rounded body and ears.
            translate([-ear_length, -grip_length / 2, 0])
                rounded_box(body_width + 2 * ear_length, grip_length, ear_thickness);
            for (i = [0:n-1]) cable_roof(i);
        }
        for (i = [0:n-1]) groove(i);
        for (x = screw_positions) screw_hole(x);
    }
}

module output_orientation() {
    if (print_on_end)
        translate([0, body_height, grip_length / 2])
            rotate([90, 0, 0]) children();
    else
        children();
}

echo(cable_count = n,
     overall_size = [body_width + 2 * ear_length, grip_length, body_height],
     screw_spacing = body_width + ear_length,
     approximate_screw_penetration = screw_length - ear_thickness + sink_depth);

output_orientation() {
    cleat();
    if (show_cables && $preview)
        for (i = [0:n-1])
            %color("orange", 0.4)
                cable_axis_cylinder(centres_x[i], cable_diameters[i] / 2,
                                    cable_diameters[i], grip_length + 12);
}
