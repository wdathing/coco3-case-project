// ============================================================================
// FLOPPY BAY FILLER PLATE -- separate file (per direction: "I wonder if this
// should maybe be in a separate file too") -- covers one empty 3.5" bay
// opening in the floppy bulkhead when no drive is installed there.
//
// Prints FLAT, decorative face up: no supports, best surface finish on the
// visible face, easy to add color (filament-swap bands or paint) per
// direction ("it should print flat... face up to have nice detail and
// perhaps colors added"). The back face (down, on the bed) carries two
// shallow pockets for a separate spring-clip part (also in this file) that
// friction/spring-fits into the bulkhead opening to retain the plate --
// "spring clips ... printed separate and insert, perhaps with glue, into
// slots in the back."
//
// Decorative treatment: a recessed center panel with half-round horizontal
// "louver" grooves, using the same "cylinder axis sits exactly on the
// surface, cutting only the inward half" technique as the main case's own
// decorative grooves -- kept visually consistent with the rest of the case.
//
// NOTE: dimensions below are copied from coco3_case.scad's own floppy_* /
// wall constants rather than `use`d/`include`d -- `include` would also
// execute that file's own part-selector at the bottom and mix its current
// default part into this file's output. Keep these in sync by hand if the
// bulkhead opening changes in the main file.
//
// FIRST PASS: the clip's spring geometry (arm_len/arm_w/t below) has not
// been print-fit-tested. Expect to retune after the first print.
// ============================================================================

$fn = 64;

// --- copied from coco3_case.scad (see note above) ---
floppy_w         = 101.6;
floppy_h         = 25.4;
floppy_fit_clear = 3;

opening_w = floppy_w + floppy_fit_clear;   // 104.6 -- matches the real bulkhead opening
opening_h = floppy_h + floppy_fit_clear;   // 28.4

// --- filler plate parameters ---
flange_margin  = 3;      // flange overlap past the opening, all sides -- keeps it from falling through
flange_t       = 3.5;    // overall plate thickness
inset_depth    = 1;      // decorative panel recess depth
inset_margin   = 6;      // solid border width kept around the decorative panel
corner_r       = 4;      // plate's own outer corner rounding
inset_corner_r = 2.5;    // recessed panel's corner rounding

flange_w = opening_w + 2*flange_margin;   // 110.6
flange_h = opening_h + 2*flange_margin;   // 34.4

groove_r     = 1.0;      // shallower than the main case's 1.5mm -- there's less material to spare here
groove_pitch = 5;
groove_edge_clear = 3;   // keep grooves this far from the panel's own top/bottom edge

// --- spring clip slots, in the plate's back face ---
clip_slot_w   = 3.4;
clip_slot_l   = 9;
clip_slot_d   = 1.6;
clip_slot_x_offset = flange_w/2 - 3;   // slot center, 3mm in from the flange's L/R edge

module rounded_rect_2d(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h], center = true);
}

module floppy_filler_plate() {
    panel_w = flange_w - 2*inset_margin;
    panel_h = flange_h - 2*inset_margin;
    difference() {
        linear_extrude(height = flange_t)
            rounded_rect_2d(flange_w, flange_h, corner_r);

        // recessed decorative panel (cut down from the top/decorative face)
        translate([0, 0, flange_t - inset_depth])
            linear_extrude(height = inset_depth + 0.1)
                rounded_rect_2d(panel_w, panel_h, inset_corner_r);

        // half-round louver grooves within the panel -- cylinder axis sits
        // exactly on the recessed panel's own surface, so only the inward
        // half is ever removed
        for (gy = [-(panel_h/2 - groove_edge_clear) : groove_pitch : panel_h/2 - groove_edge_clear])
            translate([0, gy, flange_t - inset_depth])
                rotate([0, 90, 0])
                    cylinder(r = groove_r, h = panel_w + 1, center = true);

        // back-side pockets for the spring clips (recessed from the back
        // face only -- plate back sits on the bed when printed, so these
        // just leave gaps in the first layer, no overhangs/supports needed)
        for (side = [-1, 1])
            translate([side*clip_slot_x_offset, 0, -0.05])
                cube([clip_slot_w, clip_slot_l, clip_slot_d + 0.05], center = true);
    }
}

module floppy_filler_clip() {
    // Flat cantilever leaf-spring clip -- prints in-plane (XY), no
    // overhangs. Base slides (glue if needed) into the plate's back
    // pocket; the arm extends past the plate's edge and flexes to press
    // outward against the bulkhead opening's inner wall for retention.
    base_w  = clip_slot_w - 0.15;
    base_l  = clip_slot_l - 0.3;
    arm_len = 9;
    arm_w   = 3;
    t       = 1.2;

    linear_extrude(height = t) {
        translate([-base_w/2, -base_l/2])
            square([base_w, base_l]);
        translate([0, base_l/2])
            polygon([
                [-arm_w/2, 0], [arm_w/2, 0],
                [arm_w*0.6, arm_len*0.6], [arm_w*0.35, arm_len],
                [-arm_w*0.35, arm_len], [-arm_w*0.6, arm_len*0.6]
            ]);
    }
}

// ============================================================================
// part selection -- "plate" | "clip" | "both" (both, laid out for one plate)
// ============================================================================
part = "plate";

if (part == "plate")
    floppy_filler_plate();
else if (part == "clip")
    floppy_filler_clip();
else if (part == "both") {
    floppy_filler_plate();
    translate([0, flange_h/2 + 12, 0]) floppy_filler_clip();
    translate([0, -(flange_h/2 + 12), 0]) rotate([0,0,180]) floppy_filler_clip();
}
