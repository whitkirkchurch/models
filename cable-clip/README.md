# Cable clip

A parametric saddle which holds one or more cables against a mounting surface using two screws. Each cable can have a different diameter. The grooves open downwards so the clip can be placed over existing cables, and the outside contour follows each cable. The mounting ears have a continuous outline and countersunk screw holes.

- [OpenSCAD source](cable-clip.scad)
- [Printable STL](cable-clip.stl)

## Customising

All dimensions are in millimetres. Edit `cable_diameters` in OpenSCAD to set the cable sizes in left-to-right order; the number of entries determines the cable count:

```scad
cable_diameters = [6, 10, 8, 14];
```

The default clip is 79.8 mm wide, 20 mm along the cables and 17.85 mm high, with screw centres 67.4 mm apart.

| Parameter | Purpose |
| --- | --- |
| `diameter_allowance` | Amount added to each groove diameter; positive values loosen the fit |
| `compression` | Amount the groove is lowered to press on the cable jacket |
| `grip_length` | Length along the cables |
| `web` | Spacing between adjacent cable envelopes |
| `outer_wall`, `roof_thickness` | Side and roof material around the grooves |
| `ear_thickness` | Thickness of the screw mounting ears |
| `screw_shank_diameter`, `screw_hole_clearance` | Screw shank and hole fit |
| `screw_head_diameter`, `head_clearance` | Countersink head fit |
| `countersunk` | Defaults to a 90-degree countersink; disable for pan heads |

`diameter_allowance` and `compression` each accept either a single number or a list with one value per cable. Crown interference is `compression - diameter_allowance / 2`. Start with `compression = 0` for a fit check, then adjust gently for the actual cable jackets and print material. The default is 0.15 mm compression and zero allowance.

The defaults assume **two 12 mm long screws**, with 3 mm shanks and 6 mm, 90-degree countersunk heads. Measure the actual screws and adjust the parameters. Default shank holes are 3.4 mm across and the countersinks are 6.4 mm across. The 3 mm ears leave approximately 10.5 mm of screw penetration below the mounting surface for countersunk screws; choose suitable screws for the mounting material.

## Printing

The supplied STL stands on a cable entry end, with the cable direction vertical. This avoids bridging the cable grooves. The small screw holes run horizontally in this orientation. `print_on_end = true` selects this orientation; the default OpenSCAD view shows the installed orientation. `show_cables = true` adds translucent reference cables in preview only.

Render with F6 and export an STL after changing the parameters, or run from this directory:

```sh
openscad --hardwarnings --export-format binstl \
  -D 'print_on_end=true' -o cable-clip.stl cable-clip.scad
```

The default, a single-cable version, and a mixed-diameter version with individual fit adjustments have been rendered and checked for closed, connected meshes. Physical fit and jacket compression still need a trial print.
