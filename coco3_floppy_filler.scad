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
// Bulkhead opening tightened after a real print test ("opening is about
// 3mm too wide and 2mm too tall") -- floppy_fit_clear_w/h there replace
// the old single floppy_fit_clear=3 this file used to mirror.
floppy_w           = 101.6;
floppy_h           = 25.4;
floppy_fit_clear_w = 0.3;
floppy_fit_clear_h = 1.3;

opening_w = floppy_w + floppy_fit_clear_w;   // 101.9 -- matches the real bulkhead opening
opening_h = floppy_h + floppy_fit_clear_h;   // 26.7

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

// --- spring clips ---
// Mechanism: each clip is a lofted blade that stands ON EDGE in a blind
// pocket in the plate's back (foot anchored, glue if needed). One face of
// the blade (local Z=0, matched to the pocket's own reference face) stays
// flat along the whole length; the OTHER face (Z growing) carries the
// profile: base thickness through the foot, a thin waist that does the
// actual flexing (like a real cantilever snap-fit, not a stiff taper),
// then a ramp up to a barb peak, then a sharp drop to an undercut catch
// face. The pocket itself is angled outward so, once past the peak, the
// blade sits inside the bay opening with the barb's relaxed reach past
// the opening's edge -- inserting compresses the waist as the barb rides
// over the edge, and it springs back so the catch face sits behind the
// bulkhead, resisting pull-out the way a real drive-bay clip does (not
// just relying on continuous friction from a smooth taper, which is what
// the first draft here did and which read as "no spring, no barb").
// FIRST PASS -- lengths/thicknesses below are a reasonable starting
// guess, not a solved spring rate; retune after a fit test.
clip_base_t   = 0.9;     // nominal blade thickness through the foot -- thin enough to flex,
                          // but sized to snugly fill the pocket (pocket_w below), not rattle
                          // around in it. Bumped from 0.7 after a fit test came back loose.
clip_hinge_t  = 0.35;    // thickness at the flex waist -- concentrates the bend there
clip_barb_t   = 1.7;     // barb peak thickness (extra reach that has to compress going in)
clip_catch_t  = 0.4;     // thickness right after the barb -- undercut, gives the catch a real ledge
clip_blade_w  = 3.4;     // blade width at the base -- the plate's local Y (vertical) once installed
clip_tip_w    = 1.8;     // blade width at the tip
clip_arm_w    = clip_blade_w * 0.8;   // width through the waist/barb/catch region
clip_foot_len = 2.0;     // portion anchored in the plate's blind pocket
clip_arm_len  = 8.0;     // portion projecting free past the back face, into the bay opening
clip_total_len = clip_foot_len + clip_arm_len;
clip_splay_deg = 18;     // pocket lean, outward from straight-in -- at this angle the barb
                          // peak (positioned to clear the 4mm bulkhead with margin) lands
                          // about 1.5mm past the opening's own edge at rest
clip_x_offset  = 52;     // pocket center -- must sit in the solid border (panel edge is at
                          // flange_w/2 - inset_margin = 49.3, only 2.5mm of material remains
                          // under the panel itself; the pocket needs the full-thickness
                          // border, up to the flange's own outer edge at 55.3)
clip_y_offset  = 9;      // 4 clips total (2 per side, split top/bottom) instead of 2 -- a
                          // single clip per side lets the plate rock/twist about the
                          // diagonal; four spread across all quadrants holds it flat and
                          // square. Stays clear of the corner rounding (corner_r=4 starts
                          // past X=51.3/Y=13.2, this sits inside that).

module rounded_rect_2d(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h], center = true);
}

module floppy_filler_clip_pocket() {
    // Blind pocket for one clip's foot, angled outward by clip_splay_deg.
    // Only the foot depth is cut here -- the arm projects into open space
    // beyond the back face and isn't part of the plate's own geometry.
    // Matches the clip's own foot cross-section (local Z 0..clip_base_t,
    // Y -clip_blade_w/2..clip_blade_w/2) with a little clearance -- not
    // centered in X, so the pocket's local X=0 face lines up with the
    // blade's flat (non-barb) reference face. Clearance tightened from
    // 0.3 to 0.15 after the wider gap printed loose.
    pocket_w = clip_base_t + 0.15;
    pocket_h = clip_blade_w + 0.3;
    pocket_d = clip_foot_len + 0.5;
    rotate([0, -clip_splay_deg, 0])
        translate([-0.15, -pocket_h/2, 0])
            cube([pocket_w, pocket_h, pocket_d]);
}

module floppy_filler_clip_pockets() {
    for (side = [-1, 1])
        for (yo = [-clip_y_offset, clip_y_offset])
            translate([side*clip_x_offset, yo, 0])
                mirror([side < 0 ? 1 : 0, 0, 0])
                    floppy_filler_clip_pocket();
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
                    cylinder(r = groove_r, h = panel_w + 0.2, center = true);

        // blind pockets for the two spring clips (see floppy_filler_clip_pocket)
        floppy_filler_clip_pockets();
    }
}

module clip_xsec(len_pos, w, t) {
    // A thin cross-section slice at a given length position, for lofting.
    // Z always starts at 0 -- that face is the blade's flat reference
    // side (matches the pocket's own local X=0 face); only the Z=t face
    // (the barb side) varies.
    translate([len_pos - 0.0005, -w/2, 0])
        cube([0.001, max(w, 0.01), max(t, 0.05)]);
}

module floppy_filler_clip() {
    // Flat-printing (lies on the bed, no supports) lofted spring blade.
    // Foot -> flex waist -> barb ramp -> catch undercut -> short tip,
    // see the header comment above for the mechanism. Installed standing
    // on edge in the plate's back pocket (floppy_filler_clip_pocket).
    f = clip_foot_len;
    pts = [
        [0,                clip_blade_w, clip_base_t],   // foot, deep end (in the pocket)
        [f,                clip_blade_w, clip_base_t],   // foot end / pocket mouth
        [f + 2.2,          clip_arm_w,   clip_base_t],   // narrows into the arm
        [f + 2.8,          clip_arm_w,   clip_hinge_t],  // flex hinge -- thin, does the bending
        [f + 3.3,          clip_arm_w,   clip_base_t],   // back to base thickness after the hinge
        [f + 6.0,          clip_arm_w,   clip_barb_t],   // ramp up to the barb peak
        [f + 6.6,          clip_arm_w,   clip_catch_t],  // sharp drop -- the catch face (undercut)
        [clip_total_len,   clip_tip_w,   clip_catch_t],  // short lead-in tip past the catch
    ];
    for (i = [0 : len(pts) - 2])
        hull() {
            clip_xsec(pts[i][0],   pts[i][1],   pts[i][2]);
            clip_xsec(pts[i+1][0], pts[i+1][1], pts[i+1][2]);
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
    for (i = [0, 1, 2, 3])
        translate([-clip_total_len/2 - 14 + i*10, flange_h/2 + 8, 0])
            floppy_filler_clip();
}
