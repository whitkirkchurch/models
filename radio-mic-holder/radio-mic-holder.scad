// Radio Mic Holder
// Holds 2 microphone packs and 1 battery charger

// --- Item dimensions ---
// mm
mic_width   = 65;
// mm
mic_depth   = 26;

// mm
charger_width = 70;
// mm
charger_depth = 30;

// mm
clip_width = 30;
// mm
clip_depth = 10;

// --- Holder parameters ---
// number of microphone packs to hold
num_mic_packs   = 2;
// mm — floor under items
base_thickness  = 3;
// mm — height at front of holder
holder_height_front = 35;
// mm — height at back of holder
holder_height_back  = 50;
// mm — space between items front-to-back
item_spacing    = 8;
// mm — space on left and right
wall_thickness_side = 3;
// mm — space on front and back
wall_thickness_front_back = 8;
// degrees — backward tilt of holders
tilt_angle      = 12;
// mm — how much base extends beyond top
base_flare      = 4;

// --- Calculated dimensions ---
widest_item = max(mic_width, charger_width);            // 70
// Account for backward extension from tilt: depth*cos(angle) + height*sin(angle)
// For small angles, cos ≈ 1, so extension ≈ depth + height*sin(angle)
tilt_extension = holder_height_back * sin(tilt_angle);
total_depth = num_mic_packs * (mic_depth + clip_depth) + charger_depth + num_mic_packs * item_spacing + tilt_extension;

holder_width = widest_item + 2 * wall_thickness_side;              // 76
// Account for the front wall tilt - at base height, front wall is pushed back
front_wall_offset = base_thickness * tan(tilt_angle);
holder_depth = total_depth + 2 * wall_thickness_front_back + front_wall_offset;

side_wall = (holder_width - widest_item) / 2;           // 3
front_wall = wall_thickness_front_back + front_wall_offset;    // 8 + offset

// --- Reusable modules ---
module slanted_box(width, depth, height_front, height_back, angle, flare) {
    // Create a box with front wall tilted backward by angle and sloped top
    offset = height_front * tan(angle);
    
    polyhedron(
        points = [
            // Bottom face (flared out)
            [-flare, -flare, 0],           // 0: front left bottom
            [width + flare, -flare, 0],    // 1: front right bottom
            [width + flare, depth + flare, 0],   // 2: back right bottom
            [-flare, depth + flare, 0],    // 3: back left bottom
            // Top face (sloped)
            [0, offset, height_front],         // 4: front left top
            [width, offset, height_front],     // 5: front right top
            [width, depth, height_back],       // 6: back right top
            [0, depth, height_back]            // 7: back left top
        ],
        faces = [
            [0, 1, 2, 3],  // bottom
            [7, 6, 5, 4],  // top (sloped)
            [0, 4, 5, 1],  // front
            [1, 5, 6, 2],  // right
            [2, 6, 7, 3],  // back
            [3, 7, 4, 0]   // left
        ]
    );
}

module mic_pack(height) {
    union() {
        // Main body
        cube([mic_width, mic_depth, height]);
        
        // Clip cutout on back
        translate([(mic_width - clip_width) / 2, mic_depth, 0])
            cube([clip_width, clip_depth, height]);
    }
}

module battery_charger(height) {
    cube([charger_width, charger_depth, height]);
}

// --- Main holder ---
difference() {
    // Slanted block with sloped top and flared base
    slanted_box(holder_width, holder_depth, holder_height_front, holder_height_back, tilt_angle, base_flare);

    // Mic packs
    for (i = [0:num_mic_packs-1]) {
        // Calculate adjustments for tilt
        mic_total_depth = mic_depth + clip_depth;
        y_position = front_wall + i * (mic_total_depth + item_spacing);
        
        // Z offset: base clearance + tilt adjustment + slope following
        // As items go further back (larger Y), raise them to follow the sloped top
        slope_adjustment = (y_position / holder_depth) * (holder_height_back - holder_height_front);
        z_offset = base_thickness + mic_total_depth * sin(tilt_angle) + slope_adjustment;
        
        translate([(holder_width - mic_width) / 2, 
                   y_position, 
                   z_offset])
            rotate([-tilt_angle, 0, 0])
                mic_pack(holder_height_back);
    }

    // Battery charger
    charger_y_position = front_wall + num_mic_packs * ((mic_depth + clip_depth) + item_spacing);
    
    // Z offset with slope following
    charger_slope_adjustment = (charger_y_position / holder_depth) * (holder_height_back - holder_height_front);
    charger_z_offset = base_thickness + charger_depth * sin(tilt_angle) + charger_slope_adjustment;
    
    translate([(holder_width - charger_width) / 2, 
               charger_y_position, 
               charger_z_offset])
        rotate([-tilt_angle, 0, 0])
            battery_charger(holder_height_back);
}
