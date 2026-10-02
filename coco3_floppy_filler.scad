// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Bill Athing -- https://github.com/wdathing/Coco3StreamlineCase
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
groove_n     = 4;        // a fixed count, centred on the panel (per direction -- the fixed-pitch loop lost one
                          // when the opening shrank and the panel got shorter)
groove_pitch = 5;        // at most; tightened if the panel can't fit groove_n at this pitch
groove_edge_clear = 3;   // keep grooves this far from the panel's own top/bottom edge

// --- spring clips ---
// Mechanism (2026-09-30 rework, per a print fit): each clip is a lofted blade standing ON EDGE in a blind pocket in
// the plate's back (foot anchored, glue if needed), one per side, centred vertically in a 20mm-tall slot. One face of
// the blade (local Z=0, matched to the pocket's own reference face) stays flat; the other carries the profile: base
// thickness through the foot, a thin waist that does the flexing, then a ROUNDED BUMP. The pocket leans outward so the
// relaxed bump reaches clip_bump_preload past the opening's side edge; installed, the bump presses on the bulkhead's
// opening side and the drive rail right behind it (the rails are flush with the opening's side edges, so there is no
// ledge behind the bulkhead to hook -- the old barb-and-catch clip ran into the rail). Holds by spring pressure; both
// sides of the bump are gentle ramps, so it pushes in and pulls out. The rest of the blade stays clear of the wall.
// Also fixed: the slots used to sit at a fixed X = 52 from when the opening was 104.6 wide -- outside today's 101.9
// opening. The position is derived from opening_w now.
clip_base_t   = 1.1;     // blade thickness through the foot (was 0.9)
clip_hinge_t  = 0.45;    // thickness at the flex waist -- concentrates the bend there (was 0.35)
clip_bump_t   = 1.8;     // bump crest thickness
clip_tip_t    = 0.6;     // thickness at the tip (lead-in)
clip_slot_h   = 20;      // the slot in the plate's back, along the plate's vertical
clip_blade_w  = clip_slot_h - 0.3;    // blade width at the base -- the plate's local Y (vertical) once installed
clip_tip_w    = clip_blade_w - 4;     // blade width at the tip (lead-in)
clip_arm_w    = clip_blade_w - 1;     // width through the waist/bump region
clip_foot_len = 2.0;     // portion anchored in the plate's blind pocket
clip_arm_len  = 8.0;     // portion projecting free past the back face, into the bay opening
clip_total_len = clip_foot_len + clip_arm_len;
clip_face_clr  = 0.3;    // blade's outer face this far inside the opening's edge at the bay face
clip_bump_preload = 0.8; // bump crest this far past the opening's edge at rest = how much it presses when installed
clip_pocket_d  = clip_foot_len + 0.5;   // blind pocket depth into the plate's back
clip_bump_pos  = [clip_foot_len + 5.0, clip_foot_len + 5.6];   // bump crest (start, end) along the clip, from the foot's deep end
clip_bump_depth = (clip_bump_pos[0] + clip_bump_pos[1])/2 - clip_pocket_d;   // crest's distance behind the plate's back face
clip_x_offset  = opening_w/2 - clip_face_clr - clip_base_t;   // pocket's reference (inner) face, at the back face
// Lean outward so the crest lands clip_bump_preload past the edge: offset + depth*tan(splay) + bump_t = edge + preload.
clip_splay_deg = atan((clip_face_clr + clip_base_t + clip_bump_preload - clip_bump_t) / clip_bump_depth);
clip_y_offset  = 0;      // centred vertically

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
    // blade's flat (non-bump) reference face. Clearance tightened from
    // 0.3 to 0.15 after the wider gap printed loose.
    pocket_w = clip_base_t + 0.15;
    pocket_h = clip_slot_h;
    pocket_d = clip_pocket_d;
    rotate([0, -clip_splay_deg, 0])
        translate([-0.15, -pocket_h/2, 0])
            cube([pocket_w, pocket_h, pocket_d]);
}

module floppy_filler_clip_pockets() {
    for (side = [-1, 1])
        for (yo = [clip_y_offset])                 // one per side now
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
        let (pitch = min(groove_pitch, (panel_h - 2*groove_edge_clear) / (groove_n - 1)))
        for (i = [0 : groove_n - 1])
            let (gy = (i - (groove_n - 1)/2) * pitch)
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
    // (the bump side) varies.
    translate([len_pos - 0.0005, -w/2, 0])
        cube([0.001, max(w, 0.01), max(t, 0.05)]);
}

module floppy_filler_clip() {
    // Flat-printing (lies on the bed, no supports) lofted spring blade.
    // Foot -> flex waist -> rounded bump -> lead-in tip,
    // see the header comment above for the mechanism. Installed standing
    // on edge in the plate's back pocket (floppy_filler_clip_pocket).
    f = clip_foot_len;
    pts = [
        [0,                clip_blade_w, clip_base_t],   // foot, deep end (in the pocket)
        [f,                clip_blade_w, clip_base_t],   // foot end / pocket mouth
        [f + 1.6,          clip_arm_w,   clip_base_t],   // narrows into the arm
        [f + 2.2,          clip_arm_w,   clip_hinge_t],  // flex hinge -- thin, does the bending
        [f + 2.7,          clip_arm_w,   clip_base_t],   // back to base thickness after the hinge
        [clip_bump_pos[0], clip_arm_w,   clip_bump_t],   // gentle ramp up to the bump (the pull-out side)
        [clip_bump_pos[1], clip_arm_w,   clip_bump_t],   // crest
        [clip_total_len,   clip_tip_w,   clip_tip_t],    // gentle ramp down to the tip (the push-in side)
    ];
    for (i = [0 : len(pts) - 2])
        hull() {
            clip_xsec(pts[i][0],   pts[i][1],   pts[i][2]);
            clip_xsec(pts[i+1][0], pts[i+1][1], pts[i+1][2]);
        }
}

// A clip seated in its pocket, in the plate's frame: the clip's length runs from the pocket bottom out of the back face
// (plate -z), its thickness along the pocket's local +x (the bump side, facing outward), its width along y.
module floppy_filler_clips_seated() {
    for (side = [-1, 1])
        translate([side*clip_x_offset, clip_y_offset, 0])
            mirror([side < 0 ? 1 : 0, 0, 0])
                rotate([0, -clip_splay_deg, 0])
                    multmatrix([[0, 0, 1, 0], [0, 1, 0, 0], [-1, 0, 0, clip_pocket_d], [0, 0, 0, 1]])
                        floppy_filler_clip();
}

// ============================================================================
// part selection -- "plate" | "clip" | "both" (both, laid out for one plate)
//                   | "assembly" (plate with both clips seated, for looking at / fit checks)
// ============================================================================
part = "plate";

if (part == "plate")
    floppy_filler_plate();
else if (part == "clip")
    floppy_filler_clip();
else if (part == "assembly") {
    color("Orange") floppy_filler_plate();
    color("SteelBlue") floppy_filler_clips_seated();
}
else if (part == "both") {
    floppy_filler_plate();
    for (i = [0, 1])
        translate([-clip_total_len - 4 + i*(clip_total_len + 8), flange_h/2 + 4 + clip_blade_w/2, 0])
            floppy_filler_clip();
}
