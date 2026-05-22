/**
 * Single-side 19" rack mounting plate: 1U tall, two holes (outer holes of the
 * standard EIA-310 three-hole group — middle hole omitted).
 *
 * Datum: plate bottom (Z = 0) aligns with the rack U boundary below this slot
 * (center of the 1/2" gap between hole groups). Plate top is the U boundary
 * above. Height and hole Z positions are fixed per EIA-310 (not parametric).
 * Plate width, thickness, hole size, and holder dimensions are parametric.
 *
 * Axes: X = along the ear (horizontal), Y = plate normal (Y = 0 is the outer stack
 *       plane; plate, tab, and ring lie in Y ≤ 0), Z = vertical (EIA rack height).
 *       X = 0 is the rail contact plane; geometry is symmetric in X (no handedness).
 *
 * Mic holder: hollow cylinder, axis +Z (vertical bore). Outer ring can have a wedge
 * removed (apex at holder centre, opening along −Y), with chamfered cylinders on the jaw
 * tips (tip Ø = half the outer−inner difference, i.e. radial wall). Bodies use
 * chamfered_cylinder (barrel h − 2×chamfer + end cones). Inner/outer are full Ø;
 * holder_thickness is the vertical grip length (Z). Ring lies in Y ≤ 0 (outer tangent
 * to Y = 0). Rail-side alignment: min X of ring and plate both at
 * X = 0. Z centered between the two rack mounting holes.
 *
 * Tab: square in XY (holder_outer_d/2 × holder_outer_d/2), Z = holder_thickness;
 * Y from −holder_outer_d/2 … 0 (face on Y = 0), anchored at X = 0. Unioned with the outer
 * ring; inner bore subtracted from that union.
 *
 * Plate chamfer: main slab shortened in Y by chamfer, then hull frustum unioned on the −Y
 * face (same pattern as tab / ring: thin body + added bevel solid).
 */

// --- Parametric (user) ---
plate_width = 15;       // mm, horizontal extent (single rail side)
plate_thickness = 2;    // mm
mounting_hole_d = 7.2;  // mm, typical for M6/cage-nut clearance (adjust to rail)
chamfer = 0.6;          // mm, 45° bevel on plate −Y face rim (see chamfer module)

// Mic grip (diameters = full Ø; thickness = vertical length along Z / bore axis)
holder_inner_d = 32;
holder_outer_d = 42;
holder_thickness = 8;
// Wedge removed from outer ring only: apex at holder centre, symmetric about −Y (full angle, deg).
mic_wedge_deg = 90;

// --- EIA-310 vertical: not parametric ---
// 1U = 1.75 in
function u_height_mm() = 44.45;
// Within one U, hole centers are 5/8" + 5/8" + 1/2" apart on center (bottom→top).
// U boundary lies in the middle of each 1/2" gap, so first and third hole centers
// sit 1/4" above the lower gap center and 1/4" below the upper gap center.
function hole_bottom_z_mm() = 6.35;   // 12.7 / 2
function hole_top_z_mm() = 38.1;    // 6.35 + 15.875 + 15.875

// Positive solid: hull of inset X–Z face at Y = −t (outer back) and full face at Y = −t + c (joins thinned slab).
module plate_back_face_chamfer_frustum(w, t, hh, c) {
  eps_y = 0.02;
  assert(c > 0);
  assert(c < t, "chamfer must be less than plate thickness");
  assert(w > 2 * c && hh > 2 * c, "chamfer inset needs w and hh greater than 2 * chamfer");

  // Large slab at join (y = −t + c, with thinned core); small at outer back (y = −t) — same
  // sense as tab top chamfer (large at join, small at tip) with +Y = “into” the plate.
  hull() {
    translate([c, -t, c])
      cube([w - 2 * c, eps_y, hh - 2 * c]);
    translate([0, -t + c - eps_y, 0])
      cube([w, eps_y, hh]);
  }
}

// Vertical cylinder on +Z, centered: main barrel height (h − 2×ch) plus truncated cones (ch each).
// outer=true: outer lip (r grows toward ends). outer=false: bore-positive solid (inner flare).
module chamfered_cylinder(d, h, ch, outer = true, fn = 64) {
  R = d / 2;
  assert(ch > 0 && ch < h / 2, "chamfer must be in (0, h/2)");
  if (outer)
    assert(ch < R, "outer chamfer must be less than radius");
  union() {
    cylinder(h = h - 2 * ch, d = d, center = true, $fn = fn);
    translate([0, 0, -h / 2])
      cylinder(h = ch, r1 = outer ? R - ch : R + ch, r2 = R, $fn = fn);
    translate([0, 0, h / 2 - ch])
      cylinder(h = ch, r1 = R, r2 = outer ? R - ch : R + ch, $fn = fn);
  }
}

// Apex at origin; pie symmetric about −Y; extruded along Z (holder local frame after translate).
// r_far: use a full outer diameter from the apex so the triangular wedge reliably clears the ring.
module mic_holder_centre_neg_y_wedge_remove(gap_deg, r_far, h) {
  rotate([0, 0, -90 - gap_deg / 2])
    linear_extrude(height = h, center = true)
      polygon([[0, 0], [r_far, 0], [r_far * cos(gap_deg), r_far * sin(gap_deg)]]);
}

module mic_holder_ring() {
  assert(holder_outer_d > holder_inner_d, "holder_outer_d must exceed holder_inner_d");
  assert(holder_inner_d > 0 && holder_thickness > 0);
  assert(chamfer > 0 && chamfer < holder_thickness / 2, "chamfer must be less than half holder_thickness");
  assert(chamfer < holder_outer_d / 2, "chamfer must be less than outer radius for ring chamfer cones");
  assert(holder_inner_d / 2 + chamfer < holder_outer_d / 2, "inner chamfer cones must stay inside outer ring wall");
  assert(holder_outer_d > 4 * chamfer, "tab chamfer needs holder_outer_d > 4 * chamfer (square inset)");
  assert(mic_wedge_deg > 0 && mic_wedge_deg < 179, "mic_wedge_deg must be in (0, 179) for finite wedge");
  assert(chamfer < (holder_outer_d - holder_inner_d) / 4,
    "chamfer must be less than half the tip radius (tip Ø is half of outer−inner difference)");

  zb = hole_bottom_z_mm();
  zt = hole_top_z_mm();
  z_center = (zb + zt) / 2;
  // Outer disk in XY; min X = 0 aligns with plate rail-side edge.
  x_center = holder_outer_d / 2;
  // Ring in Y ≤ 0; outer circle tangent to the Y = 0 plane (same as plate/tab face).
  y_center = -holder_outer_d / 2;

  h_plate = u_height_mm();
  z_tab = h_plate / 2 - holder_thickness / 2;

  R_outer = holder_outer_d / 2;
  R_inner = holder_inner_d / 2;
  R_wall_mid = (R_inner + R_outer) / 2; // claw tips sit mid-wall, not on outer rim
  claw_tip_d = (holder_outer_d - holder_inner_d) / 2; // Ø = radial wall (diameter diff is split)
  H = holder_thickness;
  c = chamfer;

  a_tab = holder_outer_d / 2;
  z0_tab = z_tab;
  eps_tab = 0.02;

  difference() {
    union() {
      // Tab: main block shortened in Z + square frustums (45° bevel on top and bottom faces).
      union() {
        translate([0, -a_tab, z0_tab + c])
          cube([a_tab, a_tab, H - 2 * c]);
        // Bottom bevel: large at join (z0_tab + c), small at outer tip (z0_tab) — same sense as top.
        hull() {
          translate([c, -a_tab + c, z0_tab])
            linear_extrude(eps_tab) square(a_tab - 2 * c);
          translate([0, -a_tab, z0_tab + c - eps_tab])
            linear_extrude(eps_tab) square(a_tab);
        }
        hull() {
          translate([0, -a_tab, z0_tab + H - c])
            linear_extrude(eps_tab) square(a_tab);
          // linear_extrude goes +Z; end top slice at z0_tab + H, not above it.
          translate([c, -a_tab + c, z0_tab + H - eps_tab])
            linear_extrude(eps_tab) square(a_tab - 2 * c);
        }
      }
      // Outer claw: chamfered cylinder minus wedge, plus chamfered tips on the jaw edges.
      translate([x_center, y_center, z_center]) {
        r_wedge = holder_outer_d;
        union() {
          difference() {
            chamfered_cylinder(holder_outer_d, H, c, outer = true, fn = 64);
            mic_holder_centre_neg_y_wedge_remove(mic_wedge_deg, r_wedge, H + 0.2);
          }
          // Wedge is symmetric about −Y; jaw edges at −90° ± half angle (not +Y).
          for (a = [-90 - mic_wedge_deg / 2, -90 + mic_wedge_deg / 2])
            translate([R_wall_mid * cos(a), R_wall_mid * sin(a), 0])
              chamfered_cylinder(claw_tip_d, H, c, outer = true, fn = 32);
        }
      }
    }
    // Bore: chamfered inner solid (subtract; flares wider at top/bottom).
    translate([x_center, y_center, z_center])
      chamfered_cylinder(holder_inner_d, H, c, outer = false, fn = 64);
  }
}

module rack_1u_two_hole_plate() {
  h = u_height_mm();
  z1 = hole_bottom_z_mm();
  z2 = hole_top_z_mm();

  difference() {
    union() {
      union() {
        translate([0, -plate_thickness + chamfer, 0])
          cube([plate_width, plate_thickness - chamfer, h]);
        plate_back_face_chamfer_frustum(plate_width, plate_thickness, h, chamfer);
      }
      mic_holder_ring();
    }
    for (z = [z1, z2])
      translate([plate_width / 2, -plate_thickness / 2, z])
        rotate([90, 0, 0])
          cylinder(d = mounting_hole_d, h = plate_thickness + 0.02, center = true, $fn = 48);
  }
}

rack_1u_two_hole_plate();
