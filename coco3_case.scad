// ============================================================================
// CoCo3 (26-3334) "CoCo4-style" 3D Printable Case  —  Parametric OpenSCAD
// ============================================================================
// DATA PROVENANCE — read this before changing numbers:
//
//   REAL / MEASURED data (do not guess-adjust without re-checking source):
//     - Motherboard outline, 3 standoff-hole positions+diameters, 12 named
//       connector positions/rotations  -> parsed directly from coco3.step
//       (KiCad STEP export of the qbancoffee/coco_motherboards 26-3334 board).
//     - Keyboard-controller PCB outline, 5 standoff holes, connector
//       positions -> parsed directly from Coco_pico_keyb.step (Pico-based
//       keyboard interface board).
//     - Boss height (22.25mm) and case wall thickness (2.4mm ABS) -> given
//       by user, measured from a stock case.
//     - Port identities (JK1/JK2 joystick, JK3 serial, JK4 cassette, J5A/J5B
//       composite video/audio, SW1 power, SW3 ch3/4, SW2 reset, CN1
//       cartridge -- confirmed RIGHT SIDE panel not rear, CN3 RGB
//       bottom-mounted) -> confirmed by user + Tandy service manual text.
//
//   PLACEHOLDER data (flagged TODO below, safe defaults, MUST verify before
//   printing final parts):
//     - oem_foot_height: stock rubber foot height was never measured/found;
//       Multipak card-edge slots have several mm of vertical play so this is
//       low-risk, but true it up if you can measure a stock foot.
//     - keyboard_unit_* : real CoCo keyboard mechanical envelope is NOT YET
//       measured (user is getting real numbers). Everything about the
//       keyboard tray floor/window is parametric off these 4 numbers, so
//       updating them re-shapes the whole keyboard tray automatically.
//     - Panel cutout SIZES for DIN4/5/6, RCA, cartridge slot, power switch,
//       reset button, slide switch: real bounding boxes only resolved
//       cleanly for JK3 (serial) and the two power jacks; everything else
//       uses standard commodity connector dimensions (DIN shells are
//       standardized regardless of pin count; RCA jacks are standardized;
//       card-edge slot width is derived from standard .1" 40-pos edge-card
//       spec). Adjust per-connector if your actual parts differ.
//     - Pico USB-port edge/orientation on the keyboard PCB (for the rear
//       keyboard-case cutout) and J6 DE-9 breakout orientation: positions
//       are real, but which edge the connector body actually exits from
//       wasn't resolved from the STEP nesting. Verify against the physical
//       board before printing the keyboard rear panel.
//
// UNITS: millimeters throughout. Y=0 is the REAR-panel edge of the board;
//        Y+ increases toward the FRONT (keyboard side). X+ = rightward as
//        viewed from the front (matches the real CN1 cartridge-slot side).
//        Z+ = up.
// ============================================================================

/* [Printer / Global] */
bed_x = 250;              // printer bed X (mm)   
bed_y = 250;              // printer bed Y (mm)
bed_z = 250;              // printer bed Z (mm) - not used for splitting yet (parts are short)
split_margin = 6;         // extra clearance subtracted from bed size before deciding to split
wall            = 2.4;    // shell wall thickness (matches OEM spirit)
tol             = 0.25;   // general fit clearance
// Fastening method for every M3 screw post/boss THAT THREADS DIRECTLY INTO
// PRINTED PLASTIC throughout the project (board standoffs' own real
// mounting-hole DIAMETERS on the PCB itself -- e.g. the 3.2mm clearance
// holes on the kbpcb board -- are fixed by the physical boards and
// unaffected by this; this only sets the PILOT hole printed into each
// post/boss). Per direction: reintroduced as a build-time choice (was
// self-tap-only for a while) -- "self_tap": screw threads directly into
// the plastic, pilot sized for good bite (2.6mm, per direction, up from
// the earlier 2.5mm placeholder -- "too big" reported at 2.5, i.e. that
// was already undersized/binding, not oversized -- true up further
// against the specific screws you actually use). "heat_set": a threaded
// brass insert gets pressed/heat-staked into the pilot first, then a
// machine screw threads into THAT -- pilot sized to the insert's own OD
// (4.0mm, per direction), not the screw.
screw_mount_type = "self_tap"; // "self_tap" or "heat_set"
m3_pilot_d = (screw_mount_type == "heat_set") ? 4.0 : 2.6;
$fn             = 48;     // circle resolution (raise for final render, lower for fast preview)

/* [Keyboard attachment mode] */
// true  = keyboard shell is structurally merged with the main shell (one
//         continuous printed seam, reinforced rib, NOT separable)
// false = keyboard shell is a separate, detachable part: lip-and-socket +
//         magnets join it to the main shell
keyboard_attached = false;
// (keyboard_attached=true = the BOLTED variant: no magnets; 3 M3 screws
//  from inside the main case clamp the keyboard shell on -- see
//  main_kb_bolt_holes() / kb_bolt_pilots(). false = detachable, magnets.)
// Rectangular lip/socket lugs (main_lip_socket / kb_socket_pockets) --
// separate from the magnet pockets, which stay on either way. Per
// direction, turned off for now (magnets alone are enough of an
// interlock to test with); flip back to true to bring the tabs back.
lip_socket_tabs_enabled = false;
// ONE-PIECE BOTTOM (big printers, e.g. the Sovol SV08 Max): the main bottom and the keyboard shell print as a single
// part ("bottom_one_piece"). The keyboard goes on the same 5mm stick-on feet as the main case (kb_feet), so the two
// undersides are one flat plane -- no supports. That lifts the keyboard 5mm, and the main top's front skirt (which is
// derived from the keyboard's shelf height) grows 5mm with it: print the main top from THIS setting too
// (stl/main_top_whole_1p.stl). No magnets, bolts or joiner keys -- keyboard_attached is ignored.
one_piece_bottom = false;
// HINGED LID: the back plate (rear wall, with all its connector cutouts and the DV I/O panel) becomes part of the
// bottom, and the rest of the top is a lid that swings up on a hinge along the rear top edge -- the drives ride up
// with it -- for access to the drive bays and the motherboard. See HINGED LID near the seam lugs. Parts keep their
// usual names (main_top_* = the lid, main_bottom_* / bottom_one_piece include the plate); export them to hinged-stls/.
main_hinged = false;
// The one-piece base WITH the hinged lid gets extra strength work (all gated on this, so no other build changes):
// solid posts up the two back corners, the decorative groove round the base's top edge filled across the back (it sat
// under the back plate as a support-hungry notch; kept along the sides), the rear PCB ribs' wall step carried up the
// plate as fins (the leftmost rib moved to sit centred between its two ports), and much rounder rear port openings.
onepiece_hinged = one_piece_bottom && main_hinged;
kb_join_magnets = !one_piece_bottom && !keyboard_attached;
kb_join_bolts   = !one_piece_bottom && keyboard_attached;
kb_join_keys    = !one_piece_bottom;   // the stepped bow-tie keys across the keyboard/main seam

/* [Height stack — Multipak compatibility] */
oem_boss_height   = 22.25;  // REAL (measured by user)
oem_floor_t       = 2.4;    // REAL (measured/estimated by user)
oem_foot_height   = 3.0;    // TODO PLACEHOLDER — verify against a stock unit if possible
target_pcb_top_above_desk = oem_foot_height + oem_floor_t + oem_boss_height;

new_foot_height   = 5.0;    // this design's own foot height (can differ from OEM) --
                             // 5mm adhesive rubber stick-on feet. standoff_height
                             // below solves to compensate automatically so the
                             // PCB (and cart slot) height above the desk stays
                             // fixed at target_pcb_top_above_desk regardless of
                             // this value -- that's the whole point of this
                             // formula, so just changing this one number is the
                             // correct/complete fix, no other height edits needed.
new_floor_t       = wall;   // this design's own floor thickness
standoff_height   = target_pcb_top_above_desk - new_foot_height - new_floor_t;
echo(str("Computed standoff height above case floor: ", standoff_height, " mm"));
echo(str("Target PCB-top height above desk (must match OEM for Multipak fit): ", target_pcb_top_above_desk, " mm"));

/* [Case shape / aesthetic — CoCo4-prototype-inspired wedge] */
case_margin        = 13.17; // clearance from board edge to inner wall
                            // Sized for the cart-slot side: CN1 is confirmed
                            // 40mm from the case wall on a real CoCo3;
                            // proposed 25mm here (tighter, still comfortable
                            // for the cantilevered cartridge). CN1 sits
                            // 11.83mm in from the board edge, so the wall
                            // needs to be 25 - 11.83 = 13.17mm out from the
                            // board edge to hit that. Applied uniformly (all
                            // 4 sides use the same margin) rather than only
                            // on the cart side, for simplicity -- total
                            // width becomes 280 + 2*13.17 = 306.3mm, still
                            // under 320mm. This also comfortably supersedes
                            // the earlier 6->9 bump that was only sized for
                            // the CN3 collar's own clearance need.
rear_margin         = case_margin - 9; // ~4.17mm -- per direction, after a
                            // real dry-fit of the physical motherboard into
                            // a partial print: the board's rear edge fell
                            // about 9mm short of reaching the rear wall.
                            // case_margin (13.17mm) was sized for the CN1
                            // cart-slot clearance need on the SIDE wall and
                            // just applied uniformly everywhere for
                            // simplicity -- it was never validated against
                            // the rear panel specifically, where the real
                            // connectors (DIN jacks etc.) mount close to the
                            // board edge and need the wall close behind
                            // them, not 13mm of open air. Used ONLY for the
                            // -Y (rear) side of the footprint everywhere
                            // that matters (outer shell, inner cavity, rear
                            // support ribs, raceway, rear panel notches) --
                            // front/left/right keep the original case_margin.
// front_deck_h / rear_tower_h are computed further down (see "TOP SHELL
// STYLING" below main_depth) -- they depend on parting_h and the floppy bay
// stack, neither of which exist yet at this point in the file.
corner_r           = 5;    // outer corner rounding radius -- matches the
                            // explicit 5mm 3D edge fillet request (see
                            // edge_fillet_r / rounded_footprint_solid
                            // below), used consistently for both. Applies
                            // directly to the BOTTOM shell and the TOP
                            // shell's vertical corners; the top shell's own
                            // rounded-top-rim treatment is not implemented
                            // yet (it's a wedge, not a plain box, so the
                            // hull()-cap technique used for the bottom
                            // shell doesn't directly apply) -- flag if you
                            // want that pursued too.

// Top/bottom clamshell split, flat across the whole footprint (simplest to
// print and assemble). Per a photo of a real stock case bottom: the OEM
// bottom shell is just a shallow tray (floor, standoffs, no connector
// cutouts) and the TALL top shell carries all the connector panel cutouts
// and louvers.
//
// parting_h = standoff_height + pcb_edge_lip_height: the bottom tray's
// wall stops right at the top of the PCB-edge lip (see main_pcb_edge_lip_
// relief further down) -- NOT higher, with extra headroom, as an earlier
// version of this file had it (parting_h = 34, ~10mm above the lip). That
// extra height was a real bug, not just cosmetic: a cartridge slides in
// at roughly PCB height, but the cart-slot notch is cut into the TOP
// shell starting at parting_h -- if the bottom tray's wall is still solid
// well above PCB height, it physically blocks the cartridge from ever
// reaching that notch. The cart guide walls are the one deliberate
// exception: they rise well above parting_h into the top shell's (hollow)
// interior, to guide the cartridge continuously from PCB height up to the
// slot opening.
pcb_edge_lip_height = 1.6; // matches PCB thickness -- see main_pcb_edge_lip_relief()
parting_h = standoff_height + pcb_edge_lip_height;

louver_count       = 11;
louver_w           = 3.0;
louver_gap         = 4.0;
louver_depth       = wall + 1.0; // cut all the way through the wall + a hair

/* [Keyboard mechanical envelope — TODO: replace with real measurements] */
keyboard_unit_w   = 330;  // PLACEHOLDER, proportioned from OEM 375mm cabinet width
keyboard_unit_d   = 130;  // PLACEHOLDER
keyboard_unit_h   = 20;   // PLACEHOLDER (keyswitch travel + plate)
keyboard_deck_margin = 10; // bezel width around the keyboard window

// ============================================================================
// MOTHERBOARD GEOMETRY (real, from coco3.step)
// ============================================================================
// board_pt() re-bases KiCad's native board coordinates (origin at a board
// corner, rear-panel connectors clustered near Y=0, board extends to
// Y=-156.26) into a first-quadrant, rear-positive-Y frame used everywhere
// else in this file.
BOARD_X_OFF = 31.48;
// board_pt is mirrored in X (248.52 - x, not x + BOARD_X_OFF) relative to
// the original transform. The original mapping put CN1 (cart slot) at
// high X and labeled that "right as viewed from the front" -- but the
// rigorous camera math for a viewer standing in front of the machine
// facing the rear (facing -Y) gives screen-right = -X, not +X (verify with
// a compass: face north, right hand points east; face south instead, right
// hand points west). So high-X was actually the viewer's LEFT. Confirmed
// against a real photo of the motherboard (coco2.jpg): viewed from near
// the keyboard looking toward the rear, the real card-edge connector is on
// the photographer's right -- which requires it to sit at LOW X once Y=0
// is correctly fixed as the rear (there's no ambiguity left on that point:
// every rear-panel connector clusters there). 248.52 = board_w -
// BOARD_X_OFF, chosen so the mirrored outline still spans exactly [0, 280].
function board_pt(x,y) = [248.52 - x, -y];

board_outline_raw = [
 [217.390,-1.000],[216.390,-0.000],[1.000,0.000],[0.000,-1.000],
 [-0.000,-16.320],[1.000,-17.320],[10.200,-17.320],[10.200,-87.400],
 [-30.480,-87.410],[-31.480,-88.410],[-31.480,-92.100],[-30.480,-93.100],
 [-28.400,-93.100],[-28.400,-95.920],[-30.480,-95.920],[-31.480,-96.920],
 [-31.480,-110.310],[-30.480,-111.310],[-28.240,-111.310],[-28.240,-113.980],
 [-30.480,-113.980],[-31.480,-114.980],[-31.480,-155.260],[-30.480,-156.260],
 [247.520,-156.260],[248.520,-155.260],[248.520,-122.070],[247.520,-121.070],
 [233.370,-121.070],[233.370,-97.970],[247.520,-97.970],[248.520,-96.970],
 [248.520,-24.760],[247.520,-23.760],[233.530,-23.760],[233.530,-12.670],
 [232.530,-11.670],[217.390,-11.670]
];
board_outline = [ for (p = board_outline_raw) board_pt(p[0], p[1]) ];
board_w = 280;     // bounding-box width  (X), real
board_d = 156.26;  // bounding-box depth  (Y), real
board_thickness = 1.55; // real

// standoff holes: [x, y, hole_diameter] -- real. First 3 were already known;
// the last 2 were found by re-parsing coco3.step directly (isolating the
// PCB's own solid body, extracting every CIRCLE entity, filtering to the
// 2.5-4.5mm mounting-screw diameter range, and checking for isolated
// corner placement vs. dense component-grid clustering). Those two are
// actually SLOTTED/oblong holes in the real board (a pair of 3.5mm circles
// ~2mm apart on X, not a single round hole -- likely intentional to
// absorb tolerance/thermal slop); modeled here as a plain round 3.5mm hole
// at the slot's midpoint, a reasonable simplification but not a literal
// match if you want the oblong shape reproduced exactly.
board_standoffs = [
  for (h = [ [239.389,-93.963,4.0], [239.389,-28.558,4.0], [-27.050,-103.160,3.5],
             [-26.760,-151.260,3.5], [243.360,-151.260,3.5] ])
    [ board_pt(h[0],h[1])[0], board_pt(h[0],h[1])[1], h[2] ]
];

// named connectors: [refdes, x, y, z_above_board, rot_deg, kind]
// z_above_board is the component's local Z origin from the STEP file; not
// used for cutout height directly (panel cutouts are sized generously) but
// kept for reference / future refinement.
board_connectors = [
  ["SW1", board_pt(16.30,  -9.27)[0], board_pt(16.30,  -9.27)[1],  7.31, -180, "power_switch"],
  ["JK1", board_pt(34.74, -12.29)[0], board_pt(34.74, -12.29)[1],  1.60,  180, "din6"],
  ["JK2", board_pt(58.08, -12.29)[0], board_pt(58.08, -12.29)[1],  1.60,  180, "din6"],
  ["JK3", board_pt(80.74,  -1.24)[0], board_pt(80.74,  -1.24)[1],  1.60,  180, "din4"],
  ["JK4", board_pt(103.79, -1.49)[0], board_pt(103.79, -1.49)[1], 11.76,  180, "din5"],
  ["J5A", board_pt(176.10, -1.74)[0], board_pt(176.10, -1.74)[1],  2.87,  180, "rca"],
  ["J5B", board_pt(191.10, -1.74)[0], board_pt(191.10, -1.74)[1],  2.87,  180, "rca"],
  ["SW3", board_pt(161.09, -3.55)[0], board_pt(161.09, -3.55)[1],  3.50,   90, "slide_switch"],
  ["SW2", board_pt(204.87, -3.91)[0], board_pt(204.87, -3.91)[1],  1.60,  180, "reset_button"],
  ["CN1", board_pt(236.69,-61.13)[0], board_pt(236.69,-61.13)[1],  6.60,  -90, "cart_slot"],   // RIGHT-SIDE panel!
  ["CN3", board_pt(230.31,-140.51)[0],board_pt(230.31,-140.51)[1], -0.09,  90, "rgb_din8"],
];

// ============================================================================
// KEYBOARD-CONTROLLER PCB GEOMETRY (real, from Coco_pico_keyb.step) --
// UPDATED per a revised board (smaller/simpler outline, "easier to work
// with and cheaper"; re-extracted via a proper STEP entity-graph parse
// this time, not hand-tracing, then cross-checked against the mounting
// holes' own real KiCad coordinates -- all 4 matched exactly). J2, a real
// DSUB-9 (DE-9) connector footprint now on the board, is deliberately NOT
// wired into the case yet -- per direction, "that will be implemented in
// a different deployment scenario."
//
// kbpcb_pt FIXED per direction ("upside down... rotate 180 degrees... align
// to the front edge"): the old formula [x-79.5, -y-28] flipped only the raw
// STEP Y axis (determinant -1 -- a MIRROR of the real board, not a rigid
// placement) and put the panel edge (USB/LEDs/button, all clustered near
// raw Y=-27.5) at the LOW end of local Y -- i.e. toward the case's rear,
// with the J1/J3 ribbon-header edge (raw Y=-98) toward the front instead.
// Both wrong. New formula copies raw X and Y directly (no flip at all --
// determinant +1, a proper placement) and re-zeros against the real
// outline's exact min corner (79.0, -98.0) instead of the old rounded
// (79.5, 28) constants, so the panel edge now lands at local Y=kbpcb_d
// (the HIGH end) -- the edge that gets placed toward the case's front wall
// below.
// ============================================================================
function kbpcb_pt(x,y) = [x - 79.0, y + 98.0];

// Real outline is a plain rounded rect now (2mm corner radius, not
// consumed by any cut geometry below -- kbpcb_w/kbpcb_d, the bounding
// box, are what's actually used -- so the corner rounding is just kept
// here for reference, not modeled).
kbpcb_outline_raw = [
 [167.5,-27.5],[167.5,-98.0],[79.0,-98.0],[79.0,-27.5]
];
kbpcb_outline = [ for (p = kbpcb_outline_raw) kbpcb_pt(p[0], p[1]) ];
kbpcb_w = 88.5; kbpcb_d = 70.5; kbpcb_thickness = 1.51; // real, updated board

kbpcb_standoffs = [
  for (h = [ [163.275090,-42.745040,3.2],[83.000000,-32.000000,3.2],
             [83.000000,-92.500000,3.2],[163.500000,-92.433792,3.2] ])
    [ kbpcb_pt(h[0],h[1])[0], kbpcb_pt(h[0],h[1])[1], h[2] ]
];

pico_pos = kbpcb_pt(98.575, -53.97);
// The installed 1x16 ribbon header (raw x 118.8..159.4): its CENTRE, in board-local x, is what gets centred on the case (under the
// keyboard's ribbon cable / on the main case's centreline) -- NOT the Pico/USB jack, which sits 40.5mm to its left on the board and
// has no need to be centred.
kbpcb_hdr_cx = kbpcb_pt(139.1, 0)[0];   // = 60.1

// New on the updated board: 2 LEDs (D1/D2, 3mm round) and a tactile
// button (SW1) needing case access -- per direction. R1/R2 are just their
// current-limit resistors, no case feature needed.
// REAL component data, measured off Coco_pico_keyb.stl (the stuffed board; same KiCad frame as the
// STEP, Z=0 at the PCB bottom). LED/button X are the BODY centres, not the pad positions the earlier
// numbers used (113.5 / 119.46 / 126.5) -- those were 1.1 / 1.3 / 2.3 mm off the real parts.
kbpcb_led1_pos = kbpcb_pt(114.60, -30.0);  // D1  (body x 113.27..115.93)
kbpcb_led2_pos = kbpcb_pt(120.73, -30.0);  // D2  (body x 119.23..122.24)
kbpcb_button_pos = kbpcb_pt(128.75, -31.0); // SW1 (cap x 125.05..132.45, 7.4 wide, 6.9 tall)
kbpcb_led_z = 5.43;       // LED lens centre above the PCB top
kbpcb_btn_z = 3.49;       // button cap centre above the PCB top
kbpcb_usb_x = 98.33;      // USB jack centre X (jack is 11.9 wide, 3.7 tall)
kbpcb_usb_z = 1.93;       // USB jack centre above the PCB top
kbpcb_comp_above = 8.62;  // TALLEST part above the PCB top (the 2.54mm headers)
kbpcb_pin_below  = 2.4;   // pin tails below the PCB bottom
kbpcb_edge_poke  = 0.33;  // the USB jack pokes this far past the board's USB edge

// ---- SHARED FACEPLATE WINDOW ---------------------------------------------------------------------------------------
// The keyboard's back-of-board wall and the main case's front wall carry the SAME window, closed by the SAME printed plate
// (keyboard_faceplate): USB / LED / button openings for a controller board, sitting 1.2mm from the plate exactly as the
// board sits in the keyboard. Both boards are positioned by their ribbon header (on the case centreline), so a plate centred
// on that line lines up with either board. Nothing is screwed on: the plate SNAPS in from the outside. Each end of the plate has
// a flexible finger (a slot cut beside the end, in the plate's own plane so it flexes along the layers) with a barb on its tip
// that clicks into a groove in the window's end wall. The plate seats against solid on its inner side (the keyboard's tunnel
// ends, the main case's stop blocks). To release, push it out from the inside, or pry the ends. With the plates out, the two
// windows line up into one tunnel through the seam (main X 70..210 = keyboard kx 97..237) for the keyboard ribbon, and the
// bridge plate crosses it.
fp_len = 140;        // window length (X), centred on the header line
fp_z0 = 3;           // window bottom (both frames: the keyboard's floor top; main: just above its 2.4 floor)
fp_z1 = 19;          // KEYBOARD window top only, now: the board's tallest part at the edge tops out ~z 16, and above this the keyboard's own
                      // tunnel roof continues (see kb_plate_slot()). The main bottom uses main_fp_z1 below instead -- its front wall is only
                      // parting_h (21.85) tall, and fp_z1=19 left just a ~2.85mm sliver of wall above the window there, too thin to survive
                      // printing/handling. main_fp_z1 runs the window and plate all the way up to the parting line instead, removing that
                      // sliver entirely (the TOP shell's own front wall picks up right where the plate leaves off).
main_fp_z1 = parting_h;   // flush with the parting line -- no clearance gap left above it (0.3mm still showed as a visible sliver in F6)
fp_t = 2.7;          // plate thickness
fp_clr = 0.1;        // press-fit clearance per side -- tune on a test fit (FDM holes run small)
fp_out_gap = 0.1;    // plate outer face sits this far inside the wall's outer face
// snap fingers
fp_finger_l = 13;    // finger length (Z), from the plate's bottom edge up to where it is joined to the plate
fp_finger_w = 1.6;   // finger width (X): 1.6 x 13 flexes ~0.6mm at ~0.7% strain
fp_slot_w   = 0.8;   // slot beside the finger (room to flex)
fp_barb_h   = 0.6;   // how far the barb sticks out of the plate's end face
fp_barb_z0  = 0.4;   // barb starts this far above the plate's bottom edge ...
fp_barb_zl  = 4;     // ... and is this long
fp_groove_clr = 0.15;
// Barb profile in (u = out of the plate's end, v = up the plate's thickness from its inner face). The plate goes in inner face
// first, so the leading flank (small v) is the gentle one (~40 deg) and the trailing flank (large v) is steeper (~50 deg):
// easy to push in, deliberate to pull out.
module fp_barb_2d(grow = 0) {
    offset(delta = grow) polygon([[-0.2, 0.6], [fp_barb_h, 1.5], [fp_barb_h, 1.7], [-0.2, 2.2]]);
}
// x0/x1: the plate's two end faces; y0: its inner face; z0: its bottom edge (any frame -- keyboard or main)
module fp_barbs(x0, x1, y0, z0) {
    translate([0, 0, z0 + fp_barb_z0]) linear_extrude(height = fp_barb_zl) {
        translate([x0, y0]) mirror([1, 0]) fp_barb_2d();
        translate([x1, y0]) fp_barb_2d();
    }
}
module fp_grooves(x0, x1, y0, z0) {      // cut into the shell's window end walls
    translate([0, 0, z0 + fp_barb_z0 - fp_groove_clr]) linear_extrude(height = fp_barb_zl + 2*fp_groove_clr) {
        translate([x0, y0]) mirror([1, 0]) fp_barb_2d(fp_groove_clr);
        translate([x1, y0]) fp_barb_2d(fp_groove_clr);
    }
}
module fp_finger_slots(x0, x1, y0, z0) {
    translate([x0 + fp_finger_w, y0 - 1, z0 - 1]) cube([fp_slot_w, fp_t + 2, fp_finger_l + 1]);
    translate([x1 - fp_finger_w - fp_slot_w, y0 - 1, z0 - 1]) cube([fp_slot_w, fp_t + 2, fp_finger_l + 1]);
}

// ============================================================================
// GENERIC HELPERS
// ============================================================================
// The case's exterior is a plain rounded rectangle sized around the board's
// bounding box -- NOT contour-hugging the PCB's own notches/tab. Confirmed
// against a photo of a real stock case bottom: the OEM enclosure is a
// simple rounded rectangle, not shaped to the board outline. (An earlier
// version of this file offset the real board_outline directly for the case
// exterior; besides not matching the reference case, offsetting outward
// past small notches/teeth in that outline self-intersects and produces
// sawtooth artifacts. The board outline itself is still used for standoff
// and connector placement -- just not for the case's own exterior shape.)
// `rear` optionally overrides the -Y (rear-wall) margin independently of
// `margin` (used for +Y/front and both X/side walls) -- defaults to
// `margin` so every existing call site keeps its old symmetric behavior
// unless it explicitly opts in. See rear_margin above for why this exists.
module main_footprint_2d(margin, rear = margin) {
    translate([-margin, -rear])
        offset(r = corner_r) offset(delta = -corner_r)
            square([board_w + 2*margin, board_d + margin + rear]);
}

module solid_from_footprint(margin, z0, z1, rear = margin) {
    translate([0,0,z0])
        linear_extrude(height = max(0.01, z1 - z0))
            main_footprint_2d(margin, rear);
}

// True 3D edge fillet on the TOP rim and the 4 vertical corners -- the
// BOTTOM edge (where the case meets the build plate) is now filleted too,
// per direction ("rounded bottom edges... wherever we meet the build
// plate... a 2mm rounding... all around the perimeter"), but NOT the same
// way as an earlier, failed attempt: that one used a full minkowski (all
// 12 edges + 8 corners), which is geometrically correct for a
// free-floating rounded box, but WRONG for this shell -- minkowski with a
// sphere tapers the cross-section down to nearly nothing right at the
// bottom plane (a sphere only touches a flat plane at a single point),
// which starved the FLOOR of full material near the edges and broke the
// CN3 collar's connection to the floor. This bottom fillet uses the SAME
// hull()-cap technique as the top one instead, just with its own (small,
// 2mm) radius -- the cross-section at z0 itself is inset by only br, not
// tapered to a point, and that inset is well clear of every interior
// feature's own clearance from the edge (case_margin/rear_margin, all
// >2mm) and fully resolved again by z0+br=2, well before the floor's own
// thickness (new_floor_t=2.4) even ends -- so nothing that actually
// attaches to the floor is affected, only the outer wall's own visible
// bottom edge. Opt-in (br defaults to 0, no bottom fillet) since the TOP
// shell also calls this same function with z0=parting_h -- that's the
// parting-line mating edge, not a build-plate surface, and must stay flat.
edge_fillet_r = 5;
bottom_fillet_r = 2;
module rounded_footprint_solid(margin, z0, z1, r = edge_fillet_r, rear = margin, br = 0) {
    union() {
        solid_from_footprint(margin, z0 + br, z1 - r, rear);
        hull() {
            translate([0, 0, z1 - r - 0.01])
                linear_extrude(0.01) main_footprint_2d(margin, rear);
            translate([0, 0, z1])
                linear_extrude(0.01) offset(delta = -r) main_footprint_2d(margin, rear);
        }
        if (br > 0)
            hull() {
                translate([0, 0, z0])
                    linear_extrude(0.01) offset(delta = -br) main_footprint_2d(margin, rear);
                translate([0, 0, z0 + br + 0.01])
                    linear_extrude(0.01) main_footprint_2d(margin, rear);
            }
    }
}

// Split into solid + hole so callers that need the pilot hole to survive
// being unioned with OTHER overlapping solid material (e.g. the cart
// support platform, which happens to sit right over a couple of these
// standoffs) can add the solid pegs in the union and cut all the holes in
// one later, outer difference() -- cutting the hole locally, inside this
// module, only works if nothing else solid gets unioned on top of it
// afterward, which is exactly what was silently filling some of them back
// in.
module standoff_peg_solid(x, y, hole_d, h, od = -1) {
    d = (od > 0) ? od : hole_d + 4.0; // od override for a deliberately thicker post
    translate([x, y, 0]) cylinder(d = d, h = h);
}
module standoff_peg_hole(x, y, hole_d, h) {
    translate([x, y, -0.5]) cylinder(d = hole_d - 0.2, h = h + 1); // self-tapping pilot
}
module standoff_peg(x, y, hole_d, h, od = -1) {
    difference() {
        standoff_peg_solid(x, y, hole_d, h, od);
        standoff_peg_hole(x, y, hole_d, h);
    }
}

module din_jack_cutout(d = 15.9, depth = 20) {
    // standard round panel-mount cutout, works for DIN-4/5/6/7/8 (shell OD standardized)
    rotate([-90,0,0]) cylinder(d = d, h = depth, center = false);
}

module rca_jack_cutout(d = 10.5, depth = 20) {
    rotate([-90,0,0]) cylinder(d = d, h = depth, center = false);
}

module rect_cutout(w, h, depth) {
    translate([-w/2, -depth/2, -h/2]) cube([w, depth, h]);
}

module cart_slot_cutout(w = 92, h = 13, depth = 20) {
    // standard 40-pos .1" edge-card envelope + margin; verify against real cart
    translate([-depth/2, -w/2, -h/2]) cube([depth, w, h]);
}

module louver_bank(n, slot_w, gap, run_len, cut_depth) {
    // n horizontal slots (elongated along X = run_len, thickness slot_w in Z),
    // stacked upward in Z, boring through in Y (cut_depth). Default
    // orientation suits a Y-facing wall (e.g. the rear panel); rotate the
    // whole call 90 deg about Z to bore an X-facing wall instead (e.g. the
    // left side panel) -- see main_louvers() for both uses.
    total = n*slot_w + (n-1)*gap;
    for (i = [0:n-1])
        translate([0, 0, -total/2 + i*(slot_w+gap)])
            translate([-run_len/2, -cut_depth/2, -slot_w/2])
                cube([run_len, cut_depth, slot_w]);
}

module louver_bank_vertical(n, slot_w, gap, run_len, cut_depth) {
    // Same idea as louver_bank(), but for a wall whose face normal is X
    // (the side walls): each slot runs VERTICALLY (long axis in Z, run_len
    // tall -- matching grooves that wrap DOWN from the roofline) and the n
    // slots are stacked along Y instead of Z. Bores through in X (cut_depth).
    total = n*slot_w + (n-1)*gap;
    for (i = [0:n-1])
        translate([0, -total/2 + i*(slot_w+gap), 0])
            translate([-cut_depth/2, -slot_w/2, -run_len/2])
                cube([cut_depth, slot_w, run_len]);
}

// ============================================================================
// MAIN (MOTHERBOARD) SHELL
// ============================================================================

/* [Keyboard shell -- from the hand-built "split key frame.scad"] */
kb_w = 334;            // overall width  (kx)
kb_d_key = 155;        // depth of the shell up to the keyboard's rear (the original frame's depth)
// kb_extra_d / kb_d (depth added BEHIND the keyboard) are derived further down, next to the
// board-A parameters they depend on -- kb_cap_h (below) does not depend on them, which is
// what lets the main case's skirt be derived from it up here.
kb_pocket_depth = 14.7;  // depth of the keyboard pocket: top surface above the pocket floor (vertical)
kb_raise = 3;          // the whole keyboard plane -- pocket floor AND top surface -- sits this much higher than the
                       // frame's original (front height 14.7 -> 14.7 + kb_raise). Each mm buys ~7mm of board headroom-depth
                       // at 8 deg, at the cost of 1mm of main-case tower (the skirt follows the keyboard, see kb_match_skirt).
kb_front_h = kb_pocket_depth + kb_raise;   // shell height at the FRONT edge (the "bottom front height")
kb_slope_deg = 8;      // keyboard-plane rise toward the back (15 was tried; 8 gets the overall height back)
kb_feet = one_piece_bottom;  // false: this shell sits directly on the desk (no stick-on feet), so its
                       // base plane is new_foot_height BELOW the main case's floor plane --
                       // lowers the whole keyboard relative to the main case's skirt.
                       // true (one_piece_bottom): on the same feet as the main case, one flat underside
kb_dz = kb_feet ? 0 : new_foot_height; // kb-frame z = main-frame z + kb_dz
kb_wall = 3;
kb_corner_r = 8;
kb_left_relief_extra = 4.5;  // the rectangular relief under the keyboard's left end (x 9..33) is this much deeper than the
                             // original frame's 3mm (fit testing: the stock keyboard needed it) -> 7.5 below the pocket floor
kb_floor_ovals = false;  // the four oval cut-outs in the floor from the original frame (vestigial -- no venting need); solid floor
                        // is stiffer in twist and keeps dust out, for ~30g
kb_base_t = 3;         // floor slab everywhere (was 5 under the hollows / 3 only under the board:
                       // the thinner deck under the PCB worked, so the whole floor is that now)
kb_pcb_w = 316;        // stock keyboard PCB pocket
kb_pocket_left_ext = 0.55;   // pocket extended this far LEFT: with its holes on the bezel-screw pattern the keyboard's 315.25
                             // outline sits 0.6 off-centre (8.77..324.02) and the 316 pocket (9..325) cut into it by 0.23
kb_pcb_d = 124;
kb_pocket_front_ext = 2.75;  // pocket extended this far FORWARD (only its front edge moves; the keyboard and screws don't):
                             // the keyboard sits 0.3 behind the original front edge and the OEM opening is nearly as deep as
                             // the keyboard, so the bezel had no front rail. 0.3 + 2.5 of bezel + 0.25 clearance.
kb_pocket_corner_r = 2.5;  // radius on the pocket's four corners (was square). NOTE: a stock PCB with square corners needs
                         // ~1.0mm of relief at each corner to seat (r*(sqrt2-1)) -- round/chamfer its corners, or set this to 0.
// The top stops rising here (flat shelf behind the keyboard) -- the height the
// shell would have had at its original depth, so kb_extra_d adds room, not height.
kb_cap_h = kb_front_h + tan(kb_slope_deg) * (kb_d_key - 2*kb_corner_r);
kb_x0 = board_w/2 - kb_w/2;   // main-frame X of the keyboard's left edge (centered on the main case)
kbpcb_screw_boss_h = 6; // was 3, raised per direction ("2 to 3 more mm height...
                         // for a bit more screw grab") -- still low/flush
                         // compared to the original 10mm freestanding pillar,
                         // just with more real self-tap thread engagement now.
// Board A (Pico, coco-keyboard -> USB), rotated 180deg from board B in the main case.
kbA_setback = kbpcb_edge_poke + 0.7;   // board's USB edge -> the inner face of the wall that sits AT the PCB's edge. The
                       // USB jack pokes 0.33mm past the edge, so this leaves 0.7mm to the jack.
// Layout along ky (front -> back):  ... keyboard pocket | board A (where headroom under the keyboard plane puts
// it) | 1mm | WALL (kb_wall) | CABLE BAY (kb_cable_bay_d, open at the back face toward the computer) |.
// The shell's roof carries on over the bay: that overhang hides the cable while docked, and the open bay gives
// the plug that sticks out of the main case's front wall somewhere to go as the keyboard is brought up.
kb_cable_bay_d = one_piece_bottom ? 8 : 12;   // depth of the bay behind the PCB-edge wall (was 20): needs a RIGHT-ANGLE / low-profile
                       // USB plug -- the plug-to-plug distance across the seam is kbA_setback + wall + this + the main case's
                       // wall/clearance (see the echo). One-piece: 8, to shorten the shelf; each plug then has ~13mm to the far wall.
kb_bay_x0 = kb_w/2 - fp_len/2;   // bay X extent = the shared faceplate window, centred on the header line (kx 97..237): it takes in A's
kb_bay_x1 = kb_w/2 + fp_len/2;   //   USB jack (kx ~126) and where board B's opening lands in this frame (kx ~198..218), ~81mm apart
kbA_flipped = false;   // true: board mounted UPSIDE DOWN (components hang below the PCB, bare
                       // face up) -> almost no headroom needed under the keyboard, but the
                       // bay needs depth below the PCB instead (see the echo() lines)
kbA_flip_pcb_z = kb_base_t + kbpcb_comp_above + 0.5;   // PCB height when flipped: real component depth (8.6) + clearance
kbA_floor_z = kb_base_t; // bay floor == the general floor now (3mm)
kbA_pcb_z = kbA_flipped ? kbA_flip_pcb_z : kbpcb_screw_boss_h; // PCB slab bottom above the shell
                       // base plane (upright default 6 = board B's height above the main floor)
kb_usb_w = 20; kb_usb_h = 11; // same opening size as main_usb_passthrough_front()
// Headroom the board needs under the keyboard PCB plane (whose height above the base at the board's front
// edge is ky*tan(slope)): the PCB plus whatever stands on it (upright: the tallest header; flipped: only a
// screw head). It sets how far back the board sits (kbA_edge_ky, below) -- shallower slopes push it back.
// Board A's back (USB) edge: the board sits under the keyboard plane, whose height above the base at the board's
// FRONT edge is ky*tan(slope). That front edge has to be far enough back to clear the PCB plus the tallest part
// (upright: the real 8.62mm headers; flipped: only a screw head) -- so shallower slopes push the board back.
// Never further forward than the original frame's rear rim (kb_d_key - kb_wall - kbA_setback).
// Each tall part only needs the keyboard plane to clear IT, at ITS distance behind the board's front edge -- not the
// whole board at the front edge. [ly of the part's front-most point, its height above the PCB top], from the
// stuffed-board STL. The frontmost 1x16 header footprint is NOT populated, so it is not listed; if it ever is, add it.
kbA_parts = [ [0, 0],            // the bare PCB
              [18.53, 3.58],     // Pico
              [19.37, 8.62],     // the installed 1x16 header (the tallest, and the front-most tall part)
              [33.47, 8.62],     // 1x4 header
              [50.23, 8.62],     // 2x5 header (J6)
              [53.20, 8.62],     // 1x2 header
              [62.28, 8.38],     // LED lenses
              [62.85, 7.09] ];   // button
function kbA_ylo_min() = kbA_flipped
    ? (kbA_pcb_z + kbpcb_thickness + 3 - kb_raise) / tan(kb_slope_deg)          // flipped: only a screw head stands up
    : max([ for (c = kbA_parts) (kbA_pcb_z + kbpcb_thickness + c[1] + 0.9 - kb_raise) / tan(kb_slope_deg) - c[0] ]);
kbA_edge_ky = max(ceil(kbA_ylo_min()) + kbpcb_d, kb_d_key - kb_wall - kbA_setback);
kbA_wall_y0 = kbA_edge_ky + kbA_setback;      // inner face of the PCB-edge wall
kbA_wall_y1 = kbA_wall_y0 + kb_wall;          // its back face = start of the cable bay
kb_d = kbA_wall_y1 + kb_cable_bay_d;          // overall depth (ky)
kb_extra_d = kb_d - kb_d_key;
kb_rear_h = kb_front_h + tan(kb_slope_deg) * (kb_d - 2*kb_corner_r);   // plane height at the rear cylinders (cutting height)
// Height of the keyboard's top at its back face (what the main case's front skirt meets). Normally the top stops rising
// at kb_cap_h and runs back flat (the shelf). One-piece: no flat shelf -- the keyboard plane carries on at kb_slope_deg
// right to the back face, so it flows straight into the main top's ramp (the tower rises with it).
kb_back_h = one_piece_bottom ? kb_front_h + tan(kb_slope_deg) * kb_d : kb_cap_h;
// The main case's front skirt is derived from the keyboard: the keyboard's flat shelf top
// (kb_cap_h, measured from ITS base = kb_dz below the main floor) meets the main case's
// front skirt top flush. The floppy-bay stack rises by the same amount (see bay_face_z0)
// so the ramp run and every bay Y position stay exactly as they were.
kb_match_skirt = true;

// ---- TOP SHELL STYLING: skirt + continuous slope, no flat "table" ----
// Per direction: the front has NO flat plateau -- a short vertical "skirt"
// (15-20mm) right where the top shell meets the bottom shell's parting
// line, then the roof climbs continuously at a fixed angle all the way back
// to the tall tower. The tower's own height is driven by what it actually
// needs to hold -- two side-by-side 3.5" floppy bays (see FLOPPY BAY below)
// -- not an arbitrary styling constant like the old front_deck_h/
// rear_tower_h were.
top_skirt_h_base = 8;
top_skirt_h   = kb_match_skirt ? (kb_back_h - kb_dz - parting_h) : top_skirt_h_base;
                      // ^ was a flat 8: now matches the keyboard shell's flat shelf top (kb_match_skirt).
                      // Vertical wall height above parting_h at the front edge -- reduced
                        // from 18 per direction ("straight up band interface to the base...
                        // can be reduced to 8mm")
top_slope_deg = 25;   // front-to-back roof slope, measured from VERTICAL per
                        // direction (NOT from horizontal) -- so this is a steep,
                        // near-vertical rise leaning back only 25 deg, not a
                        // gentle ramp. run = rise * tan(top_slope_deg), the
                        // opposite of the usual rise/tan(angle)-from-horizontal
                        // formula -- see top_ramp_run below.

// ---- FLOPPY BAY (2x, side by side, 3.5" front-loading from the tower's
// user-facing side, per direction) ----
// Real drive envelope -- a standard 3.5" floppy drive, NOT a distinct
// "half-height" 3.5" SKU (those aren't a commodity part the way half-height
// 5.25" drives were) -- PLACEHOLDER data (see CLAUDE.md's own PLACEHOLDER
// section) until checked against a real drive's datasheet.
floppy_w            = 101.6;
floppy_h            = 25.4;
floppy_d            = 120;   // real drive depth -- per direction, the specific part in mind
                               // is a Gotek drive emulator (~120mm deep), not a real
                               // full-depth 3.5" FDD; the tower now has ~137mm of
                               // available depth behind the bay face (see
                               // main_floppy_bay_brackets()), comfortably enough.
// Per-axis clearance added to the through-opening. A real print came back
// "about 3mm too wide and 2mm too tall" against the actual drive, so this
// replaces the old single floppy_fit_clear=3 (applied to both axes) --
// width clearance is now essentially zero (0.3mm, not a hard zero, so
// there's still SOME slip fit rather than a knife-edge tolerance) and
// height barely more than a friction fit. Worth confirming against the
// physical drive before committing another full print -- FDM holes often
// print a touch undersized, so this may still need easing.
floppy_fit_clear_w = 0.3;
floppy_fit_clear_h = 1.3;
floppy_bay_gap      = 20;    // divider width between the two bays -- widened from 10
                               // per direction ("a bit more separation between the bays")
floppy_bay_margin   = 20;    // decorative surround margin around the bay PAIR, LEFT/RIGHT only
floppy_bay_margin_v = 8;     // surround margin, TOP/BOTTOM -- kept much smaller than the L/R
                               // margin per direction ("much taller than it needs to be" --
                               // 20mm top AND bottom around a 25.4mm-tall opening was most
                               // of what drove the tower height, not anything structural)
floppy_face_w = 2*floppy_w + floppy_bay_gap + 2*floppy_bay_margin;
floppy_face_h = floppy_h + 2*floppy_bay_margin_v;

// Standard 3.5" drive side-mounting screw positions, measured from the
// drive's own FRONT bezel plane. REAL measurements off the user's own
// Gotek (front edge of each hole, per spec): 20mm and 79.2mm -- those are
// to the NEAR edge of the hole, not its center, so the screw-hole radius
// is added to get the true center offset used below. (Previous [12, 92]
// values were unverified placeholders and measured ~13-14mm off in
// practice -- confirmed by a real print: the drive stuck out that much
// when mounted through these holes.)
floppy_screw_front_offsets = [20 + m3_pilot_d/2, 79.2 + m3_pilot_d/2];
// Z height of the screw holes, up from the drive's own bottom edge. The
// generic 3.5"/floppy spec position is 12.7mm; the user's particular
// Gotek unit instead has its holes at 4.2mm. Drilling both lets either
// mount without forcing a specific drive.
floppy_screw_z_offsets = [4.2, 12.7];

// ---- Tower height, driven by the bay stack (not picked by hand) ----
bay_face_z0  = parting_h + 6 + 19.05 + (top_skirt_h - top_skirt_h_base); // rises with the skirt    // footer below the recessed face -- includes an
                                           // extra 3/4in (19.05mm) of clearance underneath
                                           // the bays per direction (was just 6mm); this
                                           // raises the whole bay assembly, and rear_tower_h
                                           // with it, since rear_tower_h is still derived
                                           // from bay_face_z0 + floppy_face_h + roof margin
bay_face_z1  = bay_face_z0 + floppy_face_h;
rear_tower_h = bay_face_z1 + 8;          // + roof clearance above the bays
// The drive openings' bottom edge, projected back as a horizontal plane: the drive screw-hole heights
// (floppy_screw_z_offsets) are measured up from THIS line, not from the surround's bottom edge (bay_face_z0).
floppy_opening_z0 = bay_face_z0 + floppy_bay_margin_v - floppy_fit_clear_h/2;
// Drive brackets now stop just below the lowest screw hole (was: all the way down to bay_face_z0), with rounded free corners.
floppy_rail_hole_margin = 6;                                              // lowest hole centre -> rail's bottom edge
floppy_rail_corner_r    = 4;                                              // radius on the rail's free corners
floppy_rail_z0 = floppy_opening_z0 + min(floppy_screw_z_offsets) - floppy_rail_hole_margin;
front_deck_h = parting_h + top_skirt_h;  // front wall height (the "skirt")

// Ramp run needed to climb from the front skirt to the tower height at
// top_slope_deg -- this, not an arbitrary fraction of the case depth (the
// old rear_break_front/rear_break_back), is what determines where the flat
// tower actually begins. top_slope_deg is measured from VERTICAL (per
// direction), so run = rise * tan(angle) here, not rise / tan(angle).
top_ramp_run   = (rear_tower_h - front_deck_h) * tan(top_slope_deg);
top_front_wall_y = board_d + case_margin; // same value as main_front_y (defined
                                            // later) -- recomputed here since
                                            // top-level plain expressions
                                            // evaluate in file order, and
                                            // main_front_y isn't assigned yet
                                            // at this point in the file.

main_depth = board_d + case_margin + rear_margin;
main_break2_y = top_front_wall_y;         // no flat front section at all -- the ramp
                                            // runs straight to the front wall itself
main_break1_y = max(main_break2_y - top_ramp_run, 5); // clamped so it can never go
                                                          // negative/degenerate if the
                                                          // ramp run ever exceeds the
                                                          // available depth

// Shared Y positions for the wrap-around groove pattern (see
// main_louvers(), which builds the whole continuous side-corner-top sweep
// per groove_y).
function groove_y_positions(n, slot_w, gap, center_y) =
    let(total = n*slot_w + (n-1)*gap)
    [for (i = [0:n-1]) center_y - total/2 + i*(slot_w+gap)];
groove_pitch = louver_w + louver_gap;
groove_span = main_break1_y * 0.95; // per direction: "3 or four more" grooves,
                                       // continuing across the top and around to
                                       // the other side -- wider span than before
groove_count = max(1, min(louver_count, floor((groove_span + louver_gap) / groove_pitch))) + 4;
groove_center_y = main_break1_y / 2;
groove_ys = groove_y_positions(groove_count, louver_w, louver_gap, groove_center_y);

// Y=0 is the REAR (connector) edge, so the tall louvered tower -- which
// houses the rear panel and, per the reference photo, sits at the BACK of
// the machine -- is clipped to LOW Y. The low front deck (keyboard side)
// is clipped to HIGH Y.
//
// IMPORTANT: do NOT hull() the whole board footprint against itself to loft
// the wedge -- the board outline is concave (tab + relief notches) and
// hull() convexifies everything it touches, which is what turned this into
// a smooth curved boat hull instead of a case. Instead: extrude the REAL
// (non-convex) outline straight up to full height, and separately clip that
// extrusion's height as a function of Y only, using a wedge block built from
// two axis-aligned boxes that share the same X range -- hull() of those two
// stays a clean flat-flat-ramp profile because there's no X variation for it
// to convexify.
// The wedge's outer roofline height as a function of Y alone -- flat at
// h_rear for y <= break1, flat at h_front for y >= break2, straight ramp
// between. Used to size anything that needs to reach from the parting-line
// rim up to the actual roof at a given Y (e.g. the top/bottom screw bosses).
function local_wedge_h(y, h_rear, h_front) =
    (y <= main_break1_y) ? h_rear :
    (y >= main_break2_y) ? h_front :
    h_rear + (h_front - h_rear) * (y - main_break1_y) / (main_break2_y - main_break1_y);

module y_wedge_block(x0, x1, h_rear, h_front) {
    // The rear/front boxes must start well before the footprint's actual
    // outer edges (-rear_margin at the rear, main_depth+case_margin at the
    // front) or this block has NO material in the gap, silently deleting
    // whatever it's intersected with there -- a +/-1mm margin here (this
    // bug's previous value) is not generous enough once case_margin=6 is
    // taken into account, and it deleted the entire rear wall face.
    //
    // BUT: that front-side margin must NOT be part of the hull() that forms
    // the ramp, or the ramp stops being "flat-ramp-flat" at all. hull()ing
    // the rear box directly against the (far-extended) front box makes the
    // hull's own convex boundary run from the rear box's top corner
    // (main_break1_y, h_rear) all the way to the FRONT box's FAR corner
    // (main_depth+margin, h_front) -- the front box's NEAR corner (right at
    // main_break2_y, where the ramp is supposed to end) sits strictly below
    // that straight line and never becomes a hull vertex, so the "ramp"
    // silently drags on almost to the outer front wall instead of ending at
    // main_break2_y like local_wedge_h() (used everywhere else to size
    // features against this same roofline, e.g. the top/bottom screw bosses)
    // assumes. Caught via a disconnected boss: local_wedge_h() said the roof
    // was already down at h_front by the boss's Y, but the real roof there
    // was still ~11mm higher mid-ramp, so the boss fell short of it.
    // Fix: hull() only the rear box against a paper-thin anchor slice
    // sitting exactly at main_break2_y (so the ramp really ends there), then
    // union() in the far-extended flat front box separately -- it still
    // reaches past the real front wall, but as a plain flat slab, not a
    // hull() operand that can bend the ramp's endpoint.
    margin = 50;
    union() {
        hull() {
            translate([x0, -margin, 0]) cube([x1-x0, main_break1_y+margin, max(h_rear, 0.01)]);
            translate([x0, main_break2_y, 0]) cube([x1-x0, 0.01, max(h_front, 0.01)]);
        }
        translate([x0, main_break2_y, 0]) cube([x1-x0, (main_depth-main_break2_y)+margin, max(h_front, 0.01)]);
    }
}

// ---- BOTTOM shell: a plain shallow tray up to parting_h, flat, no wedge --
// per a photo of a real stock case bottom (floor, standoffs, no connector
// cutouts, no styling). Much simpler than the wedge: just the rounded-rect
// footprint, extruded straight up.
module main_bottom_outer_solid() {
    // r=0: the bottom shell's own TOP edge (Z=parting_h, where it meets
    // the top shell's parting line) must stay a plain flat/sharp wall, not
    // rounded_footprint_solid()'s default top-edge treatment (edge_fillet_r
    // = 5mm) -- per direction, that top edge is a deliberate ~1.6mm
    // vertical lip above the standoff height (parting_h = standoff_height
    // + pcb_edge_lip_height), and a 5mm chamfer completely swallows a
    // feature that short, replacing it with what reads as a bevel instead
    // of the intended lip ("too short... has a 45deg inward bevel").
    // br=bottom_fillet_r (2mm) is unaffected -- that's the OTHER end
    // (Z=0, the build plate), a separate, deliberately-requested fillet.
    rounded_footprint_solid(case_margin, 0, parting_h, r = 0, rear = rear_margin, br = bottom_fillet_r);
}
module main_bottom_inner_cavity() {
    // open at the top rim (pokes through by 5mm so there's no ceiling)
    solid_from_footprint(case_margin - wall, new_floor_t, parting_h + 5, rear = rear_margin - wall);
}

// ---- TOP shell: the styled wedge (tower/ramp/deck + louvers), spanning
// from parting_h up to the roofline. Same footprint-extrude +
// height-clipping-wedge-block technique as before, just z-shifted to start
// at parting_h instead of 0.
// Rounds a single straight OUTER (convex) edge -- where a vertical wall
// meets the flat top -- with a TRUE quarter-circle fillet, not the
// chamfer the hull()-between-two-flat-slabs technique (rounded_footprint_
// solid's own top cap, used elsewhere) actually produces: hull() of two
// parallel flat plates at different heights/insets tapers LINEARLY between
// them, which is a 45-degree-ish bevel, confirmed by rendering a cross-
// section -- not the curved "5mm radius" round asked for here. This uses
// the standard notch-cut-plus-cylinder construction instead: within the
// r x r square where the sharp corner would be, subtracting a cylinder
// (radius r, axis along the edge's own run direction) from that square
// leaves exactly the sharp sliver beyond the round; subtracting THAT
// sliver from the box leaves a true quarter-circle profile.
// round_edge_over: every cut below used to box exactly up to the material's own outer faces (X=wall, Z=z1) -- a
// textbook degenerate-CSG coincident-face situation (same class already flagged elsewhere in this file, e.g. the
// "Padded 2mm" note on main_top_outer_solid), and the actual cause of the non-manifold edges Bambu Studio was
// flagging: confirmed by isolating a single groove position and the outer solid together, then tracing the exact
// duplicated triangle to this cut's own box, present even with every groove disabled (a small pre-existing baseline
// the grooves then multiplied wherever they crossed the same coincident line). Overshooting the box's own OUTER faces
// (the ones that aren't part of the visible rounded profile) by this amount gives real volume overlap instead.
round_edge_over = 1;
module round_top_edge_x(edge_y, r, x0, x1, z1) {
    // Edge running along X, where Z=z1 (top) meets Y=edge_y (a wall),
    // material at Y > edge_y.
    over = round_edge_over;
    difference() {
        translate([x0, edge_y - over, z1-r]) cube([x1-x0, r + over, r + over]);
        translate([x0, edge_y+r, z1-r]) rotate([0,90,0]) cylinder(r=r, h=x1-x0);
    }
}
module round_top_edge_y(edge_x, dir, r, y0, y1, z1) {
    // Edge running along Y, where Z=z1 (top) meets X=edge_x (a wall).
    // dir=-1: material at X < edge_x (a max-X wall); dir=+1: material at
    // X > edge_x (a min-X wall).
    cx = edge_x + dir*r;
    over = round_edge_over;
    x0 = dir > 0 ? edge_x - over : edge_x - r;
    x1 = dir > 0 ? edge_x + r    : edge_x + over;
    difference() {
        translate([x0, y0, z1-r]) cube([x1 - x0, y1-y0, r + over]);
        translate([cx, y0, z1-r]) rotate([-90,0,0]) cylinder(r=r, h=y1-y0);
    }
}
module main_top_edge_round_cut() {
    // Per direction: round the top-back/top-left/top-right edges (NOT
    // top-front, which is the sloped ramp -- there's no sharp horizontal
    // edge there to round) with a 5mm radius. Y-range for the left/right
    // edges overshoots slightly past main_break1_y (the flat tower's own
    // front extent); harmless, since the wedge is already well below
    // z1-r there and this cut has nothing to remove past that point.
    r = edge_fillet_r;
    z1 = rear_tower_h;
    min_x = -case_margin;
    max_x = board_w + case_margin;
    x_span0 = min_x - 1;
    x_span1 = max_x + 1;
    y0 = -rear_margin - 1;
    y1 = main_break1_y + 1;
    round_top_edge_x(-rear_margin, r, x_span0, x_span1, z1);
    round_top_edge_y(max_x, -1, r, y0, y1, z1);
    round_top_edge_y(min_x, 1, r, y0, y1, z1);

    // The two straight-edge cuts above overlap imperfectly right where the back edge meets each side edge (independent
    // circular cuts, not a true compound 3D fillet). Since corner_r and edge_fillet_r are conveniently the same 5mm,
    // this compound corner is exactly a spherical octant: same notch-minus-primitive technique as the straight edges,
    // just with a sphere instead of a cylinder, cleanly covering both cuts' overlap. Overshoots ALL SIX faces by
    // round_edge_over: not just the three that land on the material's own outer surface, but also the two (at
    // min_x+r / max_x-r) that land exactly on round_top_edge_y's OWN cut boundary right next door -- two different
    // subtractions meeting at an exact shared plane is the same degenerate situation, just cut-vs-cut instead of
    // cut-vs-material.
    over = round_edge_over;
    difference() {
        translate([min_x - over, -rear_margin - over, z1-r-over]) cube([r + 2*over, r + over, r + 2*over]);
        translate([min_x+r, -rear_margin+r, z1-r]) sphere(r=r);
    }
    difference() {
        translate([max_x-r-over, -rear_margin - over, z1-r-over]) cube([r + 2*over, r + over, r + 2*over]);
        translate([max_x-r, -rear_margin+r, z1-r]) sphere(r=r);
    }
}

// Mirror of round_top_edge_x, for a wall where material/cavity is on the
// Y < edge_y side instead of Y > edge_y (the front wall, where the
// interior extends toward the REAR from there).
module round_top_edge_x_neg(edge_y, r, x0, x1, z1) {
    difference() {
        translate([x0, edge_y-r, z1-r]) cube([x1-x0, r, r]);
        translate([x0, edge_y-r, z1-r]) rotate([0,90,0]) cylinder(r=r, h=x1-x0);
    }
}

// Small STRUCTURAL fillet at the INSIDE corner where the ceiling meets
// the walls, all the way around -- per direction. Same notch-cube-minus-
// cylinder technique as main_top_edge_round_cut() above (a true round,
// not the hull()-based chamfer used elsewhere), just applied the other
// way: this shape gets SUBTRACTED FROM THE CAVITY (see its use in
// main_case_top(), added to the same protection union that already keeps
// the floppy duct/roof-fill and topbottom boss footprints solid) rather
// than from the outer solid, so removing it from the cavity is what
// LEAVES the fillet's own material behind in the final shell -- the
// opposite of cutting a fillet into already-solid material.
//
// The rear and front walls are each flat (a single z1 applies along
// their whole run), but the side walls' own ceiling height follows the
// sloped ramp -- swept in many small segments using local_wedge_h() at
// each one (same principle as the corner boss's own slope-following
// construction), staying purely algebraic to avoid the CGAL mesh-
// robustness issues a real geometry intersection would risk here.
ceiling_fillet_r = 3;
module round_ceiling_edge_y_swept(edge_x, dir, r, y0, y1, h_rear, h_front, n = 100) {
    step = (y1 - y0) / n;
    for (i = [0 : n-1]) {
        ys = y0 + i*step;
        ye = ys + step + 1; // generous overlap between segments for a clean union
        ym = ys + step/2;
        z1 = local_wedge_h(ym, h_rear, h_front);
        round_top_edge_y(edge_x, dir, r, ys, ye, z1);
    }
}
module main_ceiling_fillet_protect() {
    r = ceiling_fillet_r;
    right_inner_x = -(case_margin - wall);
    left_inner_x  = board_w + (case_margin - wall);
    rear_inner_y  = -(rear_margin - wall);
    front_inner_y = main_front_y - wall;
    ceil_rear  = rear_tower_h - wall;
    ceil_front = front_deck_h - wall;
    // rear wall -- flat, entirely within the flat-roof zone
    round_top_edge_x(rear_inner_y, r, right_inner_x - r, left_inner_x + r, ceil_rear);
    // front wall -- flat at the skirt's own height
    round_top_edge_x_neg(front_inner_y, r, right_inner_x - r, left_inner_x + r, ceil_front);
    // side walls -- swept the full length, following the ramp's own slope
    round_ceiling_edge_y_swept(right_inner_x, 1, r, rear_inner_y - r, front_inner_y + r, ceil_rear, ceil_front);
    round_ceiling_edge_y_swept(left_inner_x, -1, r, rear_inner_y - r, front_inner_y + r, ceil_rear, ceil_front);
}

module main_top_outer_solid() {
    // Padded 2mm above the wedge block's own max height so the two solids
    // being intersected never share an exactly coincident flat top plane --
    // see main_bottom/top_inner_cavity below for why that matters (CGAL
    // treats an exact coincidence as degenerate and renders visible sliver
    // artifacts).
    difference() {
        intersection() {
            solid_from_footprint(case_margin, parting_h, max(rear_tower_h, front_deck_h) + 2, rear = rear_margin);
            y_wedge_block(-500, board_w+500, rear_tower_h, front_deck_h);
        }
        main_top_edge_round_cut();
    }
}
module main_top_inner_cavity() {
    // Inset by `wall` in XY; open at the BOTTOM rim (pokes through below
    // parting_h so it mates with the open-top bottom tray) and capped with
    // a proper `wall`-thick roof at the top this time (unlike the bottom
    // tray, the top shell actually needs a ceiling).
    extra = 5;
    intersection() {
        solid_from_footprint(case_margin - wall, parting_h - extra, max(rear_tower_h, front_deck_h) - wall + 2, rear = rear_margin - wall);
        y_wedge_block(-500, board_w+500, rear_tower_h - wall, front_deck_h - wall);
    }
}

// ---- Groove geometry: half-round profile, continuous/unbroken across the
// newly-rounded top corner -- per direction ("the groove should be half
// round, as if a half cylinder was removed" + "continuous/unbroken...
// across that radius"). A cylinder (or, along the curved corner, a chain
// of hulled spheres) with its axis running ALONG the groove's own path and
// positioned exactly AT the material's outer surface only ever removes the
// "inward half" of its own cross-section -- the other half is in open air
// -- which is exactly a half-round channel; sweeping that same radius
// along the whole path (straight side wall -> the 5mm corner arc ->
// straight top) keeps it visually unbroken the whole way around.
groove_r = louver_w / 2;

module groove_vertical_side(wall_x, dir, y, z0, z1, through_depth) {
    // Half-round entry (cylinder axis along Z, at the wall's own outer
    // surface) + a plain straight continuation so it actually penetrates
    // the full wall thickness for ventilation -- the half-round alone
    // (depth = groove_r) can't reach through a case_margin-thick wall.
    // z1 is exactly where the corner sweep's own arc starts (see side_vent_z1) -- extending a hair past it (same
    // round_edge_over idea as the top-edge rounding cuts) gives genuine overlap there instead of a tangent touch.
    // z0 (this cut's own bottom cap) also used to land flush with the wall's outer surface at an otherwise unrelated
    // Z, which was leaving the same kind of coincident-face artifact -- overshot by the same margin below.
    x_start = dir > 0 ? wall_x : wall_x - through_depth;
    z0e = z0 - round_edge_over;
    zh = (z1 + round_edge_over) - z0e;
    union() {
        translate([wall_x, y, z0e]) cylinder(r = groove_r, h = zh);
        translate([x_start, y - groove_r, z0e])
            cube([through_depth, groove_r*2, zh]);
    }
}

// Was a chain of hulled sphere-pairs along the sampled arc: adjacent segments shared EXACTLY one sphere at their
// common endpoint -- a knife-edge touch, not real volume overlap -- which left a degenerate coincident face at every
// one of those junctions (confirmed: disabling just this sweep dropped main_top_right's non-manifold edge count from
// ~1300 to 125; padding the segments to overlap didn't help, it just moved the seams). A torus segment -- one true
// rotate_extrude, no internal seams at all -- is what the shape actually is (a round tube of radius groove_r, swept
// along the same arc as the case's own edge fillet), so build it as one directly instead.
module groove_corner_sweep(cx, cz, R, theta0, theta1, y) {
    translate([cx, y, cz]) rotate([90, 0, 0]) rotate([0, 0, theta0])
        rotate_extrude(angle = theta1 - theta0, $fn = 96)
            translate([R, 0]) circle(r = groove_r, $fn = 24);
}

module groove_horizontal_top(z, y, x0, x1) {
    translate([x0, y, z]) rotate([0,90,0]) cylinder(r = groove_r, h = x1 - x0);
}

module main_louvers() {
    // Vents go on the left/right side walls only -- per direction, no
    // vents on the back wall. Only the portion of the tower that's part of
    // the TOP shell (parting_h..rear_tower_h) is available for the bank.
    min_x = -case_margin;
    max_x = board_w + case_margin;
    r = edge_fillet_r; // matches the top-edge rounding radius exactly, so the
                         // corner sweep below follows the SAME arc as the case's
                         // own rounded edge -- true continuity, not an approximation
    side_vent_z0_base = max(41.85 + 2, parting_h + 6);
    // min-X wall also carries the CN1 cart slot (a much taller cutout than
    // the rear connector notches, per direction it's now 108x23 real size
    // + margin) -- side_vent_z0_base only cleared the REAR connectors'
    // height, not this. The vertical grooves' own bottom end was starting
    // BELOW the cart slot's own top, cutting straight through/into ground
    // the cart slot already opened up -- unprintable per direction ("the
    // vent cuts on the right just go all the way to the cart cutout").
    // Raised 8mm clear of the cart slot's own top, min-X wall only; max-X
    // (no cart slot) keeps the lower, unrestricted floor.
    cart_slot_top_z = parting_h + cart_slot_h + cart_slot_margin_h;
    min_x_vent_z0 = max(side_vent_z0_base, cart_slot_top_z + 8);
    max_x_vent_z0 = side_vent_z0_base;
    side_vent_z1 = rear_tower_h - r; // stop right where the corner arc begins
    top_x0 = min_x + r; // where the top groove begins, past the left corner arc
    top_x1 = max_x - r; // where the top groove ends, before the right corner arc

    for (y = groove_ys) {
        groove_vertical_side(min_x, 1, y, min_x_vent_z0, side_vent_z1, louver_depth*4);
        groove_vertical_side(max_x, -1, y, max_x_vent_z0, side_vent_z1, louver_depth*4);
        groove_corner_sweep(min_x + r, rear_tower_h - r, r, 180, 90, y);
        groove_corner_sweep(max_x - r, rear_tower_h - r, r, 0, 90, y);
        groove_horizontal_top(rear_tower_h, y, top_x0, top_x1);
    }
}

// U-shaped notches open at the TOP shell's own bottom rim (parting_h),
// rising `height` above it -- per a photo of a real stock case, which cuts
// all its connector-panel openings in the TOP shell, not the bottom. This
// also happens to be far more printable than a fully-enclosed round hole
// mid-wall: printed upside down (rim facing up on the bed), each notch is
// just an open channel with zero overhang, no supports needed. Sizes are
// still the same placeholder commodity-connector envelopes flagged in the
// file header -- only the shape (closed hole -> open notch) changed here.
module rim_notch_y(x, wall_y, width, height, depth, r = 0) {
    // r > 0: rounded-corner cutout (per direction, "round them off a bit"),
    // reusing the same rounded_rect_prism_y() helper the floppy bay notch
    // uses. r = 0 (default): the original sharp-cornered cutout.
    if (r > 0)
        rounded_rect_prism_y(x - width/2, x + width/2, parting_h - 1, parting_h + height, wall_y, wall_y + depth, r);
    else
        translate([x - width/2, wall_y, parting_h - 1])
            cube([width, depth, height + 1]);
}
module rim_notch_x(wall_x, y, width, height, depth, dir = -1, taper = 0, taper_grow = 0) {
    // dir=-1: wall_x is a max-X (right, in the old pre-mirror sense) wall,
    //         cut inward toward -X.
    // dir=+1: wall_x is a min-X wall, cut inward toward +X. Cart slot uses
    //         this now that it's on the min-X wall (post board_pt mirror).
    // taper > 0: flares the opening at the wall's own OUTER face, wider by
    //            taper_grow (total, split across width and height) right
    //            at the surface, narrowing back down to the nominal
    //            width x height over a `taper` mm run -- a lead-in funnel
    //            to help guide something into the slot by feel.
    x0 = (dir < 0) ? wall_x - depth : wall_x;
    if (taper > 0) {
        x_in = (dir < 0) ? wall_x - taper : wall_x + taper; // taper's inward (nominal-size) end
        outer_off = (dir < 0) ? -0.01 : 0;
        inner_off = (dir < 0) ? -0.01 : 0;
        hull() {
            translate([wall_x + outer_off, y - (width+taper_grow)/2, parting_h - 1])
                cube([0.01, width+taper_grow, height+taper_grow+1]);
            translate([x_in + inner_off, y - width/2, parting_h - 1])
                cube([0.01, width, height + 1]);
        }
    }
    translate([x0, y - width/2, parting_h - 1])
        cube([depth, width, height + 1]);
}

// Rear-panel USB-C power input -- replaces the OEM power header (out of
// scope to reuse, see file header). Position along the rear wall is a
// placeholder: parked left of SW1 in open space, clear of every real
// connector; move it once you've picked an actual USB-C panel-mount part.
//
// Cutout disabled per direction (see its own commented-out call in
// main_connector_cutouts_top() below) -- kept overlapping the right-rear
// topbottom screw boss area even after moving it, and with no real part
// picked yet there's no reason to keep chasing a placeholder hole's exact
// position. usbc_power_x is unused while that's commented out; re-enable
// both once a real USB-C panel-mount part is chosen.
usbc_power_x = 5;

// Separate USB-C PD "trigger" board mount, back-left corner (per
// direction) -- clear of SW1 (the leftmost real rear connector, X~232) --
// so the board can be installed and powered with the case closed and
// nothing else populated yet; the trigger board's own USB-C port is
// accessible through this rear cutout, and everything else it needs
// (buttons, LEDs, output pads) lives on the board itself. First-pass
// generic dimensions -- common small USB-C PD trigger boards run around
// 22x22mm -- true up once you've picked the real part.
usbc_trigger_x        = 264; // moved 8mm right (was 272) -- the left-rear topbottom screw
                               // boss was nudged further in (see main_topbottom_screw_rf_inset)
                               // and its 10mm footprint now reaches to X~279, which the
                               // board's old position (span 261-283) overlapped
usbc_trigger_cut_w     = 14; // rear cutout for the USB-C port + cable clearance
usbc_trigger_cut_h     = 7;
usbc_trigger_board_w   = 22;
usbc_trigger_board_d   = 22;
// The real USB-C power board (no mounting holes): PCB 16.2 x 10.6 x 1.6, a TOP-MOUNT USB-C receptacle on one short edge
// overhanging the PCB by 1.3 (17.5 overall), the power cable soldered through-hole ~1mm in from the opposite edge. It
// sits in usbc_clip() (part "usbc_clip"), a small plate screwed onto the four bosses below -- the board is 10.6 wide and
// the gap between the bosses only ~9.4, so it rides on top of them -- and the rear cutout is centred on its port.
usbc_pcb_w      = 10.6;
usbc_pcb_l      = 16.2;
usbc_pcb_t      = 1.6;
usbc_conn_over  = 17.5 - 16.2;   // receptacle past the PCB edge
usbc_conn_h     = 3.2;           // receptacle height (typical); its centre sets the cutout height
usbc_clip_t     = 3.2;           // plate thickness (M3 pan/button heads sink into it)
usbc_trigger_boss_h    = 6;  // was 3, raised +3mm per direction ("raised about 3mm
                              // including taller standoff so I get better screw
                              // grabbing... self tapping m3 is fine for that in all
                              // conditions") -- same reasoning/precedent as the kbpcb
                              // boss height increase above.
usbc_trigger_hole_d    = m3_pilot_d; // self-tapping M3 confirmed fine here, per direction
usbc_trigger_cut_z     = 6;  // cutout vertical center above the floor
// NOTE: on usbc_clip() the port centre is at usbc_trigger_boss_h + usbc_clip_t + usbc_pcb_t + usbc_conn_h/2 (12.4), not
// here -- the bottom is deliberately left as is until the clip is test-fitted.
module main_usbc_trigger_cutout() {
    // Through the (bottom-shell) rear wall, at floor level -- the board
    // sits on its own low bosses (usbc_trigger_boss_h) just inside, so its
    // port lines up here rather than up at parting_h like the panel
    // notches in main_connector_cutouts_top() (those are TOP-shell, cut
    // relative to the parting line; this board is a BOTTOM-shell floor
    // feature, so it needs its own cut through this wall instead).
    translate([usbc_trigger_x - usbc_trigger_cut_w/2, -rear_margin - 1, usbc_trigger_cut_z - usbc_trigger_cut_h/2])
        cube([usbc_trigger_cut_w, rear_margin + 2, usbc_trigger_cut_h]);
}
module main_usbc_trigger_standoffs_solid() {
    inner_wall_y = -(rear_margin - wall);
    for (dx = [-1, 1])
        translate([usbc_trigger_x + dx*(usbc_trigger_board_w/2 - 3), inner_wall_y + 3, 0])
            standoff_peg_solid(0, 0, usbc_trigger_hole_d, usbc_trigger_boss_h);
    for (dx = [-1, 1])
        translate([usbc_trigger_x + dx*(usbc_trigger_board_w/2 - 3), inner_wall_y + usbc_trigger_board_d - 3, 0])
            standoff_peg_solid(0, 0, usbc_trigger_hole_d, usbc_trigger_boss_h);
}
module main_usbc_trigger_standoffs_holes() {
    inner_wall_y = -(rear_margin - wall);
    for (dx = [-1, 1])
        translate([usbc_trigger_x + dx*(usbc_trigger_board_w/2 - 3), inner_wall_y + 3, 0])
            standoff_peg_hole(0, 0, usbc_trigger_hole_d, usbc_trigger_boss_h);
    for (dx = [-1, 1])
        translate([usbc_trigger_x + dx*(usbc_trigger_board_w/2 - 3), inner_wall_y + usbc_trigger_board_d - 3, 0])
            standoff_peg_hole(0, 0, usbc_trigger_hole_d, usbc_trigger_boss_h);
}

// ---- USB-C power board clip (part "usbc_clip") ----
// Case frame (so it can be shown in place); printed plate-down as it sits. The board goes in front-first, tilted, its
// front corners under two small hooks in the ~1mm beside the receptacle; then the back is pressed down until a finger on
// each long side -- a free-standing wall in a slot through the plate, anchored at its front end, so it flexes sideways
// along its whole 9mm length instead of bending a short stub -- snaps a small hook over the PCB's top edge near the
// back. A low stop in front of the PCB edge (under the receptacle's overhang) takes the pull when a cable is unplugged
// (the corner hooks stop an angled pull from lifting the front over it);
// a low stop behind it takes the push when one is plugged in, and the cable's wires pass over it. A groove under the
// back edge clears the cable's through-hole legs (or flush-cut them). usbc_clip_lip is the knob if the fit is too
// tight or loose.
usbc_clip_clr    = 0.15;   // around the PCB
usbc_clip_lip    = 0.55;   // hook reach past the finger face (0.4 onto the PCB after usbc_clip_clr)
usbc_clip_fin_t  = 1.0;    // finger thickness
usbc_clip_slot   = 0.4;    // gap around each finger
usbc_clip_head_d = 6.2;    // counterbore for an M3 pan/button head
usbc_clip_head_h = 2.2;
usbc_conn_side   = 1.0;    // bare PCB either side of the receptacle (from the user's board)
usbc_clip_fhook  = 0.8;    // front corner hooks: width (X, inside that 1mm) and reach over the PCB top (Y)
function usbc_clip_bosses() = let (iy = -(rear_margin - wall))
    [ for (dx = [-1, 1]) for (yy = [iy + 3, iy + usbc_trigger_board_d - 3]) [usbc_trigger_x + dx*(usbc_trigger_board_w/2 - 3), yy] ];
usbc_pcb_x0 = usbc_trigger_x - usbc_pcb_w/2;
usbc_pcb_y0 = -(rear_margin - wall) + usbc_conn_over - 0.23;   // PCB front edge: the receptacle face ends 0.23 into the wall
usbc_pcb_y1 = usbc_pcb_y0 + usbc_pcb_l;
module usbc_clip() {
    z0 = usbc_trigger_boss_h;  z1 = z0 + usbc_clip_t;  zt = z1 + usbc_pcb_t;   // plate bottom / top, PCB top
    iy = -(rear_margin - wall);
    px0 = usbc_trigger_x - usbc_trigger_board_w/2 - 1;  px1 = usbc_trigger_x + usbc_trigger_board_w/2 + 1;
    py0 = iy + 0.27;  py1 = iy + usbc_trigger_board_d + 1;
    fy0 = iy + 3 + usbc_clip_head_d/2 + 0.6;          // fingers run between the front and back screw counterbores
    fy1 = iy + usbc_trigger_board_d - 3 - usbc_clip_head_d/2 - 0.6;
    fxs = [usbc_pcb_x0 - usbc_clip_clr - usbc_clip_fin_t, usbc_pcb_x0 + usbc_pcb_w + usbc_clip_clr];   // finger inner faces touch the PCB outline + clr
    difference() {
        union() {
            translate([px0, py0, z0]) linear_extrude(usbc_clip_t) offset(r = 1.5) offset(delta = -1.5) square([px1 - px0, py1 - py0]);
            // front stop, under the receptacle overhang (top-mount: nothing of the connector is below the PCB's top face)
            translate([usbc_pcb_x0, py0, z1 - 0.01]) cube([usbc_pcb_w, usbc_pcb_y0 - usbc_clip_clr - py0, usbc_pcb_t - 0.2]);
            // front corner hooks, beside the receptacle
            for (hx = [usbc_pcb_x0, usbc_pcb_x0 + usbc_pcb_w - usbc_clip_fhook]) {
                translate([hx, py0, z1 - 0.01]) cube([usbc_clip_fhook, usbc_pcb_y0 - usbc_clip_clr - py0, usbc_pcb_t + 0.1 + 1.0]);
                translate([hx, py0, zt + 0.1]) cube([usbc_clip_fhook, usbc_pcb_y0 + usbc_clip_fhook - py0, 1.0]);
            }
            // back stop, low so the cable's wires pass over it; kept between the back screw heads
            translate([usbc_trigger_x - 4, usbc_pcb_y1 + usbc_clip_clr, z1 - 0.01]) cube([8, 1.2, usbc_pcb_t]);
        }
        for (b = usbc_clip_bosses()) {
            translate([b[0], b[1], z0 - 1]) cylinder(d = 3.4, h = usbc_clip_t + 2);
            translate([b[0], b[1], z1 - usbc_clip_head_h]) cylinder(d = usbc_clip_head_d, h = usbc_clip_head_h + 1);
        }
        // relief for the cable's through-hole legs, ~1mm in from the back edge
        translate([usbc_pcb_x0 + 0.5, usbc_pcb_y1 - 2.5, z1 - 1.5]) cube([usbc_pcb_w - 1, 3, 2]);
        // slots freeing the fingers from the plate on three sides (front end stays attached)
        for (fx = fxs)
            translate([fx - usbc_clip_slot, fy0 + 2, z0 - 1]) cube([usbc_clip_fin_t + 2*usbc_clip_slot, fy1 - fy0 - 2 + usbc_clip_slot, usbc_clip_t + 2]);
    }
    // the fingers: bed level up past the PCB, the hook on the inside at the free (back) end, lead-in chamfer on top
    for (i = [0, 1]) {
        fx = fxs[i];  in = i == 0 ? 1 : -1;   // +1: the PCB is toward +x
        translate([fx, fy0, z0]) cube([usbc_clip_fin_t, fy1 - fy0, zt + 0.1 + 1.2 - z0]);
        hull() {
            translate([i == 0 ? fx + usbc_clip_fin_t - 0.01 : fx - usbc_clip_lip, fy1 - 4, zt + 0.1])
                cube([usbc_clip_lip + 0.01, 4, 0.01]);
            translate([i == 0 ? fx + usbc_clip_fin_t - 0.01 : fx - 0.01, fy1 - 4, zt + 0.1 + 1.2 - 0.01]) cube([0.02, 4, 0.01]);
        }
    }
}

// Real cartridge edge-connector envelope, per direction (replaces the
// earlier 92x19 placeholder, an unverified guess at a "standard 40-pos
// .1in edge-card envelope"), plus insertion clearance and a lead-in funnel
// at the panel face to help guide the cartridge in.
//
// Per direction, the previous constant-110-wide-past-the-taper design was
// "just a bit too wide" -- now a genuine funnel the whole way in: was
// 110mm at the panel's outer face, narrowing down to 108.5mm (0.5mm
// clearance) right at CN1's own real position, then staying 108.5 the
// rest of the way. See main_cart_slot_cut() below. Outer face further
// tightened 110 -> 109.5 per direction ("still too much play on the cart
// slot") -- this also narrows main_cart_guide_walls' inner span (derived
// from cart_slot_surface_w), which is what actually registers the
// cartridge side-to-side as it's pushed in, so this is the fix for
// insertion wobble specifically (not the tighter 108.5 at CN1 itself,
// unchanged, which was never the loose part).
cart_slot_w                  = 108;  // real card width
cart_slot_h                  = 23;
cart_slot_connector_margin_w = 0;    // clearance right at the connector -- 0: the funnel
                                       // now tapers 109.5 (outer face) -> 108 (the card's
                                       // own real width) at CN1, per direction
cart_slot_margin_h           = 2;    // total height clearance -- reduced from 3 (nominal
                                       // height 26 -> 25) per direction, "the cart slot is
                                       // too tall"
cart_slot_surface_w          = 109.5;  // width at the panel's own outer face
cart_slot_taper_grow_h       = 0;    // no vertical flare now -- was 6, but that made the
                                       // surface opening 32mm tall, part of what read as
                                       // "too tall"; height is just a flat 25mm the whole depth
module main_cart_slot_cut() {
    xy = cn1_xy();
    wall_x = -case_margin;
    notch_depth = case_margin*3;
    taper_depth = xy[0] - wall_x; // reaches the nominal (narrow) width right at CN1 itself
    nominal_w = cart_slot_w + cart_slot_connector_margin_w;
    nominal_h = cart_slot_h + cart_slot_margin_h;
    hull() {
        translate([wall_x, xy[1] - cart_slot_surface_w/2, parting_h - 1])
            cube([0.01, cart_slot_surface_w, nominal_h + cart_slot_taper_grow_h + 1]);
        translate([wall_x + taper_depth - 0.01, xy[1] - nominal_w/2, parting_h - 1])
            cube([0.01, nominal_w, nominal_h + 1]);
    }
    translate([wall_x + taper_depth, xy[1] - nominal_w/2, parting_h - 1])
        cube([notch_depth - taper_depth, nominal_w, nominal_h + 1]);
}

// CN3's real pad position (X=18.21, from board_connectors) sits right in
// the same right-rear corner as CN1/the cart slot -- per direction, "the
// rightmost rear cutout... completely blocked by the cart slot." CN3
// already needs a cable/pigtail to reach the rear panel at all (it's
// bottom-mounted on the real board), so its CUTOUT position doesn't need
// to match the pad -- only main_cn3_shelf()/pedestal (which stay on the
// real pad location) do. Relocated here to the left of SW1 (X=232.22),
// clear of both SW1's own notch and the cart slot.
cn3_cutout_x = 255;

// ---- RF connector: a second composite-style (RCA-shaped) notch beside SW3 ----
// 7mm of wall between it and SW3's notch, on the side toward JK4 (larger X). That is the only free side: to smaller X the neighbour is
// J5A, whose notch would overlap it. Same size as the RCA notches (10.5 x 16, rounded). rf_side = -1 flips it to the J5A side.
rf_gap_from_sw3 = 7;
rf_side = 1;
sw3_x = [for (c = board_connectors) if (c[0] == "SW3") c[1]][0];
sw3_shift = -3;   // moves the CUTOUT only (not the real connector's pad, still at sw3_x) -- per direction, "3mm to the right"
                  // (-X, per this model's own RIGHT/LEFT labels -- see orientation_labels()). Narrows the gap to J5B's neighbour
                  // J5A from 4.76mm to 1.76mm -- now one of the gaps main_top_rear_gussets() below reinforces.
sw3_cutout_x = sw3_x + sw3_shift;
rf_x  = sw3_cutout_x + rf_side*(10/2 + rf_gap_from_sw3 + 10.5/2);

// ---- DV I/O PANEL on the rear face of the top (from "coco-dv io template.png") ----
// The drawing is a 61 x 53 panel seen from outside (from behind), origin bottom-left; centreline at 44 up. Features are
// placed with the whole thing centred on the RF connector, and its LOWEST edge (the HDMI opening's bottom) dvio_low_z above the
// top piece's bottom edge. (A 40mm bottom edge for the whole 53mm panel wouldn't fit under the roof, so the reference is the
// lowest cutout -- change dvio_low_z if you meant something else.)
//   * two 6mm button holes, a 9.5mm RCA hole, the HDMI opening (18.5 x 7.5 with 3mm bottom chamfers)
//   * the outermost two holes are the button board's screws: M3 self-tapping bosses standing dvio_boss_h proud of the wall
dvio_tw = 61;
dvio_cx = rf_x;
dvio_low_z = 40;
dvio_boss_d = 7;
dvio_boss_h = 5;
dvio_button_d = 6;  dvio_rca_d = 9.5;
function dvio_pt(tx, ty) = [dvio_cx - dvio_tw/2 + tx, parting_h + dvio_low_z + (ty - 35.5)];   // template (x, y) -> [X, Z]
module dvio_features_2d() {
    for (p = [[13, 49], [13, 40]]) translate(p) circle(d = dvio_button_d, $fn = 48);
    translate([47, 43.6]) circle(d = dvio_rca_d, $fn = 64);
    polygon([[19, 43], [37.5, 43], [37.5, 38.5], [34.5, 35.5], [22, 35.5], [19, 38.5]]);
}
module main_dvio_cutouts() {
    p0 = dvio_pt(0, 0);
    translate([p0[0], -rear_margin + wall + 1, p0[1]]) rotate([90, 0, 0])
        linear_extrude(height = wall + 2) dvio_features_2d();
}
module main_dvio_bosses(tip = 1) {   // tip -1: point toward the floor instead (the hinged build's back plate prints floor-down)
    y_in = -rear_margin + wall;
    for (tx = [4, 57]) {
        p = dvio_pt(tx, 44);
        // teardrop pointing at the roof: the top is printed roof-down, so this boss sticks out sideways from a vertical wall
        translate([p[0], y_in - 0.5, p[1]]) rotate([-90, 0, 0]) hull() {
            cylinder(d = dvio_boss_d, h = dvio_boss_h + 0.5, $fn = 48);
            translate([0, -tip*1.5*dvio_boss_d/2, 0]) cylinder(d = 0.2, h = dvio_boss_h + 0.5);
        }
    }
}
module main_dvio_boss_holes() {
    for (tx = [4, 57]) {
        p = dvio_pt(tx, 44);
        translate([p[0], -rear_margin + 1.0, p[1]]) rotate([-90, 0, 0])
            cylinder(d = m3_pilot_d, h = (wall - 1.0) + dvio_boss_h + 1, $fn = 32);   // stops 1mm short of the outside face
    }
}

// ---- Triangular gussets between every pair of adjacent rear-panel cutouts ----
// Each pair of neighbouring cutouts leaves a thin, full-height (uncut) fin of wall between them -- as little as ~1.8mm
// wide now that SW3 moved -- with nothing bracing it front-to-back. A gusset centred on each gap ties it to the roof:
// full contact with the fin down its whole height (rise), widest (gusset_run) right at the roof and tapering to a knife
// edge at the bottom -- same "widest at the bed, narrows as it grows" shape as the drive-bracket cross braces, so it
// needs no support when the top prints roof-down. gusset_w (3mm) is only ever a target: whatever falls inside a
// neighbouring cutout is trimmed away automatically since this is added to the union BEFORE the notches are cut.
gusset_w = 3;
gusset_run = 8;
function rear_cutout_hw(kind) =
    (kind == "din6" || kind == "din4" || kind == "din5" || kind == "rgb_din8") ? 15.9/2 :
    (kind == "rca") ? 10.5/2 : (kind == "power_switch") ? 14/2 : (kind == "slide_switch") ? 10/2 :
    (kind == "reset_button") ? 10.5/2 : 0;
rear_cutouts_raw = concat(
    [for (c = board_connectors) if (c[5] != "cart_slot")
        let (x = (c[0] == "CN3") ? cn3_cutout_x : (c[0] == "SW3") ? sw3_cutout_x : c[1])
        [x, rear_cutout_hw(c[5])]],
    [[rf_x, 10.5/2]]);
function insert_sorted_x(lst, item) = len(lst) == 0 ? [item] :
    item[0] <= lst[0][0] ? concat([item], lst) : concat([lst[0]], insert_sorted_x([for (i = [1:len(lst)-1]) lst[i]], item));
function sort_by_x(lst) = len(lst) == 0 ? [] : insert_sorted_x(sort_by_x([for (i = [1:len(lst)-1]) lst[i]]), lst[0]);
rear_cutouts_sorted = sort_by_x(rear_cutouts_raw);
// [gx, w] pairs: gx is the gap's midpoint, w is the gusset's own width there -- capped to leave gusset_gap_clr of
// clearance from each neighbouring notch instead of butting up flush against its cut edge. Landing exactly ON that
// edge (which is what "trimmed by whichever cutout is nearest" meant before) put the gusset's own boundary and the
// notch's cut boundary on the same plane -- the same degenerate-coincident-face situation as round_top_edge_y, just
// two negative features meeting instead of a cut meeting the outer skin. A real gap, even a whisker of one, avoids it.
gusset_gap_clr = 0.3;
function rear_gaps() = [for (i = [0 : len(rear_cutouts_sorted)-2])
    let (e0 = rear_cutouts_sorted[i][0] + rear_cutouts_sorted[i][1], e1 = rear_cutouts_sorted[i+1][0] - rear_cutouts_sorted[i+1][1])
    if (e1 - e0 > 0.5) [(e0 + e1) / 2, min(gusset_w, e1 - e0 - 2*gusset_gap_clr)]];
module main_top_rear_gusset(gx, w = gusset_w) {
    // y_wall is the wall's own inner face -- the gusset's vertical edge sits exactly there by design (flush against it).
    y_wall = -rear_margin + wall;
    z_ceil = rear_tower_h - wall + 0.4;   // sinks a hair into the roof so it fuses
    z_low  = parting_h + 1;               // stops just above the parting line
    translate([gx - w/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = w)
        polygon([[y_wall, z_ceil], [y_wall + gusset_run, z_ceil], [y_wall, z_low]]);
}
// Three of the gussets above (x=78.55, 92.93, 121.855) land on the DV I/O panel added later: its left screw boss, the
// HDMI opening, and the RCA hole respectively. Per direction, these three don't reach the roof at all -- talking about
// the TOP shell the way it sits on the print bed (roof down, so the parting line is the physically highest point):
// each runs from the parting line down 30mm, i.e. a short stub near the rim that doesn't come anywhere near the panel
// (comfortably below its lowest feature, the HDMI opening at z=61.85). It's still self-supporting printed roof-down --
// this piece never touches the actual bed/roof, so instead of being widest there, it's WIDEST AT THE RIM (the LAST
// thing printed) and comes to a point 30mm up (the FIRST z this feature exists at, printed before anything is under
// it to grow from) -- same taper idea as the normal gussets, just anchored to the opposite end.
gusset_stub_h = 30;
function main_top_rear_gusset_is_stub(gx) = abs(gx - 78.55) < 0.1 || abs(gx - 92.93) < 0.1 || abs(gx - 121.855) < 0.1;
module main_top_rear_gusset_stub(gx, w = gusset_w) {
    y_wall = -rear_margin + wall;   // see main_top_rear_gusset() above
    z_low  = parting_h + 1;
    z_tip  = z_low + gusset_stub_h;
    translate([gx - w/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = w)
        polygon([[y_wall, z_low], [y_wall + gusset_run, z_low], [y_wall, z_tip]]);
}
module main_top_rear_gussets() {
    for (g = rear_gaps())
        if (main_top_rear_gusset_is_stub(g[0])) main_top_rear_gusset_stub(g[0], g[1]);
        else main_top_rear_gusset(g[0], g[1]);
}

// Corner radius of a rear port opening: 2 normally. In the hinged one-piece build the ROUND connectors (the DIN jacks
// JK1-4, the RCA video/audio J5A/B, and the RF jack) get stadium openings -- radius half the width, less a hair, so a
// round face sitting on the board is followed all the way round (the openings start 1mm below the board surface, which
// puts the lower semicircle's centre about where such a face's centre is). The square-bodied power switch is held to
// 4 and the reset button to the general min side/2 - 1.5 (at most 6). SW3 stays square either way.
function rear_notch_round(kind) = kind == "din6" || kind == "din4" || kind == "din5" || kind == "rgb_din8" || kind == "rca";
function rear_notch_r(w, h, kind) = !onepiece_hinged ? 2
    : rear_notch_round(kind) ? min(w, h)/2 - 0.3
    : kind == "power_switch" ? 4 : min(6, min(w, h)/2 - 1.5);
module main_connector_cutouts_top() {
    notch_depth = case_margin*3;
    for (c = board_connectors) {
        refdes = c[0]; x_real = c[1]; y = c[2]; kind = c[5];
        x = (refdes == "CN3") ? cn3_cutout_x : (refdes == "SW3") ? sw3_cutout_x : x_real;
        if (kind == "din6" || kind == "din4" || kind == "din5" || kind == "rgb_din8")
            rim_notch_y(x, -rear_margin, 15.9, 20, notch_depth, rear_notch_r(15.9, 20, kind));
        else if (kind == "rca")
            rim_notch_y(x, -rear_margin, 10.5, 16, notch_depth, rear_notch_r(10.5, 16, kind));
        else if (kind == "power_switch")
            rim_notch_y(x, -rear_margin, 14, 14, notch_depth, rear_notch_r(14, 14, kind));
        else if (kind == "slide_switch")
            rim_notch_y(x, -rear_margin, 10, 11, notch_depth); // SW3 -- stays sharp, per direction
        else if (kind == "reset_button")
            rim_notch_y(x, -rear_margin, 10.5, 12, notch_depth, rear_notch_r(10.5, 12, kind)); // SW2: 8x8 body + clearance; 10.5 wide because the
                // 2mm corner rounding eats ~1.2mm per side at the top corners of a square body
        else if (kind == "cart_slot")
            main_cart_slot_cut();
        // "cart_slot" exits the RIGHT-SIDE panel (min X, post board_pt mirror, still case_margin), all others exit the REAR panel (min Y, now rear_margin)
    }
    rim_notch_y(rf_x, -rear_margin, 10.5, 16, notch_depth, rear_notch_r(10.5, 16, "rca"));   // RF connector (see above)
    //rim_notch_y(usbc_power_x, -rear_margin, 10, 5, notch_depth, notch_r);
}

// The main bottom's own window in the front wall, full height (see main_fp_z1 above) -- no snap groove (the taller plate is
// held by 2 screws instead, see main_faceplate_screw_*() below).
module main_faceplate_window() {
    translate([board_w/2 - fp_len/2, main_front_y - wall - 0.01, fp_z0])   // starts at the wall's inner face so it leaves the stop lips alone
        cube([fp_len, wall + 1.01, main_fp_z1 - fp_z0 + 0.1]);   // +0.1: overshoots the parting line a hair so the cut doesn't
                                                                  // end exactly flush with the shell's own top face -- that
                                                                  // coincident boundary was rendering as a leftover sliver
}
// Stop blocks on the wall's inside face at the window's two ends: a small lip reaches into the window just behind the plate's
// inner face, so the plate can't be pushed on into the case (the keyboard's window has solid behind its ends already).
module main_faceplate_stops() {
    y_in = main_front_y - fp_out_gap - fp_t;
    for (xe = [board_w/2 - fp_len/2, board_w/2 + fp_len/2]) {
        s = xe < board_w/2 ? -1 : 1;
        translate([min(xe, xe + s*3), y_in - 1.2, 2]) cube([3, main_front_y - wall + 0.1 - (y_in - 1.2), main_fp_z1 - 3]);   // block on the wall
        translate([min(xe, xe - s*1), y_in - 1.2, 2]) cube([1, 1.2 - 0.05, main_fp_z1 - 3]);                               // lip into the window
    }
}
// ---- MAIN FACEPLATE screw retention: L-shaped, screws straight down into the floor ----
// Per direction ("I don't want any screws [running sideways with a brace]... l shaped profile and screw into the
// bottom"): no more horizontal screw + freestanding post + wedge brace. Instead the plate itself is bent into an L --
// the same vertical face as before, plus a foot that lies flat on the case's own interior floor, extending inward from
// the window. Two screws go straight down through the foot into the floor, the same way every other screw boss in this
// file works (vertical, driven from above with the top shell off) -- no bracing needed since the foot rests directly on
// solid material the whole time.
// X positions and extent picked to clear board B's own mounting bosses/wedges (main_kbpcb_mount(), at roughly x=83.9
// and x=164.2, both reaching to within a few mm of the front wall) -- not centred or evenly spaced, just wherever's clear.
main_fp_screw_xs  = [110, 195];
main_fp_foot_x0   = 92;
main_fp_foot_x1   = 206;
main_fp_foot_len  = 10;   // how far the foot reaches into the case, away from the wall -- short enough to stay clear of
                          // the x=164.2 boss's own reach (to within 3mm of the wall) even though the foot crosses its X
main_fp_foot_t    = 2.5;  // foot thickness -- stops just clear of board B's underside (its PCB bottom sits at z=6)
main_fp_foot_pilot_depth = 1.8;   // blind hole into the floor itself (2.4mm thick) -- leaves 0.6mm below, uncut
function main_fp_foot_y1() = main_front_y - fp_out_gap - fp_t;      // foot's outer edge, flush with the leg's inner face
function main_fp_foot_y0() = main_fp_foot_y1() - main_fp_foot_len;  // foot's inner edge
module main_faceplate_floor_pilots() {   // blind pilot holes in the EXISTING floor -- no separate boss needed
    y = (main_fp_foot_y0() + main_fp_foot_y1()) / 2;
    for (x = main_fp_screw_xs)
        translate([x, y, new_floor_t - main_fp_foot_pilot_depth])
            cylinder(d = m3_pilot_d, h = main_fp_foot_pilot_depth + 0.01);
}
module main_faceplate_foot_clearance() {   // through the foot itself, in the printed plate
    y = (main_fp_foot_y0() + main_fp_foot_y1()) / 2;
    for (x = main_fp_screw_xs)
        translate([x, y, new_floor_t - 1]) cylinder(d = 3.4, h = main_fp_foot_t + 2);
}
// The main plate itself: same vertical face/features as the keyboard's (reuses kb_boardA_access(), translated into the
// main frame the same way board B's mount/access cuts already are), taller, plus the new foot.
module main_faceplate(placed = false) {
    y0 = main_front_y - fp_out_gap - fp_t;                                 // plate's inner (board-side) face
    shift = [board_w/2 - kb_w/2, y0 - kb_plate_y0, 0];                     // keyboard-frame -> main-frame, same trick main_faceplate_window's
                                                                            // predecessor used: aligns the two boards' shared header centreline
    // Printed with the foot flat on the bed (its underside is the true interior-floor height, new_floor_t): the
    // vertical leg then stands straight up from the foot's front edge as a plain, self-supporting free wall.
    translate(placed ? [0, 0, 0] : [0, 0, -new_floor_t])
    difference() {
        union() {
            translate([board_w/2 - fp_len/2 + fp_clr, y0, fp_z0 + fp_clr])
                cube([fp_len - 2*fp_clr, fp_t, main_fp_z1 - fp_clr - (fp_z0 + fp_clr)]);
            translate([main_fp_foot_x0, main_fp_foot_y0(), new_floor_t])
                cube([main_fp_foot_x1 - main_fp_foot_x0, main_fp_foot_len, main_fp_foot_t]);
        }
        translate(shift) kb_boardA_access();
        main_faceplate_foot_clearance();
        // a through-hole component's pin tails poke down to z=3.6 here (found by checking the foot against the real
        // stuffed board) -- a small notch, not worth tracking down which part it is
        translate([124, 158, 2.4]) cube([11, 5, 2.6]);
    }
}
// (superseded by main_faceplate_window() -- kept for reference, no longer called)
module main_usb_passthrough_front() {
    // front-panel USB coupler passthrough from the keyboard's Pico controller.
    // TODO: position is a placeholder — move along X to suit your panel-mount
    // USB coupler / cable routing once the keyboard tray is finalized.
    // Uses parting_h (bottom tray's real height), not front_deck_h (a
    // top-shell parameter) -- see main_lip_socket() for why that distinction
    // now matters. This one happened to still be numerically in-range
    // (16.8 < 21.85) so it wasn't actually cutting into thin air, but it was
    // the same conceptual mistake and could break again if the two
    // parameters ever drift further apart.
    // Widened 14x8 -> 20x11 and reaches further inward -- per direction,
    // the old opening didn't leave enough room for a real connector/coupler
    // housing (not just the bare USB plug), and its inward reach (only to
    // Y=149.675) stopped short of clearing the support beam's near face
    // (147.76) entirely, so it never actually broke through it. Now runs
    // back to Y=130 -- well past the (now fully gapped, see
    // main_support_beam()) beam and into the open kbpcb bay -- giving a
    // single clear corridor from the Pico's USB port to the panel. TODO:
    // true up 20x11 against the real coupler's actual housing dimensions.
    // follows board B's USB jack (the board is positioned by its ribbon header now, so the jack is no longer on the centreline)
    translate([main_kbpcb_origin[0] + kbpcb_usb_x - 79.0, (main_front_y + 130)/2, kbpcb_screw_boss_h + kbpcb_thickness + kbpcb_usb_z])
        rect_cutout(20, 11, main_front_y - 130 + case_margin*2); // depth along Y (centred on the real jack height)
}

module main_pizero_hdmi_mount() {
    // Mounting bosses for EITHER a Raspberry Pi Zero (RGBtoHDMI) OR a bulkhead
    // HDMI coupler, on the tower's rear (true back-of-machine) face, near
    // the top where it can share the panel with the other rear connectors.
    // Z anchor kept within the TOP shell's available band (parting_h to
    // rear_tower_h = 34..62): the pattern's 23mm tall span needs both rows
    // to land inside that band with margin, or the top row pokes through
    // the roofline (this bit us once already).
    pi_zero_holes = [[0,0],[48,0],[0,23],[48,23]]; // real Pi Zero mounting pattern, 3.5mm holes
    // Inset reduced from +4 to +1 -- was tuned assuming the old case_margin
    // (13.17mm) wall thickness back here; now that the rear wall specifically
    // uses the much thinner rear_margin (~4.17mm, see rear_margin above),
    // +4 would place these holes almost at the wall's INNER face (barely any
    // wall left to bite into) rather than comfortably inside its OUTER face.
    translate([board_w*0.5 - 24, -rear_margin + 1, parting_h + 3])
        rotate([90,0,0])
        for (h = pi_zero_holes)
            translate([h[0], h[1], 0])
                cylinder(d=3.4, h=6);
}

// ============================================================================
// FLOPPY BAYS (2x, side by side, 3.5", front-loading from the tower's
// user-facing side) -- per direction. See floppy_* constants above
// main_depth for the real-drive envelope, margins, and the PLACEHOLDER
// bracket screw offsets.
//
// Simpler construction per direction, replacing an earlier wall+taper
// version that still showed a visible stepped "L shape + triangle"
// artifact: think of the whole top shell as a solid rectangular block with
// a triangular wedge cut off the front (that's exactly what the TOP SHELL
// STYLING section above already builds). Now take a single rounded-rect
// "plane" sized to fit both bays + their margin + the gap between them
// (floppy_face_w x floppy_face_h) and slide it back (toward lower Y, where
// the wedge is taller) until its own top edge just reaches the wedge's
// natural roofline -- that Y position is floppy_notch_y0 below. From there
// forward to the front, hollow out everything within that rounded-rect
// footprint. Nothing needs to taper or fit exactly: wherever the wedge is
// still taller than the notch, a flat roof remains over it; wherever the
// wedge has already dropped below the notch's own height (near the front),
// the cut simply opens all the way through on its own -- no separate wall,
// no separate taper piece, no overhang.
floppy_notch_corner_r = 8; // rounded-rect corner radius for the notch itself
floppy_notch_y0_raw = main_break1_y
    + (bay_face_z0 + floppy_face_h - rear_tower_h) * (main_break2_y - main_break1_y)
      / (front_deck_h - rear_tower_h);
floppy_notch_y0 = min(max(floppy_notch_y0_raw, main_break1_y), main_break2_y); // clamped to
                                                                                  // the ramp's own
                                                                                  // valid Y range
floppy_rail_t  = 3;     // bracket rail fin thickness (X)
floppy_rail_y0 = max(-rear_margin + 3, floppy_notch_y0 - floppy_d); // as far back as
                          // available before the rear wall, capped by the real drive depth

// Rounded-rect solid extruded along Y (cross-section in the X-Z plane) --
// shared by the notch cut, the duct walls around it, and the bulkhead
// plate below, so all three stay geometrically consistent by construction.
module rounded_rect_prism_y(x0, x1, z0, z1, y0, y1, r) {
    hull()
        for (xx = [x0 + r, x1 - r])
            for (zz = [z0 + r, z1 - r])
                translate([xx, y0, zz])
                    rotate([-90, 0, 0])
                        cylinder(r = r, h = y1 - y0);
}

module main_floppy_bay_notch() {
    // -1 on y0: starts a hair before the tangent point, so the cut
    // genuinely overlaps solid material there instead of just grazing it
    // at an exact coincident height (the same coincident-face issue
    // documented on rounded_footprint_solid). y1 well past the front wall,
    // for a clean full cut-through.
    rounded_rect_prism_y(
        board_w/2 - floppy_face_w/2, board_w/2 + floppy_face_w/2,
        bay_face_z0, bay_face_z0 + floppy_face_h,
        floppy_notch_y0 - 1, main_front_y + 5,
        floppy_notch_corner_r);
}

// Per direction: the notch above leaves the tunnel completely open into
// the general case interior -- it needs its own walls (a proper enclosed
// duct), plus a flat bulkhead plate with the two actual drive-sized holes
// rather than one shared opening for the whole pair.
//
// First attempt at the duct walls ADDED a hollow tube (the notch's own
// cross-section expanded outward by wall thickness) on top of the already-
// finished shell. That stuck out past the case's own natural silhouette
// wherever the wedge had already sloped down below the duct's height --
// exactly the region nearer the front, i.e. most of it -- a visible
// protrusion (per direction). Fixed per direction, by folding this into
// the shell's OWN construction instead of bolting it on afterward: shield
// this same expanded footprint from the general inner-cavity cut (see
// main_case_top()), so the OUTER solid's own natural material -- which by
// definition never exceeds the case's own silhouette -- stays in place as
// the duct's walls. Nothing is ever added past where solid material
// already was, so there's no way for this to protrude.
floppy_duct_wall_t = wall;
module main_floppy_bay_duct_protect() {
    rounded_rect_prism_y(
        board_w/2 - floppy_face_w/2 - floppy_duct_wall_t, board_w/2 + floppy_face_w/2 + floppy_duct_wall_t,
        bay_face_z0 - floppy_duct_wall_t, bay_face_z0 + floppy_face_h + floppy_duct_wall_t,
        floppy_notch_y0 - 1, main_front_y + 5,
        floppy_notch_corner_r + floppy_duct_wall_t);
}

// Per direction: printing this upside-down, the space between the
// bulkhead's own ceiling and the actual roof (right above the bay, over
// the bulkhead's own Y-span where the wedge roof is still taller than the
// bulkhead) was left hollow by the general inner-cavity cut -- an
// unsupported horizontal span there needed print support. Since a real
// drive's screw loads land on the brackets right next to this same area,
// filling it in solid is a straight win (per direction: "saving time,
// material and adding strength" vs support material). Same shield
// technique as main_floppy_bay_duct_protect() above -- this only ever
// keeps material that's already within the case's own natural silhouette,
// so it can't protrude.
module main_floppy_bay_roof_fill_protect() {
    rounded_rect_prism_y(
        board_w/2 - floppy_face_w/2 - floppy_duct_wall_t, board_w/2 + floppy_face_w/2 + floppy_duct_wall_t,
        bay_face_z0 + floppy_face_h, rear_tower_h + 5,
        floppy_bulkhead_y0, floppy_notch_y0,
        floppy_notch_corner_r + floppy_duct_wall_t);
}

// The bulkhead plate is a genuinely ADDED solid (it has to be -- the notch
// already cut straight through whatever was there, including the front
// wall itself), so it's held to the same no-protrusion rule by
// positioning, not protection: its own height (floppy_face_h) is taller
// than the front wall's natural height (front_deck_h), so sitting it
// flush against the front wall would stick it up above the surrounding
// skirt line. Instead it sits at floppy_notch_y0 -- exactly where the
// wedge's natural height already equals the plate's own height (the same
// point the notch itself is anchored to) -- so its outward face is flush
// with the surrounding material, not proud of it. The open notch continues
// from there out to the front wall as a shrouded approach to the bays,
// rather than the bulkhead sitting right at the front edge.
floppy_bulkhead_t = 4;
floppy_bulkhead_y0 = floppy_notch_y0 - floppy_bulkhead_t;
module main_floppy_bay_bulkhead_solid() {
    rounded_rect_prism_y(
        board_w/2 - floppy_face_w/2, board_w/2 + floppy_face_w/2,
        bay_face_z0, bay_face_z0 + floppy_face_h,
        floppy_bulkhead_y0, floppy_notch_y0,
        floppy_notch_corner_r);
}
module main_floppy_bay_bulkhead_holes() {
    // The two actual drive-sized openings -- per direction, cut through
    // the bulkhead specifically, not the whole notch.
    opening_w = floppy_w + floppy_fit_clear_w;
    opening_h = floppy_h + floppy_fit_clear_h;
    opening_z0 = floppy_opening_z0;
    for (i = [-1, 1])
        translate([board_w/2 + i*(floppy_w+floppy_bay_gap)/2 - opening_w/2,
                    floppy_bulkhead_y0 - 1, opening_z0])
            cube([opening_w, floppy_bulkhead_t + 2, opening_h]);
}

// One rail band's side profile (u = Y, v = Z). The free bottom corners are rounded; the corners that fuse into the roof
// (top) and, for the forward band, into the bulkhead (front) are built past the clip box so they stay square.
module floppy_rail_band_2d(y0, y1, z0, z1, fuse_front = false) {
    // Was offset(r) offset(delta=-r) on the full rectangle, clipped to a box taller than z1-z0 so the top corners'
    // round-off fell outside the clip and came out square (per the comment above: only the free bottom corners round,
    // the ones that fuse into the roof/bulkhead stay square). That offset()-then-un-offset() round trip was leaving
    // sub-micron duplicate vertices right at the corners it was keeping square -- Bambu Studio was flagging those as
    // non-manifold edges. Built directly with hull() instead (circles for the rounded corners, degenerate slivers for
    // the square ones): same silhouette, no offset() round trip to leave numerical noise behind.
    r = min(floppy_rail_corner_r, (y1 - y0)/2 - 0.1);
    hull() {
        translate([y0 + r, z0 + r]) circle(r = r, $fn = 24);                // bottom-near: always rounded
        if (fuse_front) translate([y1 - 0.001, z0]) square([0.001, 0.001]); // bottom-far: square (fuses to bulkhead)
        else translate([y1 - r, z0 + r]) circle(r = r, $fn = 24);          // bottom-far: rounded
        translate([y0, z1]) square([y1 - y0, 0.001]);                      // top edge: always square (fuses to roof)
    }
}
module main_floppy_bay_brackets() {
    // Rail fins hanging from the tower's own ceiling, one on each side of
    // each bay position, per direction ("brackets that hang from the top").
    // Kept entirely within Y <= floppy_notch_y0 (i.e. the portion of the
    // notch that's still genuinely under solid roof) so the rail's own top
    // has real material to fuse into -- past that Y the roof is already
    // open, so a rail there would just be floating.
    // Mounting pilot holes sit at the real drive's own front-bezel-relative
    // offsets (floppy_screw_front_offsets) -- NOT rescaled to the rail's
    // own length -- so a real drive's screw holes still line up; a hole
    // that doesn't fit within the available rail length is simply omitted
    // rather than compressed to fit.
    //
    // No full-length rail at all now, per direction ("not have the whole
    // bracket going back to front, but instead an inch-wide band covering
    // the front and back holes"): just two standalone ~1in (25.4mm) wide
    // bands, one centered on each real screw location, each reaching all
    // the way to the actual roof (rear_tower_h-wall) for a genuine upside-
    // down-printable connection. Each gets a small fillet flaring out into
    // the roof (per direction, "a little cross brace or fillet for
    // strength") -- since there's no longer a connecting rail bracing them
    // along their length, that roof joint is one place their load
    // concentrates. The FORWARD band (smallest front-offset, nearest the
    // bulkhead) also gets fused directly to the bulkhead's own back face
    // instead of stopping short of it with an air gap -- per direction, a
    // missed opportunity to tie it into the one other solid wall right
    // there, not just the roof.
    true_ceiling_z = rear_tower_h - wall;
    band_half_w = 12.7; // 1in (25.4mm) total width
    fillet_h = 6; // height of the flare into the roof
    fillet_grow = 2; // extra half-width gained at the very top
    bulkhead_back_y = floppy_notch_y0 - floppy_bulkhead_t;
    forward_off = min(floppy_screw_front_offsets);
    for (i = [-1, 1]) {
        bay_cx = board_w/2 + i*(floppy_w+floppy_bay_gap)/2;
        for (side = [-1, 1]) {
            rail_x = bay_cx + side*(floppy_w/2 + floppy_fit_clear_w/2 + floppy_rail_t/2);
            difference() {
                union() {
                    for (off = floppy_screw_front_offsets) {
                        screw_y = floppy_notch_y0 - off;
                        band_y0 = max(screw_y - band_half_w, floppy_rail_y0);
                        band_y1 = (off == forward_off)
                            ? bulkhead_back_y + 0.5   // fuse into the bulkhead, small overlap
                            : min(screw_y + band_half_w, bulkhead_back_y - 1);
                        if (band_y1 - band_y0 > 4) {
                            translate([rail_x - floppy_rail_t/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = floppy_rail_t)
                                floppy_rail_band_2d(band_y0, band_y1, floppy_rail_z0, true_ceiling_z - fillet_h,
                                                    fuse_front = (off == forward_off));
                            // fillet: flares outward in Y (toward the band's own
                            // ends) as it rises into the last few mm below the
                            // roof, widening the bonded area there.
                            //
                            // true_ceiling_z is the FLAT rear roof height --
                            // valid for the band's own body (well within the
                            // flat zone, Y <= main_break1_y), but the forward
                            // band's own Y-range reaches right up near the
                            // bulkhead, just past main_break1_y where the roof
                            // actually starts sloping down. The flare's own
                            // widened top (+fillet_grow past the band's own
                            // edge) reached further into that sloped zone than
                            // the band's straight sides did, poking through the
                            // angled roof there -- per direction ("due to the
                            // geometry of the angled face... narrow that
                            // bracket"), same fillet on every rail position
                            // since they all share this same forward Y range.
                            // Clipped so the flare's own Y-reach never crosses
                            // into the sloped zone, regardless of band_y1.
                            band_yc = (band_y0 + band_y1) / 2;
                            band_hw = (band_y1 - band_y0) / 2;
                            flare_y0 = max(band_yc - band_hw - fillet_grow, floppy_rail_y0);
                            flare_y1 = min(band_yc + band_hw + fillet_grow, main_break1_y - 1);
                            if (flare_y1 > flare_y0)
                                hull() {
                                    translate([rail_x - floppy_rail_t/2, band_y0, true_ceiling_z - fillet_h])
                                        cube([floppy_rail_t, band_y1 - band_y0, 0.01]);
                                    translate([rail_x - floppy_rail_t/2, flare_y0, true_ceiling_z])
                                        cube([floppy_rail_t, flare_y1 - flare_y0, 0.01]);
                                }
                        }
                    }
                }
                for (off = floppy_screw_front_offsets)
                    for (z_off = floppy_screw_z_offsets)
                        if (floppy_notch_y0 - off > floppy_rail_y0 + 2)
                            translate([rail_x - floppy_rail_t/2 - 1, floppy_notch_y0 - off, floppy_opening_z0 + z_off])
                                rotate([0,90,0])
                                    cylinder(d = m3_pilot_d, h = floppy_rail_t + 2);
            }
        }
    }
}
// Small cross brace, rear band to the nearest duct wall -- per direction,
// "all the drive brackets should have a small cross brace... except the
// front ones, they are strong enough because they're attached to the
// front [bulkhead]." Only the two rails that actually sit next to a real
// duct wall get this (one per bay, the OUTER rail -- the inner rail of
// each pair faces the open gap between the bays, nothing to brace
// against there). Reaches halfway into the duct wall's own thickness --
// enough for a real, solid connection without extending past the
// wall's own protected footprint (main_floppy_bay_duct_protect) into
// unprotected, potentially-hollow cavity territory.
// Only floppy_brace_h (10mm) tall, at the TOP of the rails and fused to the roof (per direction): the brace only has to
// keep the rail from bending away under angular stress, and up at the roof it grows from the roof when the top is
// printed roof-down, so it needs no support -- same reasoning as the middle bridge (main_floppy_bay_center_web).
floppy_brace_h = 14;   // triangular gusset: full span along the roof, tapering to a point on the rail (was a 10mm tall block)
module main_floppy_bay_bracket_cross_braces() {
    true_ceiling_z = rear_tower_h - wall;
    band_half_w = 12.7;
    bulkhead_back_y = floppy_notch_y0 - floppy_bulkhead_t;
    rear_off = max(floppy_screw_front_offsets);
    brace_w = 4;
    for (i = [-1, 1]) {
        bay_cx = board_w/2 + i*(floppy_w+floppy_bay_gap)/2;
        for (side = [-1, 1]) {
            if (i*side == 1) { // outer rail only -- faces a real duct wall
                rail_x = bay_cx + side*(floppy_w/2 + floppy_fit_clear_w/2 + floppy_rail_t/2);
                wall_x = (i < 0)
                    ? board_w/2 - floppy_face_w/2 - floppy_duct_wall_t/2
                    : board_w/2 + floppy_face_w/2 + floppy_duct_wall_t/2;
                screw_y = floppy_notch_y0 - rear_off;
                band_y0 = max(screw_y - band_half_w, floppy_rail_y0);
                band_y1 = min(screw_y + band_half_w, bulkhead_back_y - 1);
                if (band_y1 - band_y0 > 4) {
                    brace_y0 = max(screw_y - brace_w/2, band_y0);
                    brace_y1 = min(screw_y + brace_w/2, band_y1);
                    // right triangle in X-Z: long leg along the roof (rail -> duct wall), short leg down the rail. Printed roof-down
                    // it is widest at the bed and narrows as it grows, so it needs no support.
                    zt = true_ceiling_z + 0.4;   // +0.4: sinks into the roof
                    translate([0, brace_y1, 0]) rotate([90, 0, 0]) linear_extrude(height = brace_y1 - brace_y0)
                        polygon([[rail_x, zt], [wall_x, zt], [rail_x, zt - floppy_brace_h]]);
                }
            }
        }
    }
}

// Cross web between the two INNER rear rails (the ones facing the gap between the bays) -- per direction,
// "the back two middle drive brackets don't have cross bracing." The outer rails already get
// main_floppy_bay_bracket_cross_braces() out to the duct walls; the inner pair had nothing tying them together.
// Now a small vertical web: floppy_web_h (10mm) tall, floppy_web_w (3mm) thick, spanning the open gap between
// the two rails (its ends sink into each rail's thickness for a real fuse), centred along the rear band (on the
// drive screw's own Y) and at the TOP of the rails, fused to the roof (per direction: "on the top... no need
// for it to float" -- printed roof-down it grows from the roof, so it needs no support). At the top it is also
// far above the drive-screw holes (near the rail's free end), so a screwdriver still reaches them from the gap.
floppy_web_w = 3;     // thickness (Y)
floppy_web_h = 10;    // height (Z)
module main_floppy_bay_center_web() {
    true_ceiling_z = rear_tower_h - wall;
    screw_y = floppy_notch_y0 - max(floppy_screw_front_offsets);      // middle of the rear band
    rail_h  = true_ceiling_z - bay_face_z0;                            // rail height, free end -> roof
    // inner rail centres sit floppy_bay_gap/2 - fit_clear_w/2 - rail_t/2 either side of board_w/2
    rail_off = floppy_bay_gap/2 - floppy_fit_clear_w/2 - floppy_rail_t/2;
    translate([board_w/2 - rail_off, screw_y - floppy_web_w/2, true_ceiling_z + 0.4 - floppy_web_h])   // +0.4: sinks into the roof
        cube([2*rail_off, floppy_web_w, floppy_web_h]);
}

// ---- Roof spine ribs: extend the drive-bracket rail lines the full depth of the top, front to back ----
// For extra stiffness against weight set on top (e.g. a monitor). Runs right under the roof skin the whole way from the
// rear wall to the front wall, at the same 4 X positions the drive rails already use, in effect making each rail line a
// continuous front-to-back spine instead of stopping at the bay. Uses top_roof_h_at() (already tracks the roof's own
// rear-flat/ramp/front-flat profile, sinking into the flat sections and staying clear of the thin ramp skin) so it
// follows the same roofline the screw-boss braces do. Only spine_rib_h (5mm) thick, hanging from the roof: its own top
// face IS the roof (or just under it), so it's widest right there and never gets wider going down -- self-supporting
// when the top prints roof-down.
spine_rib_w = 5;
spine_rib_h = 5;
function spine_rib_xs() =
    let (bay_cx0 = board_w/2 - (floppy_w+floppy_bay_gap)/2, bay_cx1 = board_w/2 + (floppy_w+floppy_bay_gap)/2,
         off = floppy_w/2 + floppy_fit_clear_w/2 + floppy_rail_t/2)
    [bay_cx0 - off, bay_cx0 + off, bay_cx1 - off, bay_cx1 + off];
module main_top_spine_rib_seg(x, y0, y1) {
    h0 = min(spine_rib_h, top_roof_h_at(y0));
    h1 = min(spine_rib_h, top_roof_h_at(y1));
    hull() {
        translate([x - spine_rib_w/2, y0, parting_h + top_roof_h_at(y0) - h0]) cube([spine_rib_w, 0.01, h0]);
        translate([x - spine_rib_w/2, y1 - 0.01, parting_h + top_roof_h_at(y1) - h1]) cube([spine_rib_w, 0.01, h1]);
    }
}
module main_top_spine_ribs() {
    // The 3 pieces (rear-flat/ramp/front-flat) used to share an exact Y at their two junctions -- a single-point touch
    // between separate hull()s, not real volume overlap, the same coincident-face issue as the corner sweep and the
    // rear gussets earlier. spine_pad overlaps the LATER piece back into the earlier one at each junction instead.
    // (Only safe in this direction: top_roof_h_at() has a real jump right at main_break1_y -- its own roofline is
    // continuous there, but the sink/ramp-clearance margin it adds switches over exactly at that Y -- so extending
    // the ramp piece backward, into territory the rear-flat piece already covers correctly, is fine; extending the
    // rear-flat piece forward past main_break1_y would evaluate the wrong branch.)
    y0 = -rear_margin + wall + 0.3;
    y1 = main_front_y - wall - 0.3;
    spine_pad = 0.2;
    segs = [[y0, main_break1_y], [main_break1_y - spine_pad, main_break2_y], [main_break2_y - spine_pad, y1]];
    for (x = spine_rib_xs())
        for (seg = segs)
            if (seg[1] > seg[0]) main_top_spine_rib_seg(x, seg[0], seg[1]);
}

// 45-degree FILLET where the drive-bay's floor slab meets the bulkhead's front face, so the top prints roof-down
// with a much shorter bridge. The slab (the notch's floor, 263mm wide) spans from the bulkhead face to the ramp skin
// ~19mm away; printed roof-down that is a flat ~19mm bridge. The fillet fills the inside corner (rising up the
// bulkhead face, run floppy_fillet_run (< 1.0) per unit of height = ~43 degrees from vertical, i.e. self-supporting
// when printed roof-down -- the RUN must not exceed the RISE, because the build direction runs along the rise) and
// takes ~6.5mm off the span; the rest of the slab is still a ~13mm overhang. It sits
// in FRONT of the bulkhead, below the drive openings (its height stops floppy_fillet_margin under the opening's
// bottom edge), so it never touches a drive. Only along the straight part of the notch floor (clear of its rounded corners).
floppy_floor_fillet  = false;   // OFF (reverted): the fillet that shortened the roof-down bridge under the drive-bay floor
floppy_fillet_margin = 0.6;
floppy_fillet_run    = 0.95;
module main_floppy_bay_floor_fillet() {
    h = floppy_bay_margin_v - floppy_fit_clear_h/2 - floppy_fillet_margin;    // opening bottom is bay_face_z0 + this + margin
    y0 = floppy_notch_y0;
    run = floppy_fillet_run * (h + 0.3) - 0.5;   // the polygon below overlaps the bulkhead by 0.5 and the slab by 0.3; this keeps the
                                                 // slanted face at exactly floppy_fillet_run over that overlapped rise                                                     // the bulkhead's front face
    x0 = board_w/2 - floppy_face_w/2 + floppy_notch_corner_r;
    x1 = board_w/2 + floppy_face_w/2 - floppy_notch_corner_r;
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = x1 - x0)
        polygon([[y0 - 0.5, bay_face_z0 - 0.3], [y0 - 0.5, bay_face_z0 + h], [y0 + run, bay_face_z0 - 0.3]]);
}

// BUG FIX per direction ("the screw holes are too big for mounting the pcb
// with m3 self tapping screws"): these two used to pass s[2] -- the REAL
// motherboard's own physical mounting-hole diameter (4.0mm/3.5mm, fixed by
// the actual board, see board_standoffs above) -- straight through as the
// SCREW PILOT size too. Those are two different things: the board's real
// hole is just clearance for the screw's shaft through the PCB itself, not
// a spec for the pilot this design drills into its own printed post. That
// conflation is what produced an oversized (3.3-3.8mm) pilot instead of a
// proper M3 one. Now: pilot comes from m3_pilot_d (screw_mount_type-aware)
// like everywhere else in the file; s[2] still sets the post's own OD via
// the od= override, unchanged from the implicit d=hole_d+4.0 these used to
// get, so the posts themselves aren't resized, just their pilot holes.
module main_standoffs_solid() {
    for (s = board_standoffs)
        standoff_peg_solid(s[0], s[1], m3_pilot_d, standoff_height, od = s[2] + 4.0);
}
module main_standoffs_holes() {
    for (s = board_standoffs)
        standoff_peg_hole(s[0], s[1], m3_pilot_d, standoff_height);
}

// X-direction counterpart to cross_brace_wedge() (see main_beam_cross_braces
// for that one) -- same angled-gusset idea, just braced sideways toward a
// side wall instead of forward/backward toward the front wall.
module cross_brace_wedge_x(x_tall, x_thin, y_center, w, h_tall) {
    hull() {
        translate([x_tall, y_center - w/2, 0]) cube([0.01, w, h_tall]);
        translate([x_thin - 0.01, y_center - w/2, 0]) cube([0.01, w, 0.01]);
    }
}
standoff_brace_w = 5;
// Per direction: these 5 REAL board standoffs are tall (standoff_height,
// 20.25mm) freestanding pegs -- much more worth bracing than the short
// kbpcb bosses or the cn4 rib. All 5 happen to sit close to a SIDE wall
// (X near 0 or near board_w, per the real STEP data), so each gets one
// angled gusset reaching sideways to that wall's inner face -- same
// "angle up to meet it, connect to the wall" style preferred for the main
// beam's own braces, just on the X axis instead of Y.
module main_standoffs_braces() {
    right_inner_x = -(case_margin - wall);       // inner face of the min-X wall
    left_inner_x  = board_w + (case_margin - wall); // inner face of the max-X wall
    for (s = board_standoffs) {
        x = s[0]; y = s[1];
        // Nearer to the min-X (right) wall or the max-X (left) wall?
        if (x < board_w/2)
            cross_brace_wedge_x(x, right_inner_x, y, standoff_brace_w, standoff_height);
        else
            cross_brace_wedge_x(x, left_inner_x, y, standoff_brace_w, standoff_height);
    }
}
// Per direction: additional braces from the 2 real board standoffs nearest
// CN1/the cart slot (X~9.1, Y~28.6/94.0), running the OTHER direction from
// their existing wall-brace above -- across the raceway instead -- for
// more strength. Full-height gusset (floor up to Z12, no floating gap
// underneath -- per direction, "I don't want to have space underneath
// that new brace"), EXCEPT directly over the raceway's own open channel,
// so the hollow cable path stays clear -- everywhere else, including over
// the raceway's solid legs, it's a real floor-to-12 wall, not just a thin
// slab bridging across.
//
// The channel cut used to stop at Z5 (raceway_h), leaving the brace's
// upper portion (Z5-12) as a short solid bridge OVER the open channel --
// per direction, "the cross brace on the raceway pokes into the raceway
// itself, and that little bit needs support." Extended to the brace's
// full height instead: this fully separates the brace into two stubs
// where it crosses the channel, but each stub still sits on the case's
// own continuous floor just outside the raceway's own narrow floor cut
// (see main_cable_raceway_floor_cut), so neither one goes disconnected/
// floating -- confirmed via the STL connectivity check.
cn1_raceway_brace_w  = 3;
cn1_raceway_brace_h  = 12;
cn1_raceway_brace_x1 = 44; // past the raceway's far leg (raceway_x+~4) with clearance --
                             // raceway_x moved further out (see its own comment), so this
                             // moved out to match
module main_cn1_raceway_braces() {
    for (s = board_standoffs)
        // The 2 real standoffs near CN1 (X~9.1, Y~28.6/94.0) -- NOT just an
        // X<20 filter, which also catches a 3rd real standoff at (5.16,
        // 151.26) up near CN3 that has nothing to do with CN1 or the
        // raceway (which only runs out to ~Y117) -- its brace came out
        // fully disconnected, floating in open air, caught by the STL
        // connectivity check. Also require Y within the raceway's own span.
        if (s[0] < 20 && s[1] < raceway_y1)
            difference() {
                translate([s[0] - 1, s[1] - cn1_raceway_brace_w/2, 0])
                    cube([cn1_raceway_brace_x1 - (s[0] - 1), cn1_raceway_brace_w, cn1_raceway_brace_h]);
                translate([raceway_x - raceway_w/2 - 0.5, s[1] - cn1_raceway_brace_w/2 - 1, -1])
                    cube([raceway_w + 1, cn1_raceway_brace_w + 2, cn1_raceway_brace_h + 2]);
            }
}

// Long support rib along the board's LENGTH -- the board is wider (280mm,
// X) than deep (156.26mm, Y), so "length" is the X axis, not Y (an earlier
// version had this rotated 90deg). Matches a similar structural beam
// running across the middle of a stock case bottom (Img_9744); bridges the
// long unsupported span between the sparse standoff points (only 5 real
// ones) to cut down on PCB flex/sag. Top flush with standoff_height, same
// as the standoffs -- stays entirely below the PCB, so it can't collide
// with anything mounted on its top side regardless of where real
// components turn out to be. First-pass centerline position; nudge if it
// turns out to interfere with something on the real board's underside.
beam_w = 3;
beam_margin = 10;
beam_front_offset = 7; // distance in from the PCB's front edge (board_d)
function beam_y() = board_d - beam_front_offset;
// Base fillet along BOTH sides of the beam's full length, per direction:
// the first prototype print showed the beam had flexed/raised a little
// (likely warping from being tall, thin, and long) -- a continuous fillet
// widens its effective base without adding height, which is the standard
// fix for exactly this. Not on the two named cross-brace/gusset points
// only; runs the whole length, same as the beam itself, and gets the same
// kbpcb-bay gap cut out of it below.
beam_fillet = 4;
module main_support_beam() {
    difference() {
        union() {
            translate([beam_margin, beam_y() - beam_w/2, 0])
                cube([board_w - 2*beam_margin, beam_w, standoff_height]);
            for (side = [-1, 1])
                hull() {
                    translate([beam_margin, beam_y() + side*beam_w/2, 0])
                        cube([board_w - 2*beam_margin, 0.01, beam_fillet]);
                    translate([beam_margin, beam_y() + side*(beam_w/2 + beam_fillet), 0])
                        cube([board_w - 2*beam_margin, 0.01, 0.01]);
                }
        }
        // Full-height gap spanning the ENTIRE kbpcb (Pico keyboard-
        // controller) board footprint in X -- per direction, "we need
        // nothing above where the keyboard controller is going." Also
        // opens the only path the Pico's USB cable/coupler has to reach
        // main_usb_passthrough_front() -- the beam used to run straight
        // through here uncut (confirmed by rendering the beam/cutout
        // together: the panel cutout's own inward reach stopped short of
        // the beam's near face, so it never actually broke through).
        translate([main_kbpcb_origin[0] - 1, beam_y() - beam_w/2 - beam_fillet - 1, -1])
            cube([kbpcb_w + 2, beam_w + 2*beam_fillet + 2, standoff_height + 2]);
    }
}

// Cross braces tying the beam back to the front wall for lateral support.
// Top flush with standoff_height like everything else; each spans from the
// beam's own Y out to the front wall's inner face. Solid blocks, full
// height, full contact with the front wall -- per direction, reverted from
// an angled/wedge version tried here ("better the way it was, connecting
// to the front"). The angled-wedge idea itself wasn't wrong, just not for
// THESE -- it's used instead on main_cn4_rib and the kbpcb standoff bosses
// below, via the same beam_cross_brace_wedge() helper.
beam_brace_w = 3;
// Per direction: the same rib_wall_bump_h (1.6mm) bump the rear support ribs get where they meet THEIR wall -- but here
// the step starts beam_brace_bump_in (9.5mm) in from the front wall and CONTINUES all the way to the wall (per
// direction, "those bumps on the front ones should continue to the front wall" -- not a short nub sitting apart from it).
beam_brace_bump_in = 9.5;
module main_beam_cross_brace_bump(x, front_wall_inner_y) {
    translate([x - beam_brace_w/2, front_wall_inner_y - beam_brace_bump_in, standoff_height])
        cube([beam_brace_w, beam_brace_bump_in, rib_wall_bump_h]);
}
module main_beam_cross_braces() {
    front_wall_inner_y = main_front_y - wall;
    n = 4;
    // Skip any brace whose X lands within the kbpcb (Pico keyboard-
    // controller) board's own footprint -- per direction, "nothing above
    // where the keyboard controller is going." Generalized from a
    // hardcoded "skip i=3" (X=168) to an actual overlap test against the
    // board's real X range, since that board's origin shifted (to X-align
    // its USB port with the front panel cutout) and now also overlaps
    // brace i=4 (X=224), which the old hardcoded skip missed entirely --
    // confirmed by rendering the beam/braces/kbpcb-mount together.
    kb_x0 = main_kbpcb_origin[0];
    kb_x1 = main_kbpcb_origin[0] + kbpcb_w;
    keep0 = magnet_d/2 + 0.1 + beam_brace_w/2 + 1.5;   // a brace must stay this far (centre to centre) from a magnet bore in the front wall
    for (i = [1:n]) {
        x_raw = board_w*i/(n+1);
        hit0 = [for (m = main_magnet_x) if (abs(x_raw - m) < keep0) m];
        x = len(hit0) > 0 ? (x_raw > hit0[0] ? hit0[0] + keep0 : hit0[0] - keep0) : x_raw;   // e.g. X=224 sat on the X=220 bore
        if (x < kb_x0 || x > kb_x1) {
            translate([x - beam_brace_w/2, beam_y(), 0])
                cube([beam_brace_w, front_wall_inner_y - beam_y(), standoff_height]);
            main_beam_cross_brace_bump(x, front_wall_inner_y);
        }
    }
    // The kbpcb gap splits the beam into two stubs (see main_support_beam):
    // a long one to the left (beam_margin..kb_x0) that still gets 2 braces
    // above (i=1,2), and a short one to the right (kb_x1..board_w-
    // beam_margin) that previously got NONE, since none of the 4 evenly-
    // spaced positions land in its short span. Per direction, one brace in
    // the middle is enough for that short a run -- same solid-block style
    // as the rest of this beam's braces.
    // ... but kept clear of the magnet bores in the front wall: the board moving left slid this brace's midpoint (X ~219) right onto the
    // X=220 magnet. If the midpoint lands within a bore's reach, tuck it just short of the bore instead.
    keep = magnet_d/2 + 0.1 + beam_brace_w/2 + 1.5;
    raw_mid = (kb_x1 + (board_w - beam_margin)) / 2;
    hit = [for (m = main_magnet_x) if (abs(raw_mid - m) < keep) m];
    short_stub_mid = len(hit) > 0 ? hit[0] - keep : raw_mid;
    translate([short_stub_mid - beam_brace_w/2, beam_y(), 0])
        cube([beam_brace_w, front_wall_inner_y - beam_y(), standoff_height]);
    main_beam_cross_brace_bump(short_stub_mid, front_wall_inner_y);
    // the same for the stub left of the board, if the board has moved far enough right to leave one worth bracing
    if (kb_x0 - beam_margin > 12) {
        left_stub_mid = (beam_margin + kb_x0) / 2;
        translate([left_stub_mid - beam_brace_w/2, beam_y(), 0])
            cube([beam_brace_w, front_wall_inner_y - beam_y(), standoff_height]);
        main_beam_cross_brace_bump(left_stub_mid, front_wall_inner_y);
    }
}

// Angled gusset -- full height where it meets the tall feature it's
// bracing (h_tall, at y_tall), tapering down to a thin edge a short
// distance away at y_thin -- per direction, "angle up to meet it, save
// plastic/time." Reused for main_cn4_rib and the kbpcb standoff bosses,
// neither of which sits next to a wall to brace against the way the main
// support beam does, so these just taper down to the open floor nearby
// instead. A ramp that keeps increasing in height as it approaches the
// tall end is inherently self-supporting (never overhangs).
module cross_brace_wedge(x_center, w, y_tall, y_thin, h_tall) {
    hull() {
        translate([x_center - w/2, y_tall, 0])
            cube([w, 0.01, h_tall]);
        translate([x_center - w/2, y_thin - 0.01, 0])
            cube([w, 0.01, 0.01]);
    }
}

// Floor ventilation slots, matching the vent banks visible in a stock case
// bottom (Img_9744) -- each slot's long axis runs along Y (depth), with
// multiple slots stacked side-by-side along X (an earlier version had this
// rotated 90deg too). Banks flank the support beam above/below it in Y,
// clear of the standoffs, screw bosses, and the cart/CN3 cluster on the
// left. First-pass layout (positions, count, size) -- not derived from
// real data, just proportioned to look/function similarly; retune once you
// can compare directly.
vent_slot_w = 3;
vent_slot_gap = 4;
vent_slot_len = 40;
vent_cols = 6;
module main_floor_vent_bank(cx, cy) {
    bank_w = vent_cols*vent_slot_w + (vent_cols-1)*vent_slot_gap;
    for (i = [0:vent_cols-1])
        translate([cx - bank_w/2 + i*(vent_slot_w+vent_slot_gap), cy - vent_slot_len/2, -1])
            cube([vent_slot_w, vent_slot_len, new_floor_t+2]);
}
module main_floor_vents() {
    // 6 banks now (was 4) for more ventilation; kept away from X=140 (a
    // screw boss position runs down that column at both Y=25 and Y~143).
    main_floor_vent_bank(board_w*0.25, board_d*0.25);
    main_floor_vent_bank(board_w*0.25, board_d*0.75);
    main_floor_vent_bank(board_w*0.5,  board_d*0.35); // between the two screw columns; nudged
                                                        // down from board_d*0.5 to clear the CN4 rib
    main_floor_vent_bank(board_w*0.75, board_d*0.25);
    main_floor_vent_bank(board_w*0.75, board_d*0.75);
}

// Discrete support ribs along the rear wall, between specific named
// connectors -- per direction from the user, the real case has these
// (rather than one continuous shelf) because some rear connectors have
// solder tabs protruding from the PCB underside that need to lay flat, so
// the support has to be interrupted right where those tabs are. Positions
// are the midpoint between each named pair's real (mirrored) X. Span from
// the rear wall's inner face inward by rear_rib_depth; top flush with
// standoff_height, same as every other support feature.
rear_rib_w = 2.4;
rear_rib_depth = 10;   // was 5 -- per direction, "the main part of those should be another 5mm long from the back" 
function rear_rib_x(refdes) = [for (c = board_connectors) if (c[0]==refdes) c[1]][0];
rear_rib_positions_base = [
    (rear_rib_x("SW1") + rear_rib_x("JK1")) / 2 + 2, // +2: per direction, "the rib to the
        // left of JK1 needs to be 2mm further to the left" (+X = left, per this file's
        // own convention) -- the only rib between SW1 and JK1, i.e. the one immediately
        // left of JK1
    (rear_rib_x("JK2") + rear_rib_x("JK3")) / 2,
    (rear_rib_x("JK4") + rear_rib_x("J5A")) / 2, // "other side of JK4" from JK3
    (rear_rib_x("J5A") + rear_rib_x("J5B")) / 2, // between video and sound
];
// Hinged one-piece: the leftmost rib (SW1/JK1) moves to the middle of the gap between those two ports' openings, so
// its fin up the back plate (main_plate_rib_fins) sits clear of both.
function rear_gap_mid_near(x) = let (gs = rear_gaps(), d = [for (g = gs) abs(g[0] - x)], m = min(d))
    [for (i = [0 : len(gs) - 1]) if (d[i] == m) gs[i][0]][0];
rear_rib_positions = onepiece_hinged
    ? concat([rear_gap_mid_near(rear_rib_positions_base[0])], [for (i = [1 : len(rear_rib_positions_base) - 1]) rear_rib_positions_base[i]])
    : rear_rib_positions_base;
rib_wall_bump_h = 1.6; // per direction: "where it intersects the wall... 1.6mm higher,
                         // for a distance of 1mm from the wall only. for the rest I want
                         // it to be the same height it currently is" -- applies to every
                         // rib (main_rear_support_ribs() below and main_cn4_rib()'s own
                         // wall-to-wall low segment)
rib_wall_bump_run = 2;   // was 1 -- per direction, "[the top part] needs to be 1mm longer" 
module main_rear_support_ribs() {
    inner_wall_y = -(rear_margin - wall);
    for (x = rear_rib_positions) {
        translate([x - rear_rib_w/2, inner_wall_y, 0])
            cube([rear_rib_w, rear_rib_depth, standoff_height]);
        translate([x - rear_rib_w/2, inner_wall_y, standoff_height])
            cube([rear_rib_w, rib_wall_bump_run, rib_wall_bump_h]);
    }
}

// CN2's real position, confirmed from coco3.step (kept as a reference
// anchor -- CN4, below, is positioned relative to it): found the
// NEXT_ASSEMBLY_USAGE_OCCURRENCE labeled 'CN2' (#18505), traced its
// ITEM_DEFINED_TRANSFORMATION (#18503) to placement #15 -> CARTESIAN_POINT
// #16 = (100.43, -106.416, 8.58) in the board's raw frame. Cross-checked:
// the very next placement in that same list, #19, is EXACTLY J5A's
// already-known real position (176.10, -1.74) -- confirming this
// extraction method against a known value before trusting it for CN2.
cn2_xy_raw = [100.43, -106.416];
function cn2_xy() = [board_pt(cn2_xy_raw[0], cn2_xy_raw[1])[0], board_pt(cn2_xy_raw[0], cn2_xy_raw[1])[1]];

// One more rib: near CN4 (a memory connector -- NOT the keyboard header,
// that's CN2; NOT JK4 either -- both were wrong guesses on the way here).
// CN4 does not appear anywhere in coco3.step's labeled parts (neither does
// IC12, which was offered as a second reference point) -- this STEP export
// is missing quite a few refdes labels (J5A/J5B aren't in it either, despite
// being real/confirmed connectors elsewhere in this file), so this can't be
// independently verified the way CN2 was. Positioned per description
// instead: "15mm behind CN2, and parallel with it" -- "behind" taken as
// toward the REAR (lower Y in this file's transformed frame, since CN2
// sits well toward the front at Y=106.4 and "behind" a front-ish
// component most naturally means further from the front); "parallel"
// taken as same X as CN2 and same orientation (along X, matching the
// board's length axis). FLAG: the rear-direction assumption is NOT
// independently confirmed -- if CN4 turns out to be 15mm the OTHER way
// (toward the front), flip cn4_xy_raw's Y sign-offset below.
// Rib itself: rotated 90deg from the other rear ribs per direction -- runs
// IN LINE WITH CN4 (along X), offset 5mm from it in Y (toward the rear,
// same uncertainty as above -- only CN4's estimated ORIGIN is known, not
// its real footprint/edge, so this offsets from that estimate).
cn4_rib_len = 20;
cn4_xy_raw = [cn2_xy_raw[0], cn2_xy_raw[1] + 15]; // 15mm "behind" CN2 = further
                                                    // from the front = raw Y
                                                    // increases (less negative)
                                                    // since transformed Y = -raw Y
function cn4_xy() = [board_pt(cn4_xy_raw[0], cn4_xy_raw[1])[0], board_pt(cn4_xy_raw[0], cn4_xy_raw[1])[1]];
cn4_rib_y_offset = -5;
cn4_rib_brace_w = 5;
cn4_rib_brace_run = 8;
// Per direction: not another fillet like the main beam's -- take this rib
// and extend it all the way across, but low -- 3mm, not standoff_height --
// for extra lateral stiffness across the floor without turning it into a
// second full-height beam. "All the way" means actually wall-to-wall (the
// real side walls' own inner faces, same as main_standoffs_braces()
// reaches for), not just the beam_margin inset main_support_beam uses --
// that first pass fell short of that per direction ("that rib doesn't run
// the full length either"). The original tall 20mm segment (the real
// contact point near CN4) is untouched. Kept clear of the kbpcb bay (same
// gap main_support_beam cuts for itself) and the raceway's own open
// channel (only the channel gap -- it still crosses/merges with the
// raceway's solid legs on either side, which only adds more connection
// there).
cn4_rib_low_h = 3;
module main_cn4_rib() {
    xy = cn4_xy();
    rib_y = xy[1] + cn4_rib_y_offset;
    right_wall_x = -(case_margin - wall);        // inner face of the min-X wall
    left_wall_x  = board_w + (case_margin - wall); // inner face of the max-X wall
    translate([xy[0] - cn4_rib_len/2, rib_y - rear_rib_w/2, 0])
        cube([cn4_rib_len, rear_rib_w, standoff_height]);
        
    difference() {
        translate([right_wall_x, rib_y - rear_rib_w/2, 0])
            cube([left_wall_x - right_wall_x, rear_rib_w, cn4_rib_low_h]);
//        translate([main_kbpcb_origin[0] - 1, rib_y - rear_rib_w/2 - 1, -1])
//            cube([kbpcb_w + 2, rear_rib_w + 2, cn4_rib_low_h + 2]);
        translate([raceway_x - raceway_w/2 - 0.5, rib_y - rear_rib_w/2 - 1, -1])
            cube([raceway_w + 1, rear_rib_w + 2, cn4_rib_low_h + 2]);
    }
    // 1.6mm bump for the last 1mm where this low, wall-to-wall segment
    // meets each side wall -- same rib_wall_bump_h/run as the rear ribs.
    translate([right_wall_x, rib_y - rear_rib_w/2, cn4_rib_low_h])
        cube([rib_wall_bump_run, rear_rib_w, rib_wall_bump_h]);
    translate([left_wall_x - rib_wall_bump_run, rib_y - rear_rib_w/2, cn4_rib_low_h])
        cube([rib_wall_bump_run, rear_rib_w, rib_wall_bump_h]);
    // Per direction: this rib is short and completely freestanding -- never
    // part of the main support beam, no wall nearby to brace against --
    // so one angled gusset at its middle, tapering down to the open floor
    // toward the rear, is enough (same reasoning as the kbpcb boss braces).
    cross_brace_wedge(xy[0], cn4_rib_brace_w, rib_y, rib_y - cn4_rib_brace_run, standoff_height);
}

// Mounting for the Pico keyboard-controller board (Coco_pico_keyb),
// relocated into the MAIN case near CN2 -- per direction, this board can
// end up here (as well as in the keyboard tray, depending on the
// software/use mode: coco-keyboard<->USB passthrough, or connecting a
// Bluetooth keyboard). Reuses the board's REAL mounting-hole pattern
// (kbpcb_standoffs, already real data from Coco_pico_keyb.step), just with
// a new origin instead of the keyboard tray's own kb_pcb_origin. SCREW
// BOSSES (self-tapping pilot, like the top/bottom shell fasteners), not
// plain standoff pegs, per explicit correction.
// Position: X is chosen so the Pico's USB connector (pico_pos, real data
// from Coco_pico_keyb.step) lines up with the EXISTING front-panel USB
// passthrough cutout (main_usb_passthrough_front, at the middle of the
// front wall, X=board_w/2=140) -- per direction, "USB poking out the
// middle front." Y is now driven off kbpcb_pt's corrected (proper,
// non-mirrored) orientation -- per direction ("aligned to the front edge
// ... USB connector accessible, LEDs visible, button protrudes") -- so the
// board's panel edge (local Y=kbpcb_d, where the USB end of the Pico and
// D1/D2/SW1 all cluster) sits just inside the front wall's inner face
// instead of ~40-65mm back from it. kbpcb_front_clearance is the only
// slack left between that edge and the wall.
kbpcb_front_clearance = fp_out_gap + fp_t + kbpcb_edge_poke + 0.7 + 0.2 - wall;   // = 1.63: puts the PCB edge the same 1.23mm from the plate
                           // as board A is in the keyboard (plate inner face is 0.4 inside the wall's inner face)
// board_d + case_margin here is the same value as main_front_y, computed
// locally (not by referencing main_front_y itself) because main_front_y is
// a top-level variable defined much later in file order -- referencing it
// here would silently evaluate to undef (same class of ordering pitfall as
// the raceway comment above about parting_h/pcb_edge_lip_height).
main_kbpcb_origin = [board_w/2 - kbpcb_hdr_cx,
                      (board_d + case_margin) - wall - kbpcb_front_clearance - kbpcb_d];
kbpcb_screw_boss_d = 7;
kbpcb_screw_pilot_d = m3_pilot_d; // self-tap/heat-set pilot for the board's 3.2mm holes
// kbpcb_screw_boss_h (6) is defined up with the keyboard shell parameters: board A's height, and through it the
// keyboard's depth, depends on it, and the main case's skirt is derived from that depth.
// Reuses all 4 of the board's REAL mounting holes (kbpcb_standoffs) -- this
// is the actual physical Pico keyboard-controller PCB's own hole pattern,
// so every hole should get a boss unless there's a real fit conflict.
kbpcb_boss_brace_w = 4;
kbpcb_boss_brace_run = 5; // short -- these bosses are only 6mm tall to begin with
module main_kbpcb_mount() {
    for (s = kbpcb_standoffs) {
        x = main_kbpcb_origin[0] + s[0];
        y = main_kbpcb_origin[1] + s[1];
        translate([x, y, 0])
            difference() {
                cylinder(d = kbpcb_screw_boss_d, h = kbpcb_screw_boss_h);
                translate([0,0,-1]) cylinder(d = kbpcb_screw_pilot_d, h = kbpcb_screw_boss_h + 2);
            }
        // Small angled gusset per boss, per direction -- tapers down toward
        // the rear (-Y, open floor, clear of the board's own Y range and
        // of the neighboring bosses in X) rather than reaching for a wall,
        // since none of these bosses sit next to one.
        cross_brace_wedge(x, kbpcb_boss_brace_w, y, y - kbpcb_boss_brace_run, kbpcb_screw_boss_h);
    }
}

// D1/D2 (LEDs) and SW1 (button) access -- per direction, "It also has 2 leds
// and a button that we'll need access to." CORRECTED per direction: all
// three are mounted RIGHT-ANGLE (90 degrees) on the board, so they don't
// point up at the roof at all -- they point OUT toward the board's front
// (panel) edge, at a height above the PCB surface (their legs bend up off
// the pad position, then turn horizontal). So the access cut is a
// HORIZONTAL hole through the FRONT WALL, not a vertical one through the
// roof, centered 4mm above the PCB's top surface (per direction, "mounted
// 4mm above the plane of the pcb"), running from just behind each
// component's pad position (kbpcb_led1_pos etc -- real STEP data, the
// pad/leg location, not the bent-over head) out through the wall.
// LED holes shrunk 6 -> 4mm per direction ("not enough material there
// currently") -- the real pad spacing is tight (D1/D2 ~5.96mm
// center-center, D2/SW1 ~7.04mm), so uniform 6mm holes left D1+D2 fully
// merged and D2/SW1 down to ~1mm of wall between them. At 4mm LED holes
// there's a real ~2mm web on both sides again. Button stays 6mm (needs
// room for the actual plunger, per the earlier "button shaft protrudes"
// direction) -- it's the SW1/D2 gap that benefits most since D2 is now
// the smaller of that pair.
kbpcb_led_access_d = 4.4;    // LED body ~3.4 + clearance
kbpcb_button_access_d = 6;   // SW1 (keyboard PCB button): a small round hole over the middle of its 7.4 x 6.9 cap
kbpcb_pcb_top_z = kbpcb_screw_boss_h + kbpcb_thickness; // top surface of the mounted PCB
module main_kbpcb_led_button_access() {
    // board_d + case_margin here is the same value as main_front_y, computed
    // locally rather than referencing main_front_y itself -- see the same
    // ordering note on main_kbpcb_origin above.
    front_wall_outer_y = board_d + case_margin;
    for (p = [kbpcb_led1_pos, kbpcb_led2_pos]) {
        x = main_kbpcb_origin[0] + p[0];
        y0 = main_kbpcb_origin[1] + p[1] - 2; // start a couple mm behind the pad, safely inside the cavity
        translate([x, y0, kbpcb_pcb_top_z + kbpcb_led_z])
            rotate([-90, 0, 0])
                cylinder(d = kbpcb_led_access_d, h = (front_wall_outer_y + 2) - y0);
    }
    // button: small round hole centred on the REAL cap position (x 128.75, 3.49 above the PCB top)
    b = kbpcb_button_pos;
    translate([main_kbpcb_origin[0] + b[0], main_kbpcb_origin[1] + b[1] - 2, kbpcb_pcb_top_z + kbpcb_btn_z])
        rotate([-90, 0, 0])
            cylinder(d = kbpcb_button_access_d, h = (front_wall_outer_y + 2) - (main_kbpcb_origin[1] + b[1] - 2));
}

// Cable raceway module bodies live here, but the raceway_x/y0/y1/len
// VALUES are defined further down, right after cn3_open (needed for
// raceway_y1) -- top-level variable EXPRESSIONS (unlike module/function
// bodies) evaluate immediately in file order in OpenSCAD, so referencing
// cn3_open here (before its own definition) silently evaluated to undef.
// Same class of ordering issue as the earlier parting_h/pcb_edge_lip_height
// fix -- moved the values, not the modules, since modules ARE lazily
// resolved and fine to keep here.
// Walls + closed, self-supporting TOP as ONE extruded solid (a single 2D
// "n"-shaped profile -- two legs plus a teardrop roof bridging them -- swept
// along Y with linear_extrude), rather than 3 separate hulled pieces unioned
// together. Open on the BOTTOM (cable rests directly on the case floor,
// nothing blocking it there) with a CLOSED top capping over it, tunnel/arch
// style. A true rounded (semicircular) top would need support past roughly
// the 45deg overhang point; this is the standard fix -- a teardrop/Gothic-
// arch roof (two straight 45deg faces meeting at a peak) -- no single face
// ever exceeds 45deg from vertical, so it prints clean with zero support.
// Rebuilt from an earlier hull()-of-3-thin-rails version after the STL
// connected-components check found a 110-triangle chunk of the channel
// orphaned specifically when main_cn3_collar() joined the union -- a CGAL
// robustness trip-up from a thin tunnel shape partly embedded inside a much
// larger overlapping solid block. A single simple polygon extrusion is much
// less prone to that than 3 near-degenerate hulled solids meeting a big box.
module main_cable_raceway_shell() {
    half_w = raceway_w/2 + raceway_wall_t; // outer span (both legs + roof)
    inner  = raceway_w/2;                  // each leg's inner face
    apex_h = raceway_h + half_w;
    // Interior roof peak, not a flat ceiling -- per direction, the flat
    // span between the two leg tops (the old [-inner,raceway_h] to
    // [inner,raceway_h] straight segment) was a real horizontal bridge/
    // overhang as seen from INSIDE the channel looking up, even though the
    // OUTSIDE of the roof was already a self-supporting 45deg slope. Uses
    // the exact same slope as the outer roof (rise 1 : run 1, from
    // leg-top up by `half_w` to the outer apex) so the two surfaces are
    // parallel and the roof becomes a constant-thickness shell (~1.4mm)
    // instead of a solid wedge -- no flat span anywhere, inside or out.
    inner_apex_h = raceway_h + inner;
    profile = [
        [-half_w, 0], [-half_w, raceway_h], [0, apex_h], [half_w, raceway_h],
        [half_w, 0], [inner, 0], [inner, raceway_h], [0, inner_apex_h], [-inner, raceway_h], [-inner, 0]
    ];
    translate([raceway_x, raceway_y1, 0])
        rotate([90, 0, 0])
            linear_extrude(height = raceway_len)
                polygon(points = profile);
}
module main_cable_raceway_bumps() {
    n = floor(raceway_len / raceway_bump_pitch);
    for (i = [0:n]) {
        y = raceway_y0 + i*raceway_bump_pitch + raceway_bump_pitch/2;
        if (y < raceway_y1 - raceway_bump_w/2) {
            side = (i % 2 == 0) ? -1 : 1;
            bx = (side < 0) ? (raceway_x - raceway_w/2) : (raceway_x + raceway_w/2 - raceway_bump_d);
            translate([bx, y - raceway_bump_w/2, 0])
                cube([raceway_bump_d, raceway_bump_w, raceway_h*0.7]);
        }
    }
}
module main_cable_raceway() {
    main_cable_raceway_shell();
    main_cable_raceway_bumps();
}
// Subtractive: opens BOTH ends of the raceway channel all the way through
// the solid wall each one dead-ends against. Without this, the channel's
// own hollow (open bottom, between the two legs) stops flush at each wall's
// FACE but never actually connects to anything past it -- confirmed via a
// real cross-section render: at the CN3 end the channel's far face sits
// right at the CN3 collar's OUTER face, so a full cn3_collar_t (2.4mm) of
// solid collar wall still separates the channel from CN3's actual 42x42
// access opening; at the rear-wall end, the channel's near face sits right
// at the wall's INNER face, so the full rear wall thickness blocks it from
// going any further. Cut a slot matching the channel's own open
// cross-section (raceway_w wide, raceway_h tall) straight through each
// wall so the hollow genuinely continues through, per direction ("the ends
// need to be open").
module main_cable_raceway_end_cuts() {
    translate([raceway_x - raceway_w/2, -rear_margin - 1, -0.5])
        cube([raceway_w, rear_margin + 2, raceway_h + 1]); // through the rear wall
    translate([raceway_x - raceway_w/2, raceway_y1 - 0.5, -0.5])
        cube([raceway_w, cn3_collar_t + 2, raceway_h + 1]); // through the CN3 collar wall
}
// Subtractive: removes the case FLOOR itself under the raceway's open
// CABLE PATH (the channel gap between the two legs), for its full length.
// Per direction: "I expect no case floor under the raceway. the cable
// needs to be inserted from under the case" -- a genuinely different ask
// than the earlier "open bottom" pass (which left the channel open above
// the floor, cable resting ON it) and the end-opening cuts above (which
// open the two Y ends through the neighboring walls, not the floor
// underneath). This cut goes through the floor's full thickness (Z
// 0..new_floor_t) so the channel is reachable from the true exterior
// underside of the case -- a cable can be pushed up into it from below.
// Deliberately sized to the raceway_w channel gap ONLY, not the full
// raceway_w+2*wall_t outer span (which would also eat into the two legs'
// own material for the bottom ~2.4mm of their height, since they start at
// the same Z=0 the floor does) -- that would leave the legs' ~119mm span
// bridging on nothing but their two end walls for their first few mm,
// unsupported and unprintable. The legs keep their normal floor footing;
// only the actual open cable path loses its floor.
module main_cable_raceway_floor_cut() {
    translate([raceway_x - raceway_w/2, raceway_y0 - 0.5, -0.5])
        cube([raceway_w, raceway_len + 1, new_floor_t + 1]);
}

function cn1_xy() = [board_pt(236.69, -61.13)[0], board_pt(236.69, -61.13)[1]];

// Molded pedestal under the cartridge-connector (CN1) area of the PCB, top
// flush with standoff_height so it braces the board directly, the same way
// a stock case bottom does -- confirmed from a photo of a real stock case
// bottom, which has an analogous raised platform under its cart-slot area.
// Without this, cartridge insertion force would be reacted entirely by the
// PCB and its standoffs instead of by the case structure.
//
// Spans from the min-X wall's inner face out to CN1 itself (NOT inward past
// CN1, which an earlier version had backwards): the platform's job is to
// brace the board against a cartridge cantilevered OUTWARD past the case
// edge, so it belongs between the connector and the wall, not on the far
// side of it toward the board's interior/the other standoffs.
//
// Widened 100 -> 120 per direction -- both guide walls (see
// main_cart_guide_walls, span ~[2.4, 4.9] and ~[117.4, 119.9]) were
// floating above open air past this platform's old edges (111.13 short
// of the front guide, 11.13 short of the back guide). 120 gets under both
// with a little margin, while stopping short of the actual rear corner
// (Y=0) rather than running flush into it.
cart_support_span_y = 120;
module main_cart_slot_support() {
    xy = cn1_xy();
    inner_wall_x = -(case_margin - wall); // inner face of the min-X wall
    translate([inner_wall_x, xy[1] - cart_support_span_y/2, 0])
        cube([xy[0] - inner_wall_x, cart_support_span_y, standoff_height]);
}

// Guide walls flanking the cartridge slot, rising from the support
// platform, so a Multipak/cartridge edge is registered side-to-side as
// it's pushed in -- matches the raised guide structure visible at the
// cart-slot corner of a real stock case bottom (Img_9744). Same span as
// the support platform above (wall to CN1), for the same reason.
// cart_guide_span sized so the walls' own INNER clear gap matches the
// real cut opening (cart_slot_w + cart_slot_margin_w = 110) -- per
// direction, "the cart port guides... are not wide enough": this was
// still 96, sized against a stale 92mm slot-width placeholder from
// before the real 108mm cartridge dimension was known, so it was
// actually narrower than the opening itself.
// BUG FIXED (found by measuring the exported STL, not the code): the walls used to be
// CENTERED at +-(surface_w + 2t)/2, which puts their INNER faces at +-(surface_w + t)/2
// -- a 112mm gap for a 109.5 opening (the comment above claimed it matched; it never did).
// Now the INNER faces are placed exactly, and they TAPER with the slot's own funnel:
// cart_slot_surface_w wide where the wall meets the platform, narrowing to the card's
// real width (cart_slot_w + cart_slot_connector_margin_w) right at CN1 -- the same
// line main_cart_slot_cut() follows through the top shell. Walls keep a constant
// cart_guide_t thickness measured outward from that inner face.
cart_guide_h    = 18;
cart_guide_t    = 2.5;
function cart_gap_at(x) =
    let (wall_x = -case_margin, x1 = cn1_xy()[0],
         w1 = cart_slot_w + cart_slot_connector_margin_w)
    cart_slot_surface_w - (cart_slot_surface_w - w1) * (x - wall_x) / (x1 - wall_x);
// One guide wall's plan-view shape (side = +1 / -1 about the slot centreline).
module cart_guide_2d(side) {
    x0 = -(case_margin - wall);   // inner face of the side wall
    x1 = cn1_xy()[0];
    cy = cn1_xy()[1];
    g0 = cart_gap_at(x0)/2; g1 = cart_gap_at(x1)/2;
    if (side > 0)
        polygon([[x0, cy+g0], [x1, cy+g1], [x1, cy+g1+cart_guide_t], [x0, cy+g0+cart_guide_t]]);
    else
        polygon([[x0, cy-g0-cart_guide_t], [x1, cy-g1-cart_guide_t], [x1, cy-g1], [x0, cy-g0]]);
}
module main_cart_guide_walls() {
    for (side = [-1, 1])
        translate([0, 0, standoff_height])
            linear_extrude(height = cart_guide_h) cart_guide_2d(side);
}

// CN3 (RGB, DIN-8 likely) is documented as bottom-mounted on the PCB. Per
// direction from the user, it needs to be accessed through the BASE
// (bottom) shell as a RECTANGULAR opening, with a collar wall rising to
// standoff_height (same height as the cart support platform / standoff
// tops) guiding up to PCB level -- and it's stepped, per a photo of a real
// stock case bottom (Img_9744): a wider lead-in near the floor, narrowing
// higher up. Real CoCo3 opening is ~40x40mm; kept at 42x42 here per the
// user's own margin call (plug adapters may assume that clearance).
// Step dimensions (extra width + step height) are a first-pass guess --
// the photo isn't clear enough at this resolution to measure precisely;
// retune once you can measure the real feature.
// cn3_bump: the whole CN3 access feature -- the floor opening, collar, shelf, hopper and raised pedestal (the "RGB bump").
// Off: plain floor there; the corner screw boss (cn3_new_standoff_xy) stays, as a full-height post braced to the side
// wall (X, running on into the support beam's end) and to the front wall (Y). Off by default in the one-piece build.
cn3_bump = !one_piece_bottom;
cn3_brace_w    = 3;
cn3_brace_drop = 3;     // braces stop this far below the board's underside (clear of solder tails near the board edge)
cn3_open       = 42;
cn3_collar_t   = wall;
// FOUND IT: cn3_step_extra was 3mm, wider than cn3_collar_t (2.4mm) -- the
// lead-in step's half-width (21+3=24) EXCEEDED the collar's own outer
// half-width (21+2.4=23.4), so for the bottom 6mm of height the "wider
// opening" cut didn't just widen the hole, it ate straight through the
// collar's wall on all four sides and into the floor beyond it, severing
// the upper collar from the floor entirely. This is what was actually
// causing the visible gap (confirmed floating in Bambu/Orca slicer
// preview) -- my own STL connected-components check missed it, most
// likely because coordinate rounding papered over the sub-mm remaining
// contact at the very corners. Real lesson: keep step_extra safely below
// collar_t so the lead-in only ever thins the wall, never fully removes it.
// Tightened further, 1.2 -> 0.4mm, per direction ("the walls all should be
// 2mm at least") -- collar_t (2.4) - step_extra must leave >= 2mm, see
// cn3_wall_min below.
cn3_step_extra = 0.4;
cn3_step_h     = 6;
function cn3_xy() = [board_pt(230.31, -140.51)[0], board_pt(230.31, -140.51)[1]];

// Cable raceway: an OPEN channel (half-pipe style -- no ceiling, so it
// prints with zero support, per explicit direction to avoid anything that
// would need support like routing under the cart platform). 8mm clear
// internal width, small 1.6mm retention bumps alternating sides every
// 20mm to snap-retain a cable despite the open top. Routed from CN3's
// opening straight back to the rear wall, offset 3mm off CN3's own X for
// clearance from the cart support platform's edge (CN1 sits at X=11.83,
// only ~6.4mm from CN3's raw X -- tight enough that centering directly on
// CN3 would nearly clip it).
raceway_w          = 8;
raceway_wall_t     = 2;
raceway_h          = 5;   // first-pass, not specified -- tall enough to
                           // contain a ribbon/small round cable
raceway_bump_d     = 1.6;
raceway_bump_w     = 4;
raceway_bump_pitch = 20;
raceway_x  = cn3_xy()[0] + 3 + 12; // shifted 12mm further from CN3 (was +3) per direction,
                                     // to make room near the right-rear topbottom screw
                                     // boss (main_topbottom_screw_rr_x, centered 35mm in
                                     // from the case's own right edge)
raceway_y0 = -(rear_margin - wall);      // rear wall inner face
raceway_y1 = cn3_xy()[1] - cn3_open/2 - cn3_collar_t + 0.01; // butt flush
                           // against the CN3 collar's own outer face (with
                           // a hair of overlap for a clean manifold seam)
                           // instead of running 2.4mm deep INTO/through the
                           // collar block -- that deep interior overlap
                           // (small thin tunnel embedded inside a much
                           // larger solid box) was a real CGAL robustness
                           // trip-up: confirmed via the STL connected-
                           // components check that adding main_cn3_collar()
                           // to the union reliably orphaned a 110-triangle
                           // chunk of the raceway's channel floor (isolated
                           // by bisecting which additive module caused it).
raceway_len = raceway_y1 - raceway_y0;

// Per direction: not a corner notch after all -- the whole front wall
// moves back (toward the rear). Back and left stay at their original
// position. Tuned by hand directly in this file to 5mm front -- still
// leaves the collar's remaining footprint short of the access-cut hole
// (42x42, unchanged, see main_cn3_access_cut() below) on that side, so
// there's no wall material near the hole there -- open on the front (by a
// few mm now, not the full inset), still a real 2.4mm frame elsewhere.
//
// The right inset (was 6mm, same "open by a few mm" idea) is REMOVED per
// direction -- "the wall holding up that platform, closest to the right
// side, just isn't there": the pedestal above needs real support on that
// side, not an opening.
cn3_collar_front_inset = 5;
cn3_collar_right_inset = 0;
module main_cn3_collar() {
    // Additive collar wall around the opening, floor to cn3_pedestal_base_h.
    // NOTE: reverted a z=-0.5 "defensive overlap" tried here -- that would
    // have pushed the collar 0.5mm BELOW the case's actual exterior bottom
    // surface (the floor's own bottom, z=0, IS the true bottom of the
    // whole case), which is a real, visible defect, not a fix. Also, on
    // reflection, a coincident face is only a known degenerate case for
    // CGAL *intersection*, not for union of two adjacent solids that share
    // a flat boundary (which is completely normal -- every standoff peg in
    // this file already does exactly that at z=0 without issue). So this
    // wasn't the right diagnosis; still investigating why this reads as
    // floating.
    xy = cn3_xy();
    x0 = xy[0] - cn3_open/2 - cn3_collar_t + cn3_collar_right_inset; // right, moved in
    y0 = xy[1] - cn3_open/2 - cn3_collar_t;                          // back, unchanged
    x1 = xy[0] + cn3_open/2 + cn3_collar_t;                          // left, unchanged
    y1 = xy[1] + cn3_open/2 + cn3_collar_t - cn3_collar_front_inset; // front, moved in
    translate([x0, y0, 0])
        cube([x1 - x0, y1 - y0, cn3_pedestal_base_h]);
}
// Real min wall thickness anywhere in the collar/pedestal, per direction
// ("the walls all should be 2mm at least").
cn3_wall_min = 2;
// Per direction: "the outer wall needs to drop, and be 8mm below the
// standoff height" -- the collar (outer wall) now stops 8mm short of
// standoff_height instead of reaching it, and everything above that
// (the shelf + pedestal below) makes up the difference. Moved above
// main_cn3_collar() since it now needs this value for its own height.
cn3_pedestal_drop   = 4; // was 8 -- per direction, pedestal (and the collar/space beneath
                          // it, which shares this same height reference) moved 4mm closer
                          // to the PCB
cn3_pedestal_base_h = standoff_height - cn3_pedestal_drop;
module main_cn3_access_cut() {
    // Subtractive: wider lead-in step near the floor, then the true
    // 42x42 opening the rest of the way up to standoff_height.
    xy = cn3_xy();
    translate([xy[0] - cn3_open/2 - cn3_step_extra+8, xy[1] - cn3_open/2 - cn3_step_extra, -1])
        cube([cn3_open + 2*cn3_step_extra-8, cn3_open + 2*cn3_step_extra-6, cn3_step_h + 1]);
    translate([xy[0] - cn3_open/2 + 4, xy[1] - cn3_open/2, cn3_step_h])
        cube([cn3_open-4, cn3_open-8, standoff_height - cn3_step_h + 1]);
}

// Two-tier pedestal, per a photo of the real case's CN3 boss ("coco3 rgb
// cn3 bump.jpg" -- a wider base with a narrower raised block on top,
// offset toward one corner rather than centered) and follow-up direction
// with real measurements: top-tier outline 24w x 14d, walls 2mm min (so a
// 20x10 inner opening), top of the raised tier level with the rest of the
// standoffs (standoff_height).
//
// Rebuilt as a proper visible STEP instead of 2 narrow braces reaching
// across open air: the (now shorter, see cn3_pedestal_drop) collar's top
// is bridged by a full FLAT SHELF spanning the whole 42x42 opening --
// "the outer wall needs to drop... and then have a flat surface over to
// the center collar" -- with only the pedestal's own 20x10 opening still
// open through it. The pedestal itself then sits on TOP of that shelf, so
// it's supported everywhere around its perimeter rather than just 2
// points. Both pieces added to the case OUTSIDE the access-cut
// difference() (see main_case_bottom()), same reason main_cable_raceway()
// is: within this footprint, main_cn3_access_cut() would otherwise carve
// them right back out along with everything else in the 42x42 opening.
// Back/left faces AND front/right faces are the ORIGINAL 24x14 sizing
// (15mm right-recede, 13mm back-recede from the collar's own UNCHANGED
// original position) -- reverted per direction ("undo those changes
// around cn3... I want the LOWER part reduced, not the upper part").
// Deliberately anchored to the collar's ORIGINAL footprint, not its new
// (smaller, see cn3_collar_front_inset/cn3_collar_right_inset above)
// one -- the pedestal doesn't move just because the collar's wall did.
cn3_pedestal_w           = 24;
cn3_pedestal_d           = 14;
cn3_pedestal_right_recede = 15; // pedestal's right face, in from the collar's own right face
cn3_pedestal_back_recede  = 13; // pedestal's back face, in from the collar's own back face
function main_cn3_pedestal_xy0() = [ // outer box min (right/back) corner
    cn3_xy()[0] - cn3_open/2 - cn3_collar_t + cn3_pedestal_right_recede,
    cn3_xy()[1] - cn3_open/2 - cn3_collar_t + cn3_pedestal_back_recede + 2.5
];
module main_cn3_shelf() {
    xy = cn3_xy();
    p0 = main_cn3_pedestal_xy0();
    x0 = p0[0]; y0 = p0[1];
    // Height was cn3_wall_min starting at cn3_pedestal_base_h-0.24, so its
    // own top landed at cn3_pedestal_base_h+cn3_wall_min-0.24 -- 0.24mm
    // SHORT of main_cn3_pedestal()'s own base (cn3_pedestal_base_h+
    // cn3_wall_min). A real gap there, just masked by main_cn3_new_
    // standoff() happening to bridge it at its old position -- exposed
    // once that standoff moved (per direction, disconnected pedestal
    // walls). Height increased by 0.5 (the original 0.24 short-fall plus a
    // small deliberate overlap) so the shelf genuinely reaches past the
    // pedestal's own base now, not just up to it.
    difference() {
        translate([xy[0] - cn3_open/2+4, xy[1] - cn3_open/2-2, cn3_pedestal_base_h-0.24])
            cube([cn3_open-2, cn3_open-1, cn3_wall_min+0.5]);
        translate([x0 + cn3_wall_min, y0 + cn3_wall_min, cn3_pedestal_base_h - 1])
            cube([cn3_pedestal_w - 2*cn3_wall_min, cn3_pedestal_d - 2*cn3_wall_min, cn3_wall_min + 2]);
    }
}
// 45-degree FUNNEL under the CN3 shelf, so the bottom shell prints without support there. The shelf is a flat plate
// spanning the whole 38 x 34 mm shaft with only the 20 x 10 pedestal hole through it -- a ~1000 mm2 bridge over an
// open shaft. Now the shaft narrows toward the shelf like a hopper: throat = the pedestal hole plus cn3_hopper_clear
// each side (anything that reaches the connector has to fit that hole anyway, so nothing that fits now stops
// fitting), widening at <= ~42 degrees to the shaft walls. On a side where the wall is further than the shaft's
// height allows, the funnel stops short and leaves a short flat ledge (<= ~5mm, an easy bridge) instead of getting
// shallower than 45. Starts at z = cn3_step_h, where the shaft's wide upper part begins. It doubles as a lead-in
// for a plug.
cn3_hopper_clear = 1;
module main_cn3_hopper() {
    xy = cn3_xy(); p0 = main_cn3_pedestal_xy0();
    sx0 = xy[0] - cn3_open/2 + 4;  sx1 = sx0 + (cn3_open - 4);        // the shaft's upper rectangle (see main_cn3_access_cut)
    sy0 = xy[1] - cn3_open/2;      sy1 = sy0 + (cn3_open - 8);
    tx0 = p0[0] + cn3_wall_min - cn3_hopper_clear;  tx1 = p0[0] + cn3_pedestal_w - cn3_wall_min + cn3_hopper_clear;   // throat
    ty0 = p0[1] + cn3_wall_min - cn3_hopper_clear;  ty1 = p0[1] + cn3_pedestal_d - cn3_wall_min + cn3_hopper_clear;
    z0 = cn3_step_h;
    z_top = cn3_pedestal_base_h - 0.24;                                 // underside of the shelf
    e = 0.92 * (z_top - z0);                                            // max run per side: ~42 deg
    bx0 = max(sx0, tx0 - e); bx1 = min(sx1, tx1 + e);
    by0 = max(sy0, ty0 - e); by1 = min(sy1, ty1 + e);
    difference() {
        translate([sx0 - 0.3, sy0 - 0.3, z0]) cube([(sx1 - sx0) + 0.6, (sy1 - sy0) + 0.6, z_top - z0 + 0.3]);  // +0.3 up into the shelf
        hull() {
            translate([tx0, ty0, z_top]) cube([tx1 - tx0, ty1 - ty0, 1]);
            translate([bx0, by0, z0 - 0.01]) cube([bx1 - bx0, by1 - by0, 0.01]);
        }
    }
}
module main_cn3_pedestal() {
    p0 = main_cn3_pedestal_xy0();
    x0 = p0[0]; y0 = p0[1];
    x1 = x0 + cn3_pedestal_w;
    y1 = y0 + cn3_pedestal_d;
    z0 = cn3_pedestal_base_h + cn3_wall_min; // sits on top of the shelf
    difference() {
        translate([x0, y0, z0])
            cube([x1 - x0, y1 - y0, standoff_height - z0]);
        translate([x0 + cn3_wall_min, y0 + cn3_wall_min, z0 - 1])
            cube([(x1-x0) - 2*cn3_wall_min, (y1-y0) - 2*cn3_wall_min, (standoff_height - z0) + 2]);
    }
}

// New attachment point "in that corner" (per direction) -- reverted back
// to its original size/position (7.5mm OD) along with the pedestal above.
cn3_new_standoff_hole_d = m3_pilot_d;
function cn3_new_standoff_xy() = [cn3_xy()[0] - cn3_open/2 + 8, cn3_xy()[1] + cn3_open/2 - 11]; // -9 -> -11, 2mm toward the back
module main_cn3_new_standoff() {
    // Extends 2mm further down than the pedestal's own base per direction
    // ("extend under [it] another 2mm") -- top stays at standoff_height,
    // only the bottom moves lower.
    p = cn3_new_standoff_xy();
    translate([0, 0, cn3_pedestal_base_h - 2])
        standoff_peg(p[0], p[1], cn3_new_standoff_hole_d, standoff_height - cn3_pedestal_base_h + 2);
}

// cn3_bump off: the same screw position, standing on the floor, braced in X (side wall -> post -> the support beam's end)
// and in Y (post -> front wall). Blind pilot, so the floor stays closed underneath.
module main_cn3_braced_standoff() {
    p = cn3_new_standoff_xy();
    bh = standoff_height - cn3_brace_drop;
    side_in = -case_margin + wall;        // the side wall's inner face
    front_in = main_front_y - wall;
    difference() {
        union() {
            translate([p[0], p[1], 0]) cylinder(d = cn3_new_standoff_hole_d + 4, h = standoff_height);
            translate([side_in - 0.5, p[1] - cn3_brace_w/2, 0]) cube([beam_margin + 1 - (side_in - 0.5), cn3_brace_w, bh]);
            translate([p[0] - cn3_brace_w/2, p[1], 0]) cube([cn3_brace_w, front_in + 0.5 - p[1], bh]);
        }
        translate([p[0], p[1], new_floor_t + 1]) cylinder(d = cn3_new_standoff_hole_d, h = standoff_height);
    }
}

// Groove around the OUTSIDE of the tray: starts at the SAME height as the
// standoffs (standoff_height) and rises 1.6mm (matching PCB thickness) --
// confirmed directly, after two wrong guesses in between (first a band
// starting above standoff_height, then one extended all the way up to
// parting_h -- neither matched what was actually described).
// The wall gets locally THINNER there (down from the normal `wall`) by
// having its OUTER surface step inward (recessed) -- the INNER surface
// (facing the PCB/cavity) stays flush and continuous with the wall below,
// so this is a genuine step cut into the existing wall, not a separate
// rib -- no risk of disconnected/floating geometry.
// Real stock case measures the resulting wall at 1.4mm; bumped to 1.6mm
// here for printability (1.4mm isn't a clean multiple of a 0.4mm nozzle
// line width, and it's a thin section taking repeated PCB-edge contact) --
// dial back to 1.4 if you'd rather match the real part exactly.
pcb_edge_lip_wall_t = 1.6; // wall thickness within the recessed band
pcb_edge_lip_recess = wall - pcb_edge_lip_wall_t;
module main_pcb_edge_lip_relief() {
    difference() {
        solid_from_footprint(case_margin, standoff_height, standoff_height + pcb_edge_lip_height, rear = rear_margin);
        solid_from_footprint(case_margin - pcb_edge_lip_recess, standoff_height - 1, standoff_height + pcb_edge_lip_height + 1, rear = rear_margin - pcb_edge_lip_recess);
    }
}

module main_feet_bosses() {
    // simple corner foot bosses (flat pads); replace with adhesive-foot
    // recesses if you prefer stick-on rubber feet instead of printed pads.
    positions = [[4,4],[board_w-4,4],[4,main_front_y-4],[board_w-4,main_front_y-4]];
    for (p = positions)
        translate([p[0], p[1], -new_foot_height])
            cylinder(d = 10, h = new_foot_height);
}

// outer face of the FRONT (keyboard-facing) wall. NOTE: this is NOT
// main_depth + case_margin -- main_depth = board_d + case_margin + rear_margin
// already counts the margin on BOTH the rear (-rear_margin, since the rear
// fix) and front ends, so the front outer face is board_d + case_margin
// (equivalently main_depth - rear_margin). Using main_depth + case_margin
// double-counted the margin and placed everything derived from it
// (lip-socket lugs, magnet pockets, USB passthrough, foot bosses) ~12mm
// past the real wall, floating in open space -- this is the bug behind the
// "floating cubes" between the main case and the keyboard tray.
main_front_y = board_d + case_margin;

module main_lip_socket() {
    // Lugs project OUTWARD (+Y) from the main case's front wall; they drop
    // into matching socket pockets cut into the keyboard tray's rear wall
    // (kb_socket_pockets()). First-pass interlock -- fit-check on a test
    // print and tune lug_w/lug_h/tol.
    // Rebuilt FLUSH TO THE FLOOR (Z 0..lug_h) instead of cantilevered at
    // mid-wall-height (previously Z was centered on parting_h/2, floating
    // free in open air on all 4 sides except the one face against the
    // wall) -- per direction, a lug sticking straight out from a vertical
    // wall with nothing under it is a genuine 90deg overhang and needs
    // support; sitting the lug on the floor instead makes its underside
    // Z=0, flush with the bed, so it prints as a clean self-supporting
    // extension of the floor+wall corner.
    // Keeps the original 5-slot spacing grid (board_w/6) but skips i=3 --
    // the exact center slot, X=140 -- per direction, "lose the middle one."
    lug_w = 10; lug_d = 6; lug_h = 6;
    spacing = board_w / 6;
    for (i = [1, 2, 4, 5]) {
        x = i*spacing;
        translate([x - lug_w/2, main_front_y, 0])
            cube([lug_w, lug_d, lug_h]);
    }
}

magnet_d = 6; magnet_h = 3;   // 6x3mm disc magnets (was 6x2.5) -- drives BOTH shells' pockets
// Skin of solid plastic left OVER each magnet pocket instead of cutting
// straight through to the outer face -- per direction, so the holes
// aren't visible from outside. Thin enough that the magnet still pulls
// through it fine.
magnet_face_t = 1.0;
magnet_pad_d = magnet_d + 6; // backing-pad diameter, a comfortable rim
magnet_pocket_depth = magnet_h + tol;
// The pocket must actually break through into the open interior cavity
// (behind the pad, behind the wall) -- not just stop after magnet_h worth
// of depth -- or it's a fully sealed void with no way to insert the
// magnet at all. Bore generously past both, regardless of the exact pad
// thickness computed above; the extra length beyond the magnet's own
// depth is just open air in the cavity, harmless.
// The magnet (2.5mm) is thicker than the wall itself (2.4mm), so there
// isn't enough material to both fully seat it AND leave magnet_face_t of
// solid skin without adding some -- this pad bulges into the cavity from
// the wall's inner face to make up the difference. ADDITIVE -- must be
// unioned in separately from main_magnet_pockets() below (the actual
// holes), not called from inside it: that module is used subtractively,
// so a pad added there would itself get subtracted instead of added.
magnet_pad_extra = max(0, magnet_pocket_depth + magnet_face_t - wall) + 0.4;
magnet_bore_len = magnet_pad_extra + wall + 5; // generous -- see note above
// Explicit X positions instead of an even board_w/(n+1) spacing -- that
// evenly-spaced grid (56, 112, 168, 224) put two of the four magnet bores
// dead center on the two main-beam cross braces (also at X=56 and X=112),
// which sit right at this same wall -- the deep bore needed to reach the
// cavity (magnet_bore_len) drilled straight through them. Chosen instead
// to clear both those braces (X 54.5-57.5, 110.5-113.5), the short stub's
// brace (X ~249.2-252.2), AND main_usb_passthrough_front() (X 130-150,
// same wall, same general Z band) -- the first fix (150) sat right on
// that cutout's own edge, confirmed overlapping it.
// X=165 relocated -> 265 per direction ("one of the magnet mounts on the
// front is right where an LED hole is from the keyboard controller...
// move it close to the front left corner") -- 165 sat right in the
// LED2/button cluster (X 152-171, see main_kbpcb_led_button_access above),
// both at the same wall and the same Z band (parting_h/2 here vs
// kbpcb_access_z there, close enough to collide). 265 sits in the clear
// gap between the "short stub's brace" (ends ~252.2) and the left-front
// topbottom screw boss/brace (starts ~279.17) -- checked clear of both.
main_magnet_x = [30, 62, 220, 265];   // 90 -> 62: with the keyboard's back wall right up at the PCB, X=90 (kb kx=217)
                                      // lands directly behind board A, where the wall is only 3mm thick. 62 sits clear
                                      // of the board's footprint (X 69..162) and of the beam brace at X 54.5..57.5's bore path.
module main_magnet_pads() {
    if (magnet_pad_extra > 0) {
        for (x = main_magnet_x)
            translate([x, main_front_y - wall - magnet_pad_extra, parting_h/2])
                rotate([-90,0,0]) cylinder(d = magnet_pad_d, h = magnet_pad_extra);
    }
}
module main_magnet_pockets() {
    // Blind pocket bored horizontally (+Y) into the front wall so the
    // magnet sits flush against the keyboard tray's own magnet (which
    // bores -Y into ITS rear wall -- see kb_magnet_pockets()), but now
    // stopping magnet_face_t short of the true outer face instead of
    // cutting all the way through it. Same parting_h/2 fix as
    // main_lip_socket() above -- front_deck_h/2 would put this cut partly
    // above where the bottom tray's wall actually is.
    for (x = main_magnet_x)
        translate([x, main_front_y - magnet_face_t - magnet_bore_len, parting_h/2])
            rotate([-90,0,0]) cylinder(d = magnet_d + 0.2, h = magnet_bore_len);
}

// keyboard_attached: instead of magnets, 3 M3 screws clamp the keyboard shell
// on. Driven from INSIDE this case (top shell off): through these clearance
// holes in the front wall and into pilots bored from the keyboard shell's back
// face (kb_bolt_pilots()) at the same X/Z as the magnets would have been.
// The keyboard-side position that falls inside its board-A bay is skipped
// (that wall is only kb_wall thick), see kb_bolt_xs().
module main_kb_bolt_holes() {
    for (x = kb_bolt_xs())
        translate([x, main_front_y - wall - 1, parting_h/2])
            rotate([-90,0,0]) cylinder(d = 3.4, h = wall + 2);
}

// ---- TOP/BOTTOM fastening ----
// Self-tapping screws driven from OUTSIDE the bottom shell's underside
// (same convention as the real machine: flip the assembled case over to
// service it), up through floor clearance holes into bosses that hang down
// from the top shell's ceiling. First-pass positions (3 along the rear
// edge, 3 along the front edge, inset 25mm from the rim so they clear the
// connector notches, which cut 18mm deep into the same wall); fit-check and
// retune like the other first-pass joints in this file (lip/socket, magnets).
// Removed per direction ("three standoffs in the middle... don't think
// these standoffs do anything, so they can go away") -- these were a
// rear-side row of three fastening bosses (X = board_w*[0.15,0.5,0.85],
// Y=25), mirrored to a front-side row that main_screw_pos_conflicts_bay()
// below was already filtering out entirely (all three X positions land
// inside the floppy bay's own footprint). Only the 4 corner bosses
// (main_topbottom_screw_corners) remain.
main_topbottom_screw_xy = [];
// 4 more, near the extreme corners -- per direction, so there's a solid
// top/bottom connection point right at each corner too, not just along
// the rear/front edges. Measured from the case's own TRUE corners (the
// actual outer footprint corners, before corner_r rounding).
//
// Bracing is now a straight 2mm rect from the boss's own cylinder
// straight to each of the two nearby walls (see topbottom_boss_brace_x/y
// below), not a tapered wedge -- per direction, simpler and works fine
// even when the boss sits right up against the wall (1-3mm), so most
// corners can go back to sitting close to their actual corner rather
// than needing to be moved inward to leave room for a wedge's own taper.
main_topbottom_screw_corner_inset = 6;
// The right-rear corner is a special case -- the whole rear wall from the
// cart slot to SW2 is packed edge-to-edge with connector cutouts (CN3,
// the cable raceway, SW2 itself), so this one can't just sit at the
// standard inset like the other 3. Settled position, per direction: 35mm
// in from the case's own right edge (X), clearing CN3's cutout (ends at
// X=26.16) and the cable raceway (moved 12mm further out, see raceway_x,
// to clear this position); Y nudged 2mm further forward from the
// original tight-to-the-rear-wall spot to clear the cart notch's own
// reach there.
main_topbottom_screw_rr_x = -case_margin + 35; // 35mm in from the case's own right edge
main_topbottom_screw_rr_y = 3;                 // was 1, nudged 2mm toward the front
// Right-front, left-rear, and left-front all nudged in a bit further than
// the standard inset -- per direction, 3mm further from each of their own
// two nearby walls -- both directions are just a bigger inset from that
// corner, so they share this second inset value instead of
// main_topbottom_screw_corner_inset.
main_topbottom_screw_rf_inset = main_topbottom_screw_corner_inset + 3;
main_topbottom_screw_corners = [
    [main_topbottom_screw_rr_x, main_topbottom_screw_rr_y], // right-rear (special, see above)
    [-case_margin + main_topbottom_screw_rf_inset, main_front_y - main_topbottom_screw_rf_inset], // right-front
    [board_w + case_margin - main_topbottom_screw_rf_inset, -rear_margin + main_topbottom_screw_rf_inset], // left-rear
    [board_w + case_margin - main_topbottom_screw_rf_inset, main_front_y - main_topbottom_screw_rf_inset], // left-front
];
// The front-side row (Y ~= main_depth-25) lands right inside the floppy
// bay's own footprint for X=42/140/238 -- a screw boss there would get
// sliced by the bay notch/bulkhead cut (caught as disconnected STL
// fragments). There's no structural point fastening top-to-bottom through
// what's now an open bay compartment anyway, so those positions are
// dropped rather than relocated.
//
// Margin tightened from floppy_duct_wall_t+5 (7.4mm) to 3mm -- per
// direction, the front-left/front-right CORNER bosses (after being moved
// further in, X=1.83/278.17) were landing just inside that old, overly
// generous margin around the bay's real footprint (X 8.4-271.6) and
// getting silently dropped by this same filter, even though they're not
// actually anywhere near the bay's real cut -- they were just "gone."
// 3mm is still comfortably more than the bay-conflict filter needs to
// catch the genuinely-inside positions this was written for.
function main_screw_pos_conflicts_bay(p) =
    (p[0] > board_w/2 - floppy_face_w/2 - 3)
    && (p[0] < board_w/2 + floppy_face_w/2 + 3)
    && (p[1] > floppy_bulkhead_y0 - 5);
main_topbottom_screw_positions_raw = concat(
    main_topbottom_screw_xy,
    [ for (p = main_topbottom_screw_xy) [p[0], main_depth - 25] ], // mirrored to the front-side row
    main_topbottom_screw_corners
);
main_topbottom_screw_positions = [
    for (p = main_topbottom_screw_positions_raw)
        if (!main_screw_pos_conflicts_bay(p) && !(main_hinged && p[1] < main_depth/2)) p   // hinged: the hinge holds the back
];

// TOP SCREW BOSSES (heat-set inserts), rebuilt per direction: "just enough for the screw support, a
// cylinder, with a small bridge to the nearby side if needed for strength."
//
// They used to run from the parting line ALL the way up to the roof (a ~90mm slender column now
// that the tower is tall) wrapped in a fat solid "protect" shield + brace blocks -- the "pillar
// object". Now each is just:
//   * a slim cylinder rising from the parting line -- top_boss_to_roof = true: ALL THE WAY to the roof
//     (per direction: printed roof-down, a boss that stops short hangs in mid-air and needs support;
//     one that reaches the roof grows from it with none). Its top follows the sloped roof underside
//     and sinks a hair into it. top_boss_to_roof = false gives the short chamfered stub instead
//     (top_boss_h, clipped so it never reaches the roof);
//   * a thin rib (top_boss_brace_w) from the cylinder to the nearest side wall (only as tall as the
//     side louver grooves allow, see top_side_vent_floor_z) and -- in the flat rear zone -- to the
//     rear wall (full height). The right-rear boss skips the side rib: that corridor belongs to the
//     bottom shell's cart guide wall.
// The heat-set pilot (top_boss_insert_d) is cut LAST (see main_topbottom_screw_boss_top_holes()).
top_boss_d          = 9;     // OD: 2.5mm of wall around a 4.0mm insert hole
top_boss_to_roof    = true;  // full-height (see above)
top_boss_h          = 16;    // short-stub height above the parting line (only if !top_boss_to_roof)
top_boss_chamfer    = 3.5;   // 45deg on the free end
top_boss_brace_w    = 3;     // rib thickness
top_boss_insert_d   = 4.0;   // heat-set insert bore (M3 inserts). Independent of screw_mount_type, which
                             // still governs the bottom shell's board standoffs etc.
top_boss_insert_depth = 8;   // insert bore depth from the parting line (insert ~5.7mm + room)
function main_topbottom_is_rr(p) =
    (p[0] == main_topbottom_screw_rr_x && p[1] == main_topbottom_screw_rr_y);
// short-stub height, never reaching the local roof underside (matters on the low front ramp)
function top_boss_h_at(p) = min(top_boss_h,
    local_wedge_h(p[1] + top_boss_d/2, rear_tower_h - wall, front_deck_h - wall) - parting_h - 0.8);
// roof underside height at a given Y (+0.3: sink into the roof so it fuses), measured from the parting line
top_rib_sink = 0.3;         // how far a rib's top sinks into the flat rear roof (fuses it)
top_rib_ramp_clear = 3;     // on the steep front ramp the rib top instead stops this far BELOW the roof skin: the skin
                            // is only ~1mm thick there (horizontally), and a rib top touching it leaves detached slivers
function top_roof_h_at(y) = local_wedge_h(y, rear_tower_h - wall, front_deck_h - wall)
                            + ((y > main_break1_y) ? -top_rib_ramp_clear : top_rib_sink) - parting_h;
// The side louvers are vertical grooves that start at side_vent_z0 and cut ~13.6mm deep into the case (see
// main_louvers()). A rib on a SIDE wall that reaches above that would be sliced by a groove and leave a loose
// sliver, so side ribs stop 1mm under the groove floor. (The min-X wall's grooves start higher, above the cart slot.)
function top_side_vent_floor_z(min_x_side) =
    min_x_side ? max(max(41.85 + 2, parting_h + 6), parting_h + cart_slot_h + cart_slot_margin_h + 8)
               : max(41.85 + 2, parting_h + 6);
module main_topbottom_screw_boss_top_braces() {
    right_inner_x = -(case_margin - wall);
    left_inner_x  = board_w + (case_margin - wall);
    rear_inner_y  = -(rear_margin - wall);
    sink = 0.4;   // ribs sink a hair into the wall so they fuse
    for (p = main_topbottom_screw_positions) {
        hb = top_boss_to_roof ? top_roof_h_at(p[1]) : top_boss_h_at(p) - top_boss_chamfer;
        wall_x = p[0] < board_w/2 ? right_inner_x : left_inner_x;
        if (!main_topbottom_is_rr(p)) {
            x0 = min(wall_x - (wall_x < p[0] ? sink : 0), p[0]);
            len = abs(wall_x - p[0]) + sink;
            ya = p[1] - top_boss_brace_w/2;  yb = p[1] + top_boss_brace_w/2;
            // The rib's TOP follows the roof slope (hull of two thin slabs, one per Y face): a flat-topped box sized
            // for the roof at its centre line stuck out through the roof on the steep ramp at the front corners
            // (the roof drops ~2mm per mm of Y there) and left detached slivers.
            cap = top_side_vent_floor_z(p[0] < board_w/2) - 1 - parting_h;   // stay clear of the side grooves
            if (top_boss_to_roof)
                hull() {
                    translate([x0, ya, parting_h - 0.01]) cube([len, 0.01, min(cap, top_roof_h_at(ya))]);
                    translate([x0, yb - 0.01, parting_h - 0.01]) cube([len, 0.01, min(cap, top_roof_h_at(yb))]);
                }
            else
                translate([x0, ya, parting_h - 0.01]) cube([len, top_boss_brace_w, hb]);
        }
        if (p[1] <= main_break1_y)
            translate([p[0] - top_boss_brace_w/2, rear_inner_y - sink, parting_h - 0.01])
                cube([top_boss_brace_w, abs(p[1] - rear_inner_y) + sink, hb]);
    }
}

// Heat-set bore + cone recess, cut LAST (see main_case_top()), after every solid that could
// otherwise fill them back in has been unioned -- the same rule main_standoffs_holes() and
// main_topbottom_screw_boss_bottom_holes() follow.
module main_topbottom_screw_boss_top_holes() {
    for (p = main_topbottom_screw_positions) {
        translate([p[0], p[1], parting_h - 1]) cylinder(d = top_boss_insert_d, h = top_boss_insert_depth + 1);
        translate([p[0], p[1], parting_h - 0.01])
            cylinder(d1 = topbottom_cone_base_d, d2 = topbottom_cone_top_d, h = topbottom_cone_h + 0.01);
    }
}
// The cart guide walls (bottom shell) stand up into the top shell's interior;
// nothing of the top shell may occupy their volume (+ a hair of clearance).
module main_cart_guide_top_clearance() {
    c = 0.4;
    for (side = [-1, 1])
        translate([0, 0, standoff_height - c])
            linear_extrude(height = cart_guide_h + 2*c) offset(delta = c) cart_guide_2d(side);
}

module main_topbottom_screw_boss_top() {
    boss_r = top_boss_d/2;
    rim_n = 16;
    for (p = main_topbottom_screw_positions) {
        if (top_boss_to_roof) {
            // Slanted-top cylinder: hull of the base disk and a ring of points on the top rim, each at that exact
            // point's own roof-underside height (pure algebra via local_wedge_h(), no mesh-on-mesh intersection --
            // the front-corner bosses sit on the steep ramp, where the roof drops over a boss's own width).
            hull() {
                translate([p[0], p[1], parting_h - 0.01]) cylinder(d = top_boss_d, h = 0.01);
                for (i = [0:rim_n-1]) {
                    rx = p[0] + boss_r*cos(i*360/rim_n);
                    ry = p[1] + boss_r*sin(i*360/rim_n);
                    translate([rx, ry, local_wedge_h(ry, rear_tower_h - wall, front_deck_h - wall)])
                        sphere(r = 0.6, $fn = 8);   // its top pokes 0.6 into the roof (2.4 thick)
                }
            }
        } else {
            hb = top_boss_h_at(p);
            translate([p[0], p[1], parting_h - 0.01]) {
                cylinder(d = top_boss_d, h = hb - top_boss_chamfer);
                translate([0, 0, hb - top_boss_chamfer - 0.01])
                    cylinder(d1 = top_boss_d, d2 = top_boss_d - 2*top_boss_chamfer, h = top_boss_chamfer + 0.01);
            }
        }
    }
}
// Per direction: replaces the earlier countersink (didn't print well in
// PLA) with a raised, wide boss instead -- standing up to the same height
// as the real board standoffs, with a wide head-clearance pocket on the
// underside (where the screw is actually inserted from) and a narrow
// shaft clearance continuing up from there, inside solid material the
// whole way, for real strength. Braced to BOTH nearby walls (not just the
// nearest side wall) -- per direction, moved away from the true corner
// and tied back to it with a continuous rib each way, rather than sitting
// right at the corner unbraced.
//
// Raised by 1.6mm (standoff_height -> parting_h) per direction -- these
// bosses only reached standoff_height (the PCB standoff height), 1.6mm
// SHORT of parting_h (the actual split line the two shells meet at,
// 1.6mm higher to account for the PCB's own edge lip) -- so they weren't
// actually meeting the top shell's own boss flush.
topbottom_boss_od = 10;
topbottom_boss_shaft_d = 3.6; // M3 clearance -- the screw passes through freely here,
                                // it only THREADS into the top shell's own boss above
topbottom_boss_head_d = 7;    // M3 pan/socket head clearance
topbottom_boss_head_h = 8;    // how tall the head pocket is, on the UNDERSIDE of the boss
topbottom_boss_h = parting_h; // was standoff_height -- see comment above
topbottom_cone_base_d = 7;    // cone tip base -- fits within the top boss's own 8mm OD
topbottom_cone_top_d  = 5;    // cone tip peak -- comfortably larger than the shaft hole (3.6)
topbottom_cone_h      = 1.5;
// Straight rect brace, boss's own center to a wall -- per direction,
// simpler than a tapered wedge and works fine even when the wall is only
// 1-3mm away (a wedge's own taper geometry gets awkward at that range).
// Deliberately runs to the boss's CENTER, not just its edge, so it
// overlaps the boss's own cylinder for a clean union regardless of inset.
topbottom_boss_brace_w = 2;
module topbottom_boss_brace_x(wall_x, boss_x, boss_y, h) {
    x0 = min(wall_x, boss_x);
    x1 = max(wall_x, boss_x);
    translate([x0, boss_y - topbottom_boss_brace_w/2, 0])
        cube([x1 - x0, topbottom_boss_brace_w, h]);
}
module topbottom_boss_brace_y(wall_y, boss_x, boss_y, h) {
    y0 = min(wall_y, boss_y);
    y1 = max(wall_y, boss_y);
    translate([boss_x - topbottom_boss_brace_w/2, y0, 0])
        cube([topbottom_boss_brace_w, y1 - y0, h]);
}
module main_topbottom_screw_boss_bottom_solid() {
    right_inner_x = -(case_margin - wall);
    left_inner_x  = board_w + (case_margin - wall);
    rear_inner_y  = -(rear_margin - wall);
    front_inner_y = main_front_y - wall;
    for (p = main_topbottom_screw_positions) {
        translate([p[0], p[1], 0]) cylinder(d = topbottom_boss_od, h = topbottom_boss_h);
        translate([p[0], p[1], topbottom_boss_h])
            cylinder(d1 = topbottom_cone_base_d, d2 = topbottom_cone_top_d, h = topbottom_cone_h);
        topbottom_boss_brace_x(p[0] < board_w/2 ? right_inner_x : left_inner_x, p[0], p[1], topbottom_boss_h);
        topbottom_boss_brace_y(p[1] < main_front_y/2 ? rear_inner_y : front_inner_y, p[0], p[1], topbottom_boss_h);
    }
}
module main_topbottom_screw_boss_bottom_holes() {
    // Cut separately from the boss's own solid, and LAST (see
    // main_case_bottom()) -- same reason main_standoffs_holes() already
    // is: this boss gets unioned together with the rest of the floor, and
    // a hole baked into the boss's own self-contained geometry before that
    // union would just get silently filled back in by the (un-holed) floor
    // solid underneath it wherever the two overlap. Caught per direction
    // ("can't see any hole in the bottom of those standoffs").
    //
    // Wide head-clearance pocket on the UNDERSIDE (where the screw is
    // actually inserted from outside), narrowing to the shaft clearance
    // as it continues up toward the top shell (now all the way through
    // the cone tip too, so the screw shaft has a clear path the whole way
    // up to thread into the top shell's own boss) -- per direction ("I
    // expect the wider hole to be on the underside to accommodate the
    // screw head"); had this inverted the first time.
    for (p = main_topbottom_screw_positions) {
        translate([p[0], p[1], -1])
            cylinder(d = topbottom_boss_head_d, h = topbottom_boss_head_h + 1);
        translate([p[0], p[1], topbottom_boss_head_h])
            cylinder(d = topbottom_boss_shaft_d, h = topbottom_boss_h + topbottom_cone_h - topbottom_boss_head_h + 1);
    }
}

module main_case_bottom() {
    union() {
        // main_cable_raceway() (walls + retention bumps) is added AFTER
        // every cut below, not inside the differenced union -- otherwise
        // main_cable_raceway_floor_cut() (which needs to remove the case
        // FLOOR under the channel) also eats the bottom of the retention
        // bumps, since they start at the same Z=0 the floor does and the
        // difference() can't tell "bump material" from "floor material"
        // apart. Same fix pattern as main_standoffs_holes() below, just
        // for an additive feature instead of a hole. The two wall cuts
        // (main_cable_raceway_end_cuts) still land correctly since they
        // cut the REAR WALL / CN3 COLLAR, which are still inside the
        // differenced union, not the raceway itself.
        difference() {
            union() {
                difference() { main_bottom_outer_solid(); main_bottom_inner_cavity(); }
                main_standoffs_solid();
                main_standoffs_braces();
                main_cart_slot_support();
                main_cart_guide_walls();
                if (cn3_bump) main_cn3_collar();
                main_support_beam();
                main_beam_cross_braces();
                main_rear_support_ribs();
                main_cn4_rib();
                main_kbpcb_mount();
                main_usbc_trigger_standoffs_solid();
                main_topbottom_screw_boss_bottom_solid(); // must be IN this union, not added
                    // later alongside main_cable_raceway() etc. -- the holes below are cut
                    // from this same union, so the boss needs to already be part of it or
                    // the cut has nothing here yet to remove (this was the actual bug: the
                    // solid, added afterward, just plugged the floor's own hole from above)
                if (kb_join_magnets) main_magnet_pads();
                main_faceplate_stops();
                if (kb_join_keys) main_km_pads();
                if (kb_join_magnets && lip_socket_tabs_enabled) main_lip_socket();
            }
            main_faceplate_window(); // replaces the separate USB / LED / button cutouts: the shared faceplate carries them now
            main_faceplate_floor_pilots();
            if (cn3_bump) main_cn3_access_cut();
            main_cable_raceway_end_cuts();
            main_cable_raceway_floor_cut();
            if (!onepiece_hinged) main_pcb_edge_lip_relief();
            else intersection() { main_pcb_edge_lip_relief(); onepiece_hinged_groove_zone(); }   // sides only, see there
            main_usbc_trigger_cutout();
            main_standoffs_holes(); // cut LAST, after every other solid is unioned in,
                                     // so nothing (e.g. the cart support platform,
                                     // which overlaps a couple of these) can silently
                                     // fill a pilot hole back in
            main_usbc_trigger_standoffs_holes(); // same reason, cut last
            main_topbottom_screw_boss_bottom_holes(); // same reason, cut last
            main_floor_vents();
            if (kb_join_keys) main_km_pockets();
            if (kb_join_magnets) main_magnet_pockets();
            if (kb_join_bolts) main_kb_bolt_holes();
        }
        // main_cn3_shelf() / main_cn3_pedestal() / main_cn3_new_standoff()
        // added here, same reasoning as main_cable_raceway() above --
        // outside the differenced union, so main_cn3_access_cut() (which
        // fills the whole 42x42 opening these sit inside) can't carve
        // them back out.
        main_cable_raceway();
        main_cn1_raceway_braces(); // same reasoning -- needs to merge with
                                    // the raceway's own solid roof, added
                                    // here right alongside it
        if (cn3_bump) {
            main_cn3_shelf();
            main_cn3_hopper();
            main_cn3_pedestal();
            main_cn3_new_standoff();
        } else
            main_cn3_braced_standoff();
    }
}

// ---- BADGE RECESS: a shallow rectangle in the angled front face, below the drive-bay cutout ----
// badge_width x badge_height (the height is measured ALONG the slope), badge_depth deep (perpendicular to the face),
// centred on the case. The ramp below the bay is only a ~1mm skin (wall is 2.4mm VERTICALLY, ~1mm perpendicular on
// a face this steep), so a backing pad is added behind the badge area (main_badge_pad) that leaves
// badge_backing of wall behind the recess. The badge sits centred in the strip between the bay cutout's bottom
// edge and the ramp's bottom edge (where the keyboard shelf meets it).
badge_width   = 123;
badge_height  = 14;
badge_depth   = 1.5;
badge_backing = 2.0;    // wall left behind the recess floor
badge_pad_margin = 3;   // the pad extends this far past the badge sideways
badge_corner_r = 0;     // NOT rounded, per direction -- the labels that go in this recess are square-cornered and need
                         // a tight fit, so only the wall chamfer (below) stays
badge_chamfer  = 0.6;   // the recess's wall also tapers outward by this much (per side) from floor to face instead of
                         // standing straight up -- a sharp vertical wall meeting the recess's edge was the other stringing
                         // spot (the perimeter had to jump a hard step); this gives it a gentle ramp instead
// Horizontal placement. Seen from the FRONT the machine's left is +X (the cart slot on the right is at -X). "left" lines
// the badge's left edge up with the left edge of the drive-bay opening (X = board_w/2 + floppy_face_w/2); "center" and
// "right" are the alternatives.
badge_align = "left";
badge_cx = (badge_align == "left")  ? board_w/2 + floppy_face_w/2 - badge_width/2
         : (badge_align == "right") ? board_w/2 - floppy_face_w/2 + badge_width/2
         :                            board_w/2;
ramp_m_ = (front_deck_h - rear_tower_h) / (main_break2_y - main_break1_y);   // dz/dy of the ramp (negative)
ramp_ang = atan(-ramp_m_);                                                    // ramp angle from horizontal
ramp_strip = (bay_face_z0 - front_deck_h) / sin(ramp_ang);                    // slope length: bay bottom edge -> ramp bottom edge
badge_gap = (ramp_strip - badge_height) / 2;                                  // margin above and below the badge
echo(str("Badge: ramp strip below the bay = ", ramp_strip, "mm along the slope; badge ", badge_height, "mm -> ", badge_gap,
         "mm margin each side", badge_gap < 1 ? "  ** TOO TIGHT **" : ""));
module badge_frame() {   // origin at the badge's TOP edge centre on the outer face; local Y runs DOWN the slope, Z out of the face
    t_top = badge_height + badge_gap;   // slope distance from the ramp's bottom edge up to the badge's top edge
    translate([badge_cx, main_break2_y - t_top*cos(ramp_ang), front_deck_h + t_top*sin(ramp_ang)])
        rotate([-ramp_ang, 0, 0]) children();
}
module badge_2d(grow = 0) {
    offset(r = badge_corner_r) offset(delta = -badge_corner_r + grow) square([badge_width, badge_height]);
}
module main_badge_recess() {
    // hull of the floor (nominal size, at the bottom) and a slightly larger profile at/above the outer face gives the
    // recess a shallow taper the whole way up instead of a sharp perpendicular wall -- see badge_corner_r/badge_chamfer above
    badge_frame() translate([-badge_width/2, 0, 0])
        hull() {
            translate([0, 0, -badge_depth]) linear_extrude(height = 0.01) badge_2d();
            translate([0, 0, -0.01]) linear_extrude(height = 1.01) badge_2d(badge_chamfer);
        }
}
module main_badge_pad() {
    // clipped to the outer solid so it can never poke out (the bottom of the pad is near the ramp's lower edge)
    intersection() {
        main_top_outer_solid();
        badge_frame() translate([-(badge_width/2 + badge_pad_margin), -1.5, -(badge_depth + badge_backing)])
            cube([badge_width + 2*badge_pad_margin, badge_height + 3, badge_depth + badge_backing + 0.5]);
    }
}

module main_case_top() {
    // main_pizero_hdmi_mount() is deliberately NOT included here -- it's
    // reference-only pins (see its own comment), never checked against the
    // rear-panel connector notches, and at least one pin in the current
    // pattern lands squarely inside the JK3 notch with nothing to attach
    // to -- a genuinely floating, disconnected fragment (caught by the STL
    // connectivity checker). Shown in "preview" only (see PART SELECTOR)
    // until the Pi Zero / HDMI mount gets a real designed location; keeping
    // it out of every printable top-shell part means nothing ships with a
    // piece that'll just snap off or get dropped by the slicer.
    union() {
        difference() {
            union() {
                difference() {
                    main_top_outer_solid();
                    // main_floppy_bay_duct_protect() shields its footprint from this
                    // cut, so the outer solid's own natural material stays in place
                    // there as the bay duct's walls -- see that module's own comment.
                    // main_floppy_bay_roof_fill_protect() similarly keeps the roof
                    // solid right above the bulkhead instead of hollow.
                    difference() {
                        main_top_inner_cavity();
                        union() {
                            main_floppy_bay_duct_protect();
                            main_floppy_bay_roof_fill_protect();
                            main_ceiling_fillet_protect();
                        }
                    }
                }
                main_topbottom_screw_boss_top();
                main_topbottom_screw_boss_top_braces();
                main_badge_pad();
                if (!main_hinged) {          // hinged: both belong to the back plate instead (main_back_plate)
                    main_dvio_bosses();
                    main_top_rear_gussets();
                }
                main_top_spine_ribs();
            }
            main_louvers();
            main_connector_cutouts_top();
            main_dvio_cutouts();
            main_dvio_boss_holes();
            main_floppy_bay_notch();
            main_topbottom_screw_boss_top_holes();   // last: see its comment
            main_cart_guide_top_clearance();
            main_badge_recess();
        }
        // Bulkhead and brackets added OUTSIDE the difference() above -- same
        // reasoning as main_cable_raceway() in main_case_bottom(): they're
        // built to already avoid the notch on their own, so nothing
        // upstream should be able to carve them back out.
        difference() {
            main_floppy_bay_bulkhead_solid();
            main_floppy_bay_bulkhead_holes();
        }
        main_floppy_bay_brackets();
        main_floppy_bay_bracket_cross_braces();
        main_floppy_bay_center_web();
        if (floppy_floor_fillet) main_floppy_bay_floor_fillet();
    }
}

// ---- bed-size splitting (board is 280mm > 250mm bed) ----
main_split_x = board_w/2 + BOARD_X_OFF*0; // split roughly at the midpoint; move to
                                          // dodge the cartridge slot / tall tower if needed

// SEAM LUGS -- how the left/right halves join (main bottom and main top alike). Each lug is a solid block straddling the
// seam, main_seam_lug_l each side, rooted to the floor / roof / rear wall, with:
//   * one M3 socket-head screw along X: head recessed in the LEFT half (counterbore from the lug's outer face), hex nut
//     in a slot in the RIGHT half. The slot runs from the nut out through the lug's free face (up in the bottom, down
//     in the top), which is also "up" as each shell prints, so the nut drops in. M3x10 (M3x12 also fits).
//   * one printed alignment pin on the LEFT half, into a socket in the RIGHT half.
// Placed from sections of the shells at the seam (nothing else is solid there except the floor, roof and rear wall):
//   bottom: rear (against the rear wall, clear of JK4's solder tabs above) and mid (between the centre vent bank and
//           board B's rear edge, merging with the CN4 rib). Board B covers the seam from there to the front wall.
//   top:    rear (under the roof, behind the drives), mid (under the roof between the rear and front drive brackets,
//           above the drives) and front (under the drive-bay floor slab, above the motherboard).
// All screws go in from the left with the drives out: install drives after the halves are bolted.
main_seam_lug_l      = 11;    // lug length each side of the seam (swallows the 5mm spine ribs at X 129-151)
main_seam_screw_d    = 3.4;   // M3 clearance
main_seam_head_d     = 6.2;   // M3 socket head (5.5) + clearance
main_seam_head_web   = 4;     // material between the screw head and the seam
main_seam_nut_af     = 5.5;   // M3 nut across flats
main_seam_nut_t      = 2.4;
main_seam_nut_clr    = 0.3;
main_seam_nut_web    = 3;     // material between the seam and the nut
main_seam_pin_d      = 5;
main_seam_pin_l      = 6;
main_seam_pin_clr    = 0.2;   // radial
main_seam_pin_chamfer = 0.8;
// [y0, y1, z0, z1, screw y, screw z, pin y, pin z, slot direction (+1 up / -1 down), optional [y1 left, y1 right]]
main_seam_rear_in_y = -(rear_margin - wall);   // rear wall inner face
main_seam_drive_top = floppy_opening_z0 + floppy_h + floppy_fit_clear_h;
main_seam_lugs_bottom = concat([
    [main_seam_rear_in_y - 0.5, 15, 1, 15,   3.5, 8,   10, 8,   +1],
    [board_d*0.35 + vent_slot_len/2 + 0.8, main_kbpcb_origin[1] - 1.4, 1, 15,   80, 8.5,   89, 8.5,   +1],
], main_hinged ? [
    // Hinged: the back plate is part of the bottom, so its two halves get a lug of their own, on the plate's inner face
    // above the JK4 opening (top z 41.9; bottom kept 6mm clear so the board can still be tilted in) and below the
    // hinge. The left half stays inside the 5mm gap behind the DV I/O board (its bosses stand 5mm off the wall, its
    // right edge at X~132), so it is only ~3mm deep there -- the head's counterbore opens out of its front face.
    // Screw in from the left, through that gap: bolt the halves BEFORE fitting the DV I/O board.
    [main_seam_rear_in_y - 0.5, 5.5, 48, 64,   1.1, 58,   0.5, 52,   +1,   [3.0, 5.5]],
] : []);
// The top's mid lug is carried forward until it fuses into the front drive brackets' bands (a printed hinged top snapped
// across the bare 8mm of roof between the two while its supports were being broken off; applied to every split top).
main_seam_front_band_y0 = max(floppy_notch_y0 - min(floppy_screw_front_offsets) - 12.7, floppy_rail_y0);   // as main_floppy_bay_brackets()
main_seam_lugs_top = [
    main_hinged   // hinged: the rear wall is gone from the lid, and the barrel's sweep needs y < ~6.3 kept clear
        ? [7, 21, main_seam_drive_top + 1.7, rear_tower_h - wall + 0.5,   11, 90,   17.5, 90,   -1]
        : [main_seam_rear_in_y - 0.5, 15, 82, rear_tower_h - wall + 0.5,   3.5, 88,   10, 88,   -1],
    [83, main_seam_front_band_y0 + 0.5, main_seam_drive_top + 1.7, rear_tower_h - wall + 0.5,   87.5, 90,   95.5, 90,   -1],
    [138.5, 157, 38, bay_face_z0 - wall + 0.4,   144, 42.5,   152, 42.5,   -1],
];
module main_seam_lug_blocks(lugs, side) {   // side -1 = left half, +1 = right half
    for (g = lugs) {
        y1 = len(g) > 9 ? (side < 0 ? g[9][0] : g[9][1]) : g[1];
        translate([side < 0 ? main_split_x - main_seam_lug_l : main_split_x, g[0], g[2]])
            cube([main_seam_lug_l, y1 - g[0], g[3] - g[2]]);
    }
}
module main_seam_lug_holes(lugs, side) {
    L = main_seam_lug_l;
    for (g = lugs) {
        translate([main_split_x - L - 1, g[4], g[5]]) rotate([0, 90, 0]) cylinder(d = main_seam_screw_d, h = 2*L + 2);
        if (side < 0) {
            translate([main_split_x - L - 1, g[4], g[5]]) rotate([0, 90, 0])
                cylinder(d = main_seam_head_d, h = L + 1 - main_seam_head_web);
        } else {
            nw = main_seam_nut_af + 2*main_seam_nut_clr;
            slot_h = (g[8] > 0 ? g[3] - g[5] : g[5] - g[2]) + 1;
            translate([main_split_x + main_seam_nut_web, g[4], g[5]]) {
                rotate([0, 90, 0])   // hex corners point +/-Z, flats face +/-Y: the slot's width is the across-flats
                    cylinder(d = nw / cos(30), h = main_seam_nut_t + main_seam_nut_clr, $fn = 6);
                translate([0, -nw/2, g[8] > 0 ? 0 : -slot_h])
                    cube([main_seam_nut_t + main_seam_nut_clr, nw, slot_h]);
            }
            translate([main_split_x - 0.01, g[6], g[7]]) rotate([0, 90, 0])
                cylinder(d = main_seam_pin_d + 2*main_seam_pin_clr, h = main_seam_pin_l + 0.6);
        }
    }
}
module main_seam_pins(lugs) {
    for (g = lugs)
        translate([main_split_x - 0.01, g[6], g[7]]) rotate([0, 90, 0]) {
            cylinder(d = main_seam_pin_d, h = main_seam_pin_l - main_seam_pin_chamfer + 0.01);
            translate([0, 0, main_seam_pin_l - main_seam_pin_chamfer])
                cylinder(d1 = main_seam_pin_d, d2 = main_seam_pin_d - 2*main_seam_pin_chamfer, h = main_seam_pin_chamfer);
        }
}
module main_seam_half(lugs, side) {
    difference() {
        union() {
            intersection() {
                children();
                if (side < 0) translate([-500, -500, -500]) cube([main_split_x + 500, 2000, 2000]);
                else          translate([main_split_x, -500, -500]) cube([2000, 2000, 2000]);
            }
            main_seam_lug_blocks(lugs, side);
        }
        main_seam_lug_holes(lugs, side);
    }
    if (side < 0) main_seam_pins(lugs);
}
module main_case_bottom_left()  { main_seam_half(main_seam_lugs_bottom, -1) main_bottom_part(); }
module main_case_bottom_right() { main_seam_half(main_seam_lugs_bottom, +1) main_bottom_part(); }
module main_case_top_left()     { main_seam_half(main_seam_lugs_top, -1) { main_top_part(); main_seam_front_gussets(); } }
module main_case_top_right()    { main_seam_half(main_seam_lugs_top, +1) { main_top_part(); main_seam_front_gussets(); } }
// Split tops (hinged or not): a gusset from the bottom of each centre FRONT drive bracket band down to the top of the front seam
// lug (the one under the drive-bay floor). Printed roof-down, that lug sits "above" the brackets and hung on the thin
// slab alone. Sloped so its long face is ~42 deg from vertical as printed; it fuses into the bulkhead's bottom edge on
// the way, and stays under the drive envelope (floppy_opening_z0), so the drives still slide in. As wide as the rail, so
// its top merges fully into the band (anything wider leaves a flat shelf that hangs when printed roof-down).
module main_seam_front_gussets() {
    g = main_seam_lugs_top[2];                    // the front lug: [y0, y1, z0, z1, ...]
    z_top = floppy_rail_z0;                       // the band's bottom edge
    z_bot = g[3] - 0.5;                           // just into the lug's top
    run = 0.9 * (z_top - z_bot);                  // forward reach while dropping: ~42 deg
    by1 = floppy_notch_y0 - floppy_bulkhead_t + 0.5;   // band's front end (fused to the bulkhead's back face)
    assert(z_top < floppy_opening_z0 - 1, "front gusset would reach into the drive envelope");
    for (i = [-1, 1]) {
        bay_cx = board_w/2 + i*(floppy_w + floppy_bay_gap)/2;
        side = -i;                                // the rail on the gap side of each drive
        rail_x = bay_cx + side*(floppy_w/2 + floppy_fit_clear_w/2 + floppy_rail_t/2);
        x0 = rail_x - floppy_rail_t/2;
        hull() {
            translate([x0, by1 - 8, z_top - 0.01]) cube([floppy_rail_t, 8, 0.5]);     // along the band's bottom edge
            translate([x0, g[0] + 0.01, z_bot]) cube([floppy_rail_t, run - 1, 0.5]);  // onto the lug's top
        }
    }
}

// ============================================================================
// HINGED LID (main_hinged)
// ============================================================================
// The top's rear wall -- everything behind its inner face, plus the DV I/O bosses and the rear gussets that hang off it,
// and both side walls back to the rear cartridge guide (hinge_return_y) -- is the BACK PLATE, fused onto the bottom. The rest of the top is the LID. The hinge is the case's own rounded
// rear-top edge (edge_fillet_r): its axis is that rounding's centre line, and the barrel is cut into hinge_n knuckles
// alternating lid / plate / lid ... (the lid owns both ends, with the rounded corners), on a hinge_pin_d rod along X.
// Behind the axis the lid has nothing but its knuckles, so opening swings everything else up and forward, away from
// the plate; it stops by itself somewhere past ~110 degrees when the roof's rear edge comes down onto the plate.
// The plate's knuckles get a 45-degree chin (the plate prints floor-down with the bottom); the plate gussets taper to a
// point at the bottom for the same reason. Screws: the two FRONT lid screws stay (they lock it shut); the rear two go.
// NOTE: the rear connector openings are closed windows now (the plate sits on the bottom's rear wall), so the
// motherboard goes in tilted -- rear connectors into their windows first, then lower the front.
hinge_r       = edge_fillet_r;
hinge_ay      = -rear_margin + edge_fillet_r;    // axis (the rear-top rounding's centre line)
hinge_az      = rear_tower_h - edge_fillet_r;
hinge_n       = 9;          // knuckles, odd so the lid gets both ends
hinge_clr     = 0.4;        // radial clearance around the other part's knuckles
hinge_gap     = 0.4;        // axial gap between knuckles
hinge_pin_d   = 3.3;        // 3mm rod (steel, or M3 threaded rod), full width
hinge_split_y = -rear_margin + wall;   // plate | lid: the rear wall's inner face
hinge_split_gap = 0.3;
// Corner returns: the plate wraps round both rear corners, taking the side walls with it as far forward as the rear
// cartridge guide's inner face -- a U instead of a flat 77mm-tall wall (a printed test bottom was too flexible). On the
// cartridge side the return fuses with the rear guide wall; the other side mirrors the depth.
hinge_return_y = cn1_xy()[1] - cart_gap_at(-(case_margin - wall))/2;
// The plate's share of the top: behind the split plane, plus each side wall back to hinge_return_y. grow > 0 is the
// lid's cut (split gap, and 0.3 off the lid's inside where it meets a return's inner face).
// The lid's side walls start just forward of the returns and reach the top edge, above the axis; opening, those top
// corners swing up and BACK over the returns. Clear the returns out to the farthest such point's radius (+ hinge_clr).
hinge_return_sweep_r = sqrt((hinge_return_y + hinge_split_gap - hinge_ay)^2 + hinge_r^2) + hinge_clr;
module hinge_return_sweep_clear() {
    xi0 = -(case_margin - wall);
    xi1 = board_w + case_margin - wall;
    hinge_cyl(hinge_return_sweep_r, hinge_x0 - 1, xi0 + 0.01);
    hinge_cyl(hinge_return_sweep_r, xi1 - 0.01, hinge_x1 + 1);
}
module hinge_plate_zone(grow = 0) {
    translate([-500, -500, -500]) cube([1000, 500 + hinge_split_y + grow, 1000]);
    xi0 = -(case_margin - wall);             // side walls' inner faces
    xi1 = board_w + case_margin - wall;
    translate([-500, -500, -500]) cube([500 + xi0 + (grow > 0 ? 0.3 : 0), 500 + hinge_return_y + grow, 1000]);
    translate([xi1 - (grow > 0 ? 0.3 : 0), -500, -500]) cube([1000, 500 + hinge_return_y + grow, 1000]);
}
hinge_x0 = -case_margin - 1;
hinge_x1 = board_w + case_margin + 1;
function hinge_seg(i) = let (w = (hinge_x1 - hinge_x0) / hinge_n) [hinge_x0 + i*w, hinge_x0 + (i + 1)*w];
function hinge_is_lid(i) = i % 2 == 0;
module hinge_cyl(r, x0, x1, fn = 64) { translate([x0, hinge_ay, hinge_az]) rotate([0, 90, 0]) cylinder(r = r, h = x1 - x0, $fn = fn); }
// FRONT SEAM. The lid's lowest front edge is ~80mm below the axis, so opening moves it FORWARD before it rises -- straight
// into the docked keyboard's back face, which the front skirt sits flat against. The lid/base seam at the front is
// therefore an arc about the hinge axis, through the top of the keyboard's back face: the lid keeps what is inside the
// arc and rotates along it; the sliver of front skirt (and the side walls' front-bottom corners) outside it moves to
// the base, raising the base's front to the keyboard's height.
hinge_front_z = kb_back_h - kb_dz;   // the keyboard back face's top, main frame (= front_deck_h)
hinge_front_r = sqrt((main_front_y - hinge_ay)^2 + (hinge_front_z - hinge_az)^2);
module hinge_front_arc(r) { hinge_cyl(r, hinge_x0 - 20, hinge_x1 + 20, fn = 720); }
module main_front_band() {   // base side
    difference() {
        intersection() {
            main_case_top();
            translate([-500, main_front_y - 40, -500]) cube([1000, 100, 1000]);
        }
        hinge_front_arc(hinge_front_r);
    }
}
module hinge_knuckle(i) {
    sg = hinge_seg(i);
    intersection() {
        main_top_outer_solid();
        hinge_cyl(hinge_r, sg[0] + hinge_gap/2, sg[1] - hinge_gap/2);
    }
}
module hinge_clear(lid_side) {   // clearance around the OTHER part's knuckles
    for (i = [0 : hinge_n - 1]) if (hinge_is_lid(i) != lid_side) {
        sg = hinge_seg(i);
        hinge_cyl(hinge_r + hinge_clr, sg[0] - hinge_gap/2, sg[1] + hinge_gap/2);
    }
}
module hinge_pin_hole() { hinge_cyl(hinge_pin_d/2, hinge_x0 - 5, hinge_x1 + 5); }
// Opening, the lid first moves FORWARD (its lower rear edge is ~70mm below the axis) and only then up, so anything of
// the lid tucked in behind a cartridge guide wall (which rises from the bottom into the lid) would drive into it -- the
// rear-right corner post's inner jaw did. Clear the lid out of each guide's path, sweeping hinge_swing_back behind it
// (0.3mm into the side wall's inner face, so the two don't rub).
hinge_swing_back = 15;
hinge_swing_clr  = 0.7;
module main_cart_guide_swing_clear() {
    c = hinge_swing_clr;
    for (side = [-1, 1])
        intersection() {
            hull() for (dy = [0, -hinge_swing_back])
                translate([0, dy, standoff_height - c]) linear_extrude(height = cart_guide_h + 2*c) offset(delta = c) cart_guide_2d(side);
            translate([-(case_margin - wall) - 0.3, -500, -500]) cube([1000, 1000, 1000]);
        }
}

module main_lid() {
    intersection() {
    hinge_front_arc(hinge_front_r - hinge_split_gap);
    difference() {
        union() {
            difference() {
                main_case_top();
                hinge_plate_zone(hinge_split_gap);
                hinge_clear(true);
                if (onepiece_hinged) main_lid_corner_post_clear();
                main_cart_guide_swing_clear();
            }
            for (i = [0 : hinge_n - 1]) if (hinge_is_lid(i)) hinge_knuckle(i);
        }
        hinge_pin_hole();
    }
    }
}
// Plate gussets: the rear gussets (main_top_rear_gussets) re-homed onto the plate, flipped so the point is at the
// BOTTOM (printed floor-down, the long sloped face is ~8 deg off vertical). The three short stubs by the DV I/O panel
// stay short.
module main_plate_gusset(gx, w, z_top) {
    y_wall = hinge_split_y;
    z_low = parting_h + 1;
    translate([gx - w/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = w)
        polygon([[y_wall - 0.5, z_low], [y_wall + gusset_run, z_top], [y_wall - 0.5, z_top]]);
}
module main_plate_gussets() {
    for (g = rear_gaps())
        main_plate_gusset(g[0], g[1], main_top_rear_gusset_is_stub(g[0]) ? parting_h + 1 + gusset_stub_h
                                                                           : hinge_az - hinge_r - hinge_clr - 1);
}
// Hinged one-piece: the decorative groove round the base's top edge (main_pcb_edge_lip_relief) is kept only along the
// left and right sides, forward of the back plate's corner returns -- across the back, under the plate and returns, it
// was a support-hungry, weak notch, so there it stays solid.
module onepiece_hinged_groove_zone() {
    y0 = hinge_return_y + hinge_split_gap;
    translate([-500, y0, -500]) cube([500 - (case_margin - wall), 1000, 1000]);
    translate([board_w + case_margin - wall, y0, -500]) cube([1000, 1000, 1000]);
}
// Hinged one-piece: each rear PCB rib's wall step (rib_wall_bump_run deep, just above the board) carried on up the back
// plate as a fin, as high as the plate gussets go.
module main_plate_rib_fins() {
    iy = -(rear_margin - wall);
    for (x = rear_rib_positions)
        translate([x - rear_rib_w/2, iy - 0.5, standoff_height])
            cube([rear_rib_w, rib_wall_bump_run + 0.5, hinge_az - hinge_r - hinge_clr - 1 - standoff_height]);
}
// Hinged one-piece: a solid post up each back corner, the lid screw bosses' diameter, floor to just under the hinge.
// Trimmed flat at the rear cartridge guide's inner face so the one on that side doesn't reach into the slot.
module main_plate_corner_posts() {
    r = top_boss_d/2;  iy = -(rear_margin - wall);
    for (x = [-(case_margin - wall) + r, board_w + case_margin - wall - r])
        intersection() {
            translate([x, iy + r, 1]) cylinder(r = r, h = hinge_az - hinge_r - hinge_clr - 1 - 1);
            translate([-500, -500, 0]) cube([1000, 500 + hinge_return_y - 0.3, 200]);
        }
}
// ... and the lid clears the space around them: the only lid material there was a useless full-height sliver left over
// from the top shell's inside corner rounding. Stops just above the posts, below the hinge barrel.
module main_lid_corner_post_clear() {
    r = top_boss_d/2;  iy = -(rear_margin - wall);  zt = hinge_az - hinge_r - hinge_clr - 1 + 0.5;
    for (x0 = [-case_margin - 1, board_w + case_margin - wall - 2*r - 0.5])
        translate([x0, -500, -1]) cube([(case_margin - wall) + 2*r + 1.5, 500 + hinge_return_y + hinge_split_gap, zt + 1]);
}
module main_back_plate() {
    zp = hinge_split_y + hinge_az - hinge_ay - hinge_r*sqrt(2) - 0.5;   // 45-degree tangent from the plate face to the barrel
    difference() {
        union() {
            intersection() {
                main_case_top();
                hinge_plate_zone();
            }
            main_dvio_bosses(tip = -1);
            main_plate_gussets();
            if (onepiece_hinged) { main_plate_rib_fins(); main_plate_corner_posts(); }
            for (i = [0 : hinge_n - 1]) if (!hinge_is_lid(i)) {
                sg = hinge_seg(i);
                hinge_knuckle(i);
                intersection() {   // chin under the knuckle, inside the case's outline
                    hull() {
                        hinge_cyl(hinge_r, sg[0] + hinge_gap/2, sg[1] - hinge_gap/2);
                        translate([sg[0] + hinge_gap/2, hinge_split_y - 0.5, zp - 0.01]) cube([sg[1] - sg[0] - hinge_gap, 0.5, 0.01]);
                    }
                    main_top_outer_solid();
                }
            }
        }
        hinge_clear(false);
        hinge_return_sweep_clear();
        main_dvio_cutouts();
        main_dvio_boss_holes();
        hinge_pin_hole();
    }
}
module main_top_part()    { if (main_hinged) main_lid(); else main_case_top(); }
module main_bottom_part() { if (main_hinged) union() { main_case_bottom(); main_back_plate(); main_front_band(); } else main_case_bottom(); }
echo(str("Seam lugs: top mid lug bottom ", main_seam_lugs_top[1][2], " vs drive top ", main_seam_drive_top,
         "; bottom mid lug ", main_seam_lugs_bottom[1][0], "..", main_seam_lugs_bottom[1][1],
         " (vents end ", board_d*0.35 + vent_slot_len/2, ", board B from ", main_kbpcb_origin[1], ")"));

// (Board A's layout along ky -- kbA_setback .. kb_d -- is defined up with the keyboard shell parameters, next to kb_x0.)
kbA_back_ledges = false;
kbA_back_lips = false;  // the two hanging lip columns over the board's back corners (removed: they
                        // looked odd and printed as floating pillars). The board is held by its two
                        // front screws; the back corners just rest on low ledges.
kb_bolt_depth = 12;    // M3 pilot depth into the keyboard's back rim (keyboard_attached)

// ============================================================================
// KEYBOARD SHELL -- adapted from the hand-built "split key frame.scad"
// ============================================================================
// REAL frame for this shell (NOT the tilted frame the original file was
// authored in -- there the top opening was level and the underside sloped;
// that was just easier for the keyboard math, the rotate() around it is
// gone here): base flat on the desk at z=0 (same plane as the main shell's
// floor bottom -- both stand on the same stick-on feet), kx across
// (0..kb_w), ky from the FRONT edge (0, nearest the typist) to the BACK
// face (kb_d, the tall face that mates with the main case's front wall).
// The keyboard plane (top surface + PCB pocket) slopes UP toward the back
// by kb_slope_deg: z_top(ky) = kb_front_h + ky*tan(slope); the keyboard PCB
// pocket floor is the parallel plane z = ky*tan(slope).
//
// kb_place() puts it in the MAIN case's frame for "preview": back face flush
// against main_front_y, X centered on the main case.
//
// Board A (the SAME Pico controller PCB as the main case's board B, just
// different firmware: coco-keyboard matrix -> USB) sits here rotated 180deg
// from board B so the two boards' USB ends face each other across the seam:
// a short USB jumper joins them (and B's front port stays free for any
// ordinary USB keyboard when this shell is detached).

function kb_z_floor(ky) = ky * tan(kb_slope_deg) + kb_raise;   // keyboard-PCB pocket floor
function kb_z_top(ky)   = kb_front_h + ky * tan(kb_slope_deg);

module kb_place() {
    // rigid placement: 180deg about Z (keyboard's +ky runs toward the main case's
    // -Y, its +kx toward main -X), then down by kb_dz if it has no feet
    translate([kb_x0 + kb_w, main_front_y + kb_d, -kb_dz]) rotate([0,0,180]) children();
}

// ---- Board A position (real frame) ----
// 180deg rotation of board B's placement about Z, USB/LED/button edge
// (board-local Y=kbpcb_d) pointing at the back face (+ky). The Pico lands at
// kb_w/2, i.e. dead center of the keyboard, which is also main-case X=board_w/2
// where board B's USB opening is -> the two USB ports line up.
// Board-local (lx,ly) -> keyboard frame. Upright: no mirror at all (the 180deg
// turn is already inside kb_place()); flipped upside down about the ky axis,
// which mirrors kx.
function kbA_pt(lx, ly) = [kb_w/2 + (kbA_flipped ? -1 : 1) * (lx - kbpcb_hdr_cx), kbA_edge_ky - kbpcb_d + ly];
kbA_x_lo = min(kbA_pt(0, 0)[0], kbA_pt(kbpcb_w, 0)[0]);   // board's low-kx edge
kbA_x_hi = max(kbA_pt(0, 0)[0], kbA_pt(kbpcb_w, 0)[0]);
kbA_y_lo = kbA_edge_ky - kbpcb_d;
// Headroom printed at render time so a bad kbA_setback / kb_extra_d / kbA_pcb_z /
// kb_slope_deg shows up immediately.
echo(str("Board A (", kbA_flipped ? "UPSIDE DOWN" : "upright", "): keyboard-PCB underside above its front edge = ",
         kb_z_floor(kbA_y_lo), "mm; PCB slab top = ", kbA_pcb_z + kbpcb_thickness, "mm"));
echo(str("  -> above the PCB: ", kb_z_floor(kbA_y_lo) - kbA_pcb_z - kbpcb_thickness,
         "mm;  below the PCB (down to the bay floor): ", kbA_pcb_z - kbA_floor_z, "mm"));
echo(str("Keyboard back-face top = ", kb_back_h - kb_dz, "mm above the MAIN floor plane, vs main front skirt (front_deck_h) = ",
         front_deck_h, "mm  (kb frame: ", kb_back_h, "mm above its own base)"));
echo(str("Main case: tower top = ", rear_tower_h, "mm above its floor (+", new_foot_height, " feet); flat shelf on the keyboard = ",
         one_piece_bottom ? 0 : 16 + kb_extra_d, "mm deep"));

// ---- PRINTING THE HALVES ON THEIR OUTER EDGES, WITHOUT SUPPORT ----
// Each half stands on its outer side face (left half on x=0, right half on x=kb_w), so the build direction runs
// sideways through the model: +X for the left half, -X for the right. Anything whose underside faces the build
// plate at more than 45 degrees from vertical would need support. These features keep every such surface at
// <= ~42 degrees ("come out from the base at 45 degrees"):
//   * kb_wedge_gussets(): a 45-degree fill along the flank of the ledge strip beside each hollow (the "wedge")
//   * teardrop board-A bosses and chamfered back-corner ledges, pointing at the half's own outer edge
//   * the base oval slots get a pointed (teardrop) end on the side that faces up in the print
// kb_oh_run is the fill's run per unit of rise (1.0 = exactly 45 deg; 1.2 = ~40 deg, a little margin);
// kb_tip_k is the same idea for teardrops (tip distance = k * radius; 1.5 -> 42 deg).
kb_print_on_side = true;
kb_oh_run = 1.2;
kb_tip_k  = 1.5;

// ---- Port of the original shell (all coordinates in the real frame) ----
// tip: +1 / -1 adds a pointed end on the +x / -x side of the slot (0 = plain round ends)
module kf_grill(g_x, g_y, width, slots, tip = 0) {
    grill_slot_width = 30;
    grill_slot_spacing = 20;
    grill_z = -60;
    spacing = grill_slot_width + grill_slot_spacing;
    for (y = [g_y : spacing : g_y + spacing * slots]) {
        hull() {
            translate([g_x, y+grill_slot_width/2, grill_z])
                rotate([-kb_slope_deg, 0, 0]) cylinder(h = 100, d = grill_slot_width);
            translate([g_x + width, y+grill_slot_width/2, grill_z])
                rotate([-kb_slope_deg, 0, 0]) cylinder(h = 100, d = grill_slot_width);
            if (kb_print_on_side && tip != 0)
                translate([tip > 0 ? g_x + width + kb_tip_k*grill_slot_width/2 : g_x - kb_tip_k*grill_slot_width/2,
                           y+grill_slot_width/2, grill_z])
                    rotate([-kb_slope_deg, 0, 0]) cylinder(h = 100, d = 0.2);
        }
    }
}

kf_left_right_support = 30;
kf_front_back_support = 20;
module kf_hollow_int(offset_hollow_x = 0) {
    translate([offset_hollow_x, 0, 0])
    translate([kf_left_right_support, kf_front_back_support, kb_base_t])
        hull() {
            translate([kb_corner_r - 10, kb_corner_r, 0])
                cylinder(h = kb_rear_h, r = kb_corner_r - kb_wall);
            translate([kb_w/2 - 2*kf_left_right_support - kb_corner_r + 10, kb_corner_r, 0])
                cylinder(h = kb_rear_h, r = kb_corner_r - kb_wall);
            translate([kb_corner_r - 10, kb_d_key - kf_front_back_support - kb_corner_r - 20, 0])
                cylinder(h = kb_rear_h, r = kb_corner_r - kb_wall);
            translate([kb_w/2 - 2*kf_left_right_support - kb_corner_r + 10, kb_d_key - kf_front_back_support - kb_corner_r - 20, 0])
                cylinder(h = kb_rear_h, r = kb_corner_r - kb_wall);
        }
}

module kf_shell() {
    slide_back = 4;
    pcb_left = (kb_w - kb_pcb_w) / 2;
    pcb_right = pcb_left + kb_pcb_w;
    difference() {
        intersection() {
            hull() {
                translate([kb_corner_r, kb_corner_r, 0])           cylinder(h = kb_front_h, r = kb_corner_r);
                translate([kb_w - kb_corner_r, kb_corner_r, 0])    cylinder(h = kb_front_h, r = kb_corner_r);
                if (one_piece_bottom)   // square back corners: the sides run straight on into the plinth along the main case
                    for (x = [0, kb_w - 2*kb_corner_r]) translate([x, kb_d - 2*kb_corner_r, 0]) cube([2*kb_corner_r, 2*kb_corner_r, kb_back_h]);
                else {
                    translate([kb_corner_r, kb_d - kb_corner_r, 0])    cylinder(h = kb_rear_h, r = kb_corner_r);
                    translate([kb_w - kb_corner_r, kb_d - kb_corner_r, 0]) cylinder(h = kb_rear_h, r = kb_corner_r);
                }
            }
            if (one_piece_bottom)   // no shelf: everything under the keyboard plane, carried on to the back face
                translate([0, 0, kb_front_h]) rotate([kb_slope_deg, 0, 0]) translate([-500, -500, -1000]) cube([1000, 1000, 1000]);
            else
                translate([-1, -1, -1]) cube([kb_w + 2, kb_d + 2, kb_cap_h + 1]); // flat shelf behind the keyboard
        }
        kf_hollow_int();
        kf_hollow_int(kb_w/2);

        // keyboard PCB recess -- parallel to the sloped top (this is the one
        // cut the original authored in the level frame via rotate(slope))
        translate([0, 0, kb_raise]) rotate([kb_slope_deg, 0, 0])
        translate([pcb_left - kb_pocket_left_ext, (kb_d_key - kb_pcb_d)/2 + slide_back - kb_pocket_front_ext, 0])
            linear_extrude(height = kb_rear_h)
                offset(r = kb_pocket_corner_r) offset(delta = -kb_pocket_corner_r)
                    square([kb_pcb_w + kb_pocket_left_ext, kb_pcb_d + kb_pocket_front_ext]);

        // underside metal lip on the stock keyboard
        translate([pcb_left, (kb_d_key - kb_pcb_d)/2 + slide_back + 4.5, 6 + kb_raise])
            rotate([kb_slope_deg, 0, 0]) {
                rotate([0,90,0]) cylinder(h = kb_pcb_w, d = 4);
                rotate([0,90,0]) translate([0,114.5,0]) cylinder(h = kb_pcb_w, d = 4);
            }

        // room for the stock keyboard's ribbon cable(s) coming off its rear edge
        {
            ribbon_w = 66; ribbon_vert = 18;
            ribbon_x = (kb_w - ribbon_w) / 2;
            ribbon_z = kb_cap_h - 24;
            // clipped at the tunnel roof's underside (kbA_roof_z) so it can't carve a bite out of the roof over the controller
            ry0 = kb_d_key-71-3;
            // never cut into the floor (at shallow slopes ribbon_z-1.6-12 goes negative -- it would
            // have punched a hole through the base) ...
            r1z0 = max(ribbon_z-1.6, kb_base_t);         r1z1 = ribbon_z-1.6+ribbon_vert;
            r2z0 = max(ribbon_z-1.6-12, kb_base_t);      r2z1 = ribbon_z-1.6-12+ribbon_vert;
            // ... and, behind the pocket, never into the tunnel roof (kbA_roof_z)
            if (r1z1 > r1z0) {
                translate([ribbon_x, ry0, r1z0])
                    cube([ribbon_w, kb_pocket_y1 - 1 - ry0, r1z1 - r1z0]);                 // in front of the roof: full height
                intersection() {
                    translate([ribbon_x, kb_pocket_y1 - 1, r1z0])
                        cube([ribbon_w, (ry0 + 70.8) - (kb_pocket_y1 - 1), max(0.01, min(r1z1, kbA_roof_z) - r1z0)]);
                    if (one_piece_bottom) kbA_tunnel_ceiling();   // ... nor into its sloped roof in the one-piece build
                }
            }
            if (r2z1 > r2z0)
                translate([ribbon_x, kb_d_key-70.8-1, r2z0])  cube([ribbon_w, 70.8-8, r2z1 - r2z0]);
        }

        // clearance cuts on the stock keyboard's underside hardware (original
        // "promicro"/washer relief -- kept verbatim from the hand-built file)
        {
            promicro_x = 16;
            promicro_y = (kb_d_key - 45)/2 - 3;
            promicro_z = 6 + kb_raise;
            promicro_w = 24; promicro_d = 50; promicro_height = 20;
            translate([promicro_x-7, promicro_y+slide_back+1, promicro_z-1])
                rotate([kb_slope_deg, 0, 0]) translate([0, 0, -kb_left_relief_extra])
                    cube([promicro_w, promicro_d-5, promicro_height-2 + kb_left_relief_extra]);
            translate([pcb_right-6.5, promicro_y-7+slide_back, promicro_z+2])
                rotate([kb_slope_deg, 0, 0]) cylinder(d=12, h=20);
            translate([pcb_right-6.5, promicro_y+promicro_d+slide_back, promicro_z+promicro_height-3])
                rotate([kb_slope_deg, 0, 0]) cylinder(d=12, h=20);
            translate([promicro_x-0.5, promicro_y-7+slide_back, promicro_z+2])
                rotate([kb_slope_deg, 0, 0]) cylinder(d=11, h=20);
            translate([promicro_x-0.5, promicro_y+promicro_d+slide_back+1, promicro_z+promicro_height-3])
                rotate([kb_slope_deg, 0, 0]) cylinder(d=12, h=20);
        }

        // the left ovals' pointed tip used to run into the controller-bay floor refill (which now starts at kbA_x_lo - bay_clr - 1 ~ x 104)
        // and got cut off: shortened so the whole teardrop, tip included, ends 2mm short of the refill
        if (kb_floor_ovals) {
            kf_grill(35 + 10, kf_front_back_support, min(70, kbA_x_lo - kbA_bay_clr - 1 - 2 - kb_tip_k*15 - (35 + 10)), 1, tip = +1);   // left half prints toward +x
            kf_grill(kb_w/2 + 35 + 20, kf_front_back_support, 70, 1, tip = -1); // right half prints toward -x
        }
    }
}

// ---- Board A bay + openings (replaces the original hand-cut controller slot) ----
// ONE-PIECE shell, no separate cover. The bay is two cuts:
//  (a) open UP into the keyboard-PCB pocket (the controller is dropped in
//      through the same opening the keyboard module goes in), and
//  (b) a TUNNEL under the solid rear shelf (ky > the pocket's rear edge) that
//      also carries the USB corridor out to the back wall. The board's back
//      end slides under the shelf; the keyboard module then covers the open
//      part. Only the two FRONT mounting holes get screws (reachable from the
//      pocket); the two BACK holes are replaced by a support ledge under each
//      back corner + a lip over it (kbA_lip_*), which holds the 1.6mm board
//      down without a screw.
kbA_bay_clr = 2;
kbA_pilot_h = 5;   // must stay < the boss height (kbA_pcb_z) or the pilot breaks through the bottom
kb_pocket_y1 = (kb_d_key - kb_pcb_d)/2 + 4 + kb_pcb_d;  // rear edge of the keyboard-PCB pocket
kbA_roof_z   = min(34, kb_cap_h - 8);   // underside of the roof over the tunnel (kb frame). Shelf top is kb_cap_h, so
                     // the roof is kb_cap_h - kbA_roof_z thick.
kbA_lip_gap   = 2.6; // support top -> lip underside: 1.51 PCB + 1.1 play, enough to tilt the
                     // board's back edge in under the lips, then lower the front onto its bosses
kbA_lip_depth = 3.5; // how far each lip overhangs the board's back edge
kbA_lip_w     = 10;  // lip / support width (X)
function kbA_is_front(s) = s[1] < kbpcb_d/2;   // s[1] = board-local Y; the back edge is the USB edge
echo(str("Board A tunnel: ", kbA_roof_z - kbA_pcb_z - kbpcb_thickness, "mm above the PCB slab under the shelf; roof ",
         kb_cap_h - kbA_roof_z, "mm thick"));

module kb_boardA_bay() {
    // (a) through the ledge, open to the pocket -- BUT ONLY BELOW THE KEYBOARD PLANE. It used to be
    // a plain box going 80mm straight up, which also sliced the pocket's (forward-leaning) rear
    // wall away above the board: the rectangular "bite" out of the roof edge over the controller.
    // Above the plane there is nothing to remove there except that wall, so we stop at the plane
    // (+0.3 into the open pocket, so the cut never leaves a coplanar skin).
    intersection() {
        translate([kbA_x_lo - kbA_bay_clr, kbA_y_lo - kbA_bay_clr, kbA_floor_z])
            cube([kbpcb_w + 2*kbA_bay_clr, (kb_pocket_y1 + 0.5) - (kbA_y_lo - kbA_bay_clr), 80]);
        translate([0, 0, 0.3 + kb_raise]) rotate([kb_slope_deg, 0, 0]) translate([-500, -500, -1000]) cube([1000, 1000, 1000]);
    }
    // (b) tunnel under the shelf, out to the back wall's inner face. One-piece (printed flat): its roof is a 45-degree
    // wedge instead of a flat 10mm cantilever -- full height at the pocket, stepping down toward the PCB-edge wall -- so
    // it prints without support. At the wall it still clears the faceplate window top (fp_z1) and the USB jack by ~9mm.
    tw = kbpcb_w + 2*kbA_bay_clr;
    if (one_piece_bottom)
        intersection() {
            translate([kbA_x_lo - kbA_bay_clr, kb_pocket_y1 - 1, kbA_floor_z])
                cube([tw, kbA_wall_y0 - (kb_pocket_y1 - 1), kbA_roof_z - kbA_floor_z]);
            kbA_tunnel_ceiling();
        }
    else
        translate([kbA_x_lo - kbA_bay_clr, kb_pocket_y1 - 1, kbA_floor_z])
            cube([tw, kbA_wall_y0 - (kb_pocket_y1 - 1), kbA_roof_z - kbA_floor_z]);
}
// One-piece: the space under the tunnel's sloped roof -- kbA_roof_z at the pocket's rear edge, dropping one_piece_oh_k mm
// per mm toward the PCB-edge wall (~48 degrees from horizontal: steeper than 45, so it prints without support).
one_piece_oh_k = 1.1;
module kbA_tunnel_ceiling() {
    translate([0, kb_pocket_y1, kbA_roof_z]) rotate([-atan(one_piece_oh_k), 0, 0]) translate([-500, -500, -1000]) cube([1000, 1000, 1000]);
}
// CABLE BAY: everything between the PCB-edge wall and the back face, kb_bay_x0..kb_bay_x1 wide, floor to the
// roof underside. Open at the back face -- the main case's front wall closes it when the keyboard is docked.
// The keyboard's roof/shelf carries on over it (the overhang that hides the cable). The bay is also where
// the coiled slack of the jumper lives.
module kb_cable_bay() {
    if (one_piece_bottom)   // printed flat, the roof over the bay is a cantilever off the PCB-edge wall: 45-degree underside,
        hull() {            // lowest at that wall, full height at the open back face
            translate([kb_bay_x0, kbA_wall_y1 - 0.01, kbA_floor_z])
                cube([kb_bay_x1 - kb_bay_x0, 0.01, kbA_roof_z - one_piece_oh_k*kb_cable_bay_d - kbA_floor_z]);
            translate([kb_bay_x0, kb_d, kbA_floor_z]) cube([kb_bay_x1 - kb_bay_x0, 1, kbA_roof_z - kbA_floor_z]);
        }
    else
        translate([kb_bay_x0, kbA_wall_y1, kbA_floor_z])
            cube([kb_bay_x1 - kb_bay_x0, kb_d - kbA_wall_y1 + 1, kbA_roof_z - kbA_floor_z]);
}
// ---- DE-9 (DB9) joystick port on the RIGHT side of the keyboard case ----
// Wired to board A's J6 (2x5 header) with a 10-conductor ribbon (IDC). Standard DE-9 dimensions -- CHECK THEM
// AGAINST YOUR ACTUAL CONNECTOR. Mounted from INSIDE: the flange sits against the inner face of a 3mm panel that
// is recessed de9_recess_d into the right wall (so a joystick plug can seat), the D shell passes through the D
// cutout, and the connector's own two jack-post/screws use the two 3.3mm holes at 24.99mm pitch.
// It sits level with J6 (same ky) in the solid shelf zone behind the hollow -- the hollow under the keys is only
// ~14mm tall there at this slope, too shallow for a 12.5mm connector plus its body -- and a straight ribbon
// channel runs from the controller tunnel out to the connector's body pocket.
de9_enabled = !one_piece_bottom;   // one-piece: no DE-9 (its pocket and ribbon channel were most of the keyboard's support-needing overhangs)
de9_y = kb_pocket_y1 - 3.5;          // just behind the keys, in the solid rim (was level with J6 -- but J6 moved 40mm forward when the
                                     // board did, and the connector's body pocket would have poked above the keyboard plane there)
de9_z = 10.75;                       // connector centre height (flange 12.55 tall: z 4.5 .. 17.0); low, so its body pocket (top z 18.25)
                                     // stays under the keyboard plane, which is only ~20mm high this far forward
de9_pitch = 24.99; de9_hole_d = 3.3; // standard mounting-hole pitch (0.984"), clearance for the 4-40/M3 posts
de9_d_w = 17.4; de9_d_h = 8.9; de9_d_angle = 10;   // D cutout incl. clearance (shell 16.9 x 8.4), wide side UP
de9_recess_d = 6; de9_recess_w = 36; de9_recess_h = 15.5;  // outer recess around the flange footprint (30.8 x 12.5)
de9_panel_t = 3;                     // the mounting panel
de9_body_d = 18; de9_body_w = 34; de9_body_h = 15;       // pocket behind the panel for the connector body + IDC
de9_ch_w = 16; de9_ch_h = 10;        // ribbon channel (10 conductors = 12.7 wide flat)
module de9_d2d(w, h, ang = 10, r = 0.8) {
    offset(r = r) offset(delta = -r)
        polygon([[-w/2, h/2], [w/2, h/2], [w/2 - h*tan(ang), -h/2], [-w/2 + h*tan(ang), -h/2]]);
}
module kb_de9() {
    x_panel1 = kb_w - de9_recess_d;            // recess floor = panel's outer face
    x_panel0 = x_panel1 - de9_panel_t;         // panel's inner face
    x_body0  = x_panel0 - de9_body_d;
    // outer recess so the mating plug can seat
    translate([x_panel1, de9_y - de9_recess_w/2, de9_z - de9_recess_h/2])
        cube([de9_recess_d + 1, de9_recess_w, de9_recess_h]);
    // D cutout through the panel
    translate([x_panel0 - 0.5, de9_y, de9_z]) rotate([90, 0, 90])
        linear_extrude(height = de9_panel_t + 1) de9_d2d(de9_d_w, de9_d_h, de9_d_angle);
    // the two mounting holes
    for (s = [-1, 1])
        translate([x_panel0 - 0.5, de9_y + s*de9_pitch/2, de9_z]) rotate([0, 90, 0])
            cylinder(d = de9_hole_d, h = de9_panel_t + 1);
    // pocket for the connector body
    translate([x_body0, de9_y - de9_body_w/2, de9_z - de9_body_h/2])
        cube([de9_body_d + 0.01, de9_body_w, de9_body_h]);
    // ribbon channel back to the controller tunnel
    x_tun = kbA_x_hi + kbA_bay_clr - 1;
    translate([x_tun, de9_y - de9_ch_w/2, de9_z - de9_ch_h/2])
        cube([x_body0 - x_tun + 0.01, de9_ch_w, de9_ch_h]);
}

module kb_boardA_access() {
    // Openings in the back wall, positioned from the REAL stuffed board (Coco_pico_keyb.stl): USB jack,
    // both LEDs, and the button cap. "face_z" is the PCB face the components stand on: the top when
    // upright, the bottom when flipped.
    sgn = kbA_flipped ? -1 : 1;
    face_z = kbA_flipped ? kbA_pcb_z : kbA_pcb_z + kbpcb_thickness;
    usb_z = face_z + sgn*kbpcb_usb_z;
    translate([kbA_pt(kbpcb_usb_x - 79.0, 0)[0], kbA_wall_y0 + kb_wall/2, usb_z])
        rect_cutout(kb_usb_w, kb_usb_h, kb_wall + 2);
    for (p = [kbpcb_led1_pos, kbpcb_led2_pos]) {
        q = kbA_pt(p[0], p[1]);
        translate([q[0], q[1] - 2, face_z + sgn*kbpcb_led_z])
            rotate([-90, 0, 0]) cylinder(d = kbpcb_led_access_d, h = kbA_wall_y1 + 1 - (q[1] - 2));
    }
    q = kbA_pt(kbpcb_button_pos[0], kbpcb_button_pos[1]);
    translate([q[0], q[1] - 2, face_z + sgn*kbpcb_btn_z])
        rotate([-90, 0, 0]) cylinder(d = kbpcb_button_access_d, h = kbA_wall_y1 + 1 - (q[1] - 2));
    // where board B's own opening lands in THIS frame -- the two only need to overlap
    b_z = kbpcb_screw_boss_h + kbpcb_thickness + kbpcb_usb_z + kb_dz;
    echo(str("USB openings (kb-frame z): board A ", usb_z - kb_usb_h/2, "..", usb_z + kb_usb_h/2,
             "  vs board B ", b_z - kb_usb_h/2, "..", b_z + kb_usb_h/2));
    echo(str("USB jack mouth -> board B's jack mouth across the cable bay: ~",
             kbA_setback - kbpcb_edge_poke + kb_wall + kb_cable_bay_d + wall + 3 - kbpcb_edge_poke, "mm"));
}
module kb_boardA_floor() {
    // refill the floor under the bay, after the grill ovals cut through it
    translate([kbA_x_lo - kbA_bay_clr - 1, kbA_y_lo - kbA_bay_clr - 1, 0])
        cube([kbpcb_w + 2*kbA_bay_clr + 2, kbA_wall_y0 - (kbA_y_lo - kbA_bay_clr) + 1, kbA_floor_z + 0.01]);
}
// the two hollows' inner flanks (the strip between them is the "wedge": solid from the floor up to the keyboard plane)
kf_hollow1_x1 = kf_left_right_support + (kb_w/2 - 2*kf_left_right_support - kb_corner_r + 10) + (kb_corner_r - kb_wall);   // 144
kf_hollow2_x0 = kb_w/2 + kf_left_right_support + (kb_corner_r - 10) - (kb_corner_r - kb_wall);                            // 190
module kb_wedge_gussets() {
    // A triangle in the hollow along each flank, from the floor up to where the flank meets the keyboard plane, with its
    // slanted face at ~40 deg: tall where the strip is tall, tapering to nothing at the front. Runs from where the hollow's
    // corner rounding ends to where the ribbon relief opens the strip up (y = kb_d_key - 70.8 - 1).
    ya = kf_front_back_support + kb_corner_r;
    yb = min(kb_d_key - 70.8 - 1, kbA_y_lo - kbA_bay_clr - 0.5);   // ...or where the controller bay opens the strip, whichever comes first
                                                                   // (with the board moved forward the bay starts ahead of the ribbon relief)
    for (side = [-1, 1]) {          // -1: left hollow's flank (fill toward -x), +1: right hollow's flank (toward +x)
        xf = side < 0 ? kf_hollow1_x1 : kf_hollow2_x0;
        hull() for (y = [ya, yb]) {
            h = max(0.01, kb_z_floor(y) - kb_base_t);
            translate([0, y, 0]) rotate([90, 0, 0]) linear_extrude(height = 0.01)
                polygon([[xf - side*0.3, kb_base_t - 0.2],
                         [xf - side*0.3, kb_base_t + h],
                         [xf + side*kb_oh_run*h, kb_base_t - 0.2]]);
        }
    }
}

module kb_boardA_bosses() {
    // a screw boss at every mounting hole. The two front ones and the back one at y~136 are reached from the pocket
    // (keyboard module out); the last one (4.5mm from the board's back edge, under the shelf) is reached through the
    // cable bay with the faceplate/span plate out -- see kb_plate_slot().
    for (s = kbpcb_standoffs) {
        p = kbA_pt(s[0], s[1]);
        sgn = p[0] < kb_w/2 ? -1 : 1;    // toward this half's own outer edge = the side that faces the build plate
        translate([p[0], p[1], 0]) hull() {
            cylinder(d = kbpcb_screw_boss_d, h = kbA_pcb_z);
            if (kb_print_on_side)   // teardrop: a 42-degree keel toward the outer edge, so the boss prints without support
                translate([sgn*kb_tip_k*kbpcb_screw_boss_d/2, 0, 0]) cylinder(d = 0.2, h = kbA_pcb_z);
        }
    }
}
module kb_boardA_pilots() {
    for (s = kbpcb_standoffs) {
        p = kbA_pt(s[0], s[1]);
        translate([p[0], p[1], kbA_pcb_z - kbA_pilot_h]) cylinder(d = kbpcb_screw_pilot_d, h = kbA_pilot_h + 1);
    }
}

// ---- Keyboard bezel screws ----
// Four M3 screws come up from UNDER the shell, through the pocket floor, into a bezel that sits over the keyboard.
// Same spots as the old "promicro"/washer relief cylinders in kf_shell() (6.5 in from the pocket's sides, ~30 and
// ~88 back from its front edge). Positions are measured IN the keyboard plane: kb_bezel_screw_v back from the
// pocket's front edge (along the slope), kb_bezel_screw_pitch apart across X, centred. Holes run square to
// the keyboard plane so they line up with the keyboard PCB and the bezel.
// Two keyboards share these holes: the OEM keyboard (3.0mm thick at the holes, 4.8mm hole in its frame) and the
// Artemis v3 PCB (1.6mm, 5.0mm holes). The Artemis KiCad bezel layers put its holes at 304.8 x 60.0 (12.000") --
// pocket-edge-minus-5.25 gave 305.5, which would bind an M3 in a 3.4 hole, so the pitch is set from the Artemis data.
// v: the keyboard outline's front edge sits kb_kbd_front_clr behind the pocket's front edge, and its holes are 30.54 / 90.56
// behind that (measured on the Artemis STL, which has the OEM outline) -- a flat 30/90 from the pocket put the keyboard
// 0.55 into the front wall
kb_kbd_front_clr     = 0.3;
kb_bezel_screw_v     = [30.54, 90.56] + [1, 1] * kb_kbd_front_clr;
kb_bezel_screw_pitch = 304.8;
kb_bezel_screw_d     = 3.4;   // M3 clearance
kb_bezel_head_d      = 6.4;   // counterbore for an M3 socket/button head (5.5 / 5.7)
kb_bezel_seat_t      = 3;     // material left between the head's seat and the pocket floor
kb_pocket_y0 = kb_pocket_y1 - kb_pcb_d;   // the pocket's ORIGINAL front edge (plane coords) -- the datum the screws and
                                          // keyboard are placed from; the pocket itself now starts kb_pocket_front_ext ahead
// plane coords (u along X, v back along the slope) -> shell coords; the pocket floor is the plane at kb_raise
function kb_plane_pt(u, v, w = 0) = [u, v*cos(kb_slope_deg) - w*sin(kb_slope_deg), kb_raise + v*sin(kb_slope_deg) + w*cos(kb_slope_deg)];
kb_bezel_screws = [ for (v = kb_bezel_screw_v, u = [kb_w/2 - kb_bezel_screw_pitch/2,
                                                    kb_w/2 + kb_bezel_screw_pitch/2]) [u, kb_pocket_y0 + v] ];
module kb_bezel_screw_holes() {
    for (s = kb_bezel_screws) {
        sgn = s[0] < kb_w/2 ? 1 : -1;   // toward the middle = UP when the half prints on its outer side face
        translate([0, 0, kb_raise]) rotate([kb_slope_deg, 0, 0]) translate([s[0], s[1], 0]) {
            // clearance hole: from below the shell's base up through the pocket floor
            translate([0, 0, -60]) kb_teardrop_cyl(kb_bezel_screw_d, 61, sgn);
            // head counterbore from the base, stopping kb_bezel_seat_t under the floor
            translate([0, 0, -60]) kb_teardrop_cyl(kb_bezel_head_d, 60 - kb_bezel_seat_t, sgn);
        }
    }
}
// cylinder along Z with a 45-deg point toward sgn*X, so it bridges nothing when that side is up in the printer
module kb_teardrop_cyl(d, h, sgn) {
    if (kb_print_on_side)
        hull() {
            cylinder(d = d, h = h);
            translate([sgn*d/2*sqrt(2), 0, 0]) cylinder(d = 0.01, h = h);
        }
    else cylinder(d = d, h = h);
}
module kb_boardA_back_lips() {
    // At each back corner of the board (at the X of the two back mounting
    // holes): a solid ledge UNDER the board's back edge (floor -> PCB bottom)
    // and a lip OVER it (kbA_lip_gap above the ledge, up into the roof).
    for (s = kbpcb_standoffs) if (!kbA_is_front(s)) {
        cx = kbA_pt(s[0], s[1])[0];
        y0 = kbA_edge_ky - kbA_lip_depth;
        sgn = cx < kb_w/2 ? -1 : 1;
        hull() {                                                                           // support ledge (kept)
            translate([cx - kbA_lip_w/2, y0 - 2.5, 0])
                cube([kbA_lip_w, kbA_lip_depth + 2.5 + 0.4, kbA_pcb_z]);
            if (kb_print_on_side)   // chamfer down to the floor on the outer-edge side
                translate([cx + sgn*(kbA_lip_w/2 + kb_oh_run*(kbA_pcb_z - kb_base_t)), y0 - 2.5, kb_base_t - 0.2])
                    cube([0.01, kbA_lip_depth + 2.5 + 0.4, 0.2]);
        }
        if (kbA_back_lips)
            translate([cx - kbA_lip_w/2, y0, kbA_pcb_z + kbA_lip_gap])
                cube([kbA_lip_w, kbA_lip_depth + 0.4, kbA_roof_z + 0.5 - (kbA_pcb_z + kbA_lip_gap)]); // lip, fused to the roof
    }
}

// ---- Joint to the main case ----
// Fixed X/Z positions come from the MAIN case (main_magnet_x, parting_h/2).
// The keyboard is the main case turned 180deg about Z, so main X -> kx is
// kb_x0 + kb_w - X.
function kb_mag_kx(x) = kb_x0 + kb_w - x;
function kb_in_bay(kx) = kx > kb_bay_x0 - 6 && kx < kb_bay_x1 + 6;   // a magnet pocket must stay in solid rim
function kb_bolt_xs() = main_magnet_x;   // all four: the bay-side one has a solid block behind it now

kb_mag_z = parting_h/2 + kb_dz;
kb_mag_slot_w = magnet_d + 0.2;
kb_mag_slot_t = magnet_pocket_depth;               // magnet_h + tol
kb_mag_y0 = kb_d - magnet_face_t - kb_mag_slot_t;  // pocket's rear (inner) face
kb_plug_h = kb_mag_z - magnet_d/2 - 0.3;           // plug fills the channel up to just under the magnet

// A magnet must never land in the cable bay's X range (no rim behind the face there to hold a pocket).
for (x = main_magnet_x) if (kb_in_bay(kb_mag_kx(x)))
    echo(str("WARNING: magnet at main X=", x, " (kb kx=", kb_mag_kx(x), ") falls in the cable bay's X range -- move it"));

module kb_magnet_pockets() {
    // Each magnet is loaded from UNDERNEATH: a slot the magnet's own profile
    // (kb_mag_slot_w wide, one magnet thick) runs up from the base into a
    // round blind pocket, which stops magnet_face_t short of the back face --
    // so nothing shows on the back and the magnet sits flush behind a thin skin
    // against the main shell's own magnet. Then a glued-in plug
    // (kb_magnet_plug(), part "keyboard_magnet_plugs") closes the slot flush
    // with the bottom and holds the magnet up. Mind polarity: the face that
    // ends up toward the main case must attract the main-side magnet.
    for (x = main_magnet_x) {
        kx = kb_mag_kx(x);
        translate([kx, kb_mag_y0, kb_mag_z]) rotate([-90,0,0]) cylinder(d = kb_mag_slot_w, h = kb_mag_slot_t);
        translate([kx - kb_mag_slot_w/2, kb_mag_y0, -1]) cube([kb_mag_slot_w, kb_mag_slot_t, kb_mag_z + 1]);
    }
}
module kb_magnet_plug() {
    // lying flat for printing: width x length x thickness
    cube([kb_mag_slot_w - 0.3, kb_plug_h, kb_mag_slot_t - 0.3]);
}
module kb_magnet_plugs() {
    for (i = [0 : len(main_magnet_x) - 1])
        translate([i*(kb_mag_slot_w + 3), 0, 0]) kb_magnet_plug();
}
module kb_bolt_pilots() {
    // keyboard_attached: M3 screws are driven from INSIDE the main case (top
    // shell off), through main_kb_bolt_holes() in its front wall, and thread
    // into pilots bored from this shell's back face. No nuts needed -- same
    // self-tap / heat-set choice (m3_pilot_d) as every other boss.
    for (x = kb_bolt_xs())
        translate([kb_mag_kx(x), kb_d - kb_bolt_depth, kb_mag_z])
            rotate([-90,0,0]) cylinder(d = m3_pilot_d, h = kb_bolt_depth + 1);
}
module kb_socket_pockets() {
    lug_w = 10; lug_d = 6; lug_h = 6;
    spacing = board_w / 6;
    for (i = [1, 2, 4, 5])
        translate([kb_mag_kx(i*spacing) - lug_w/2 - tol, kb_d - lug_d, -tol + kb_dz])
            cube([lug_w+2*tol, lug_d+tol, lug_h+2*tol]);
}

// ============================================================================
// FACEPLATE -- the wall at the controller board's edge is a separate printed part (shared with the main case)
// ============================================================================
// It sits in the shared window (fp_len x fp_z0..fp_z1) cut through the wall between the controller tunnel and the cable bay,
// spans the seam (so it also ties the two halves together), and snaps in from the bay side -- no screws. ABOVE the window the wall
// stays, so the tunnel keeps its roof. The window ends are solid behind the plate, which is its stop. With the plate out, the cable
// bay opens straight onto the board's back edge: that is how the board's rear-most mounting screw is reached (an angled driver
// through the window).
//   keyboard_faceplate   -- USB / LED / button openings (the same part goes in the main case's front wall for board B)
kb_plate_x0   = kb_bay_x0 + fp_clr;
kb_plate_x1   = kb_bay_x1 - fp_clr;
kb_plate_y0   = kbA_wall_y0 + (kb_wall - fp_t - fp_out_gap);   // outer face sits fp_out_gap inside the wall's back face
kb_plate_z0   = fp_z0 + fp_clr;
kb_plate_z1   = fp_z1 - fp_clr;
module kb_plate_slot() {
    translate([kb_bay_x0, kbA_wall_y0, kbA_floor_z])
        cube([kb_bay_x1 - kb_bay_x0, kb_wall, fp_z1 - kbA_floor_z]);
}
// The plate, in the keyboard frame (kx, ky, z)
module kb_plate_solid() {
    difference() {
        translate([kb_plate_x0, kb_plate_y0, kb_plate_z0])
            cube([kb_plate_x1 - kb_plate_x0, fp_t, kb_plate_z1 - kb_plate_z0]);
        fp_finger_slots(kb_plate_x0, kb_plate_x1, kb_plate_y0, kb_plate_z0);
    }
    fp_barbs(kb_plate_x0, kb_plate_x1, kb_plate_y0, kb_plate_z0);
}
module kb_plate_grooves() {
    fp_grooves(kb_plate_x0, kb_plate_x1, kb_plate_y0, kb_plate_z0);
}
// printed flat, its inner face (the side toward the board) on the bed
module kb_plate_flat() {
    translate([-kb_plate_x0, kb_plate_z1, -kb_plate_y0]) rotate([90, 0, 0]) children();
}
module kb_faceplate() {
    kb_plate_flat() difference() {
        kb_plate_solid();
        kb_boardA_access();
    }
}

// ============================================================================
// BRIDGE PLATE -- for the permanently-attached build (faceplates out, controller boards not fitted)
// ============================================================================
// One stepped plate joins the keyboard and the main bottom through the two aligned windows. It screws onto the controller
// boards' own mounting bosses -- board A's two rear ones in the keyboard and board B's two front-edge ones in the main
// bottom -- so neither shell needs anything extra. The bosses are kb_dz (5mm) apart in height (the keyboard sits on the
// desk, the main case on its feet), so the plate steps down at 45 degrees inside the cable bay. Both ends stay inside the free
// zones: the keyboard end within the tunnel's width, the main end within the gap in the support beam where board B goes.
// (Print with supports under the raised end, or tree supports.)
bp_t = 2.7;
bp_hole_d = 3.4;
function kb2main(p) = [kb_x0 + kb_w - p[0], main_front_y + kb_d - p[1]];
function bp_a_holes() = [ for (s = kbpcb_standoffs) if (!kbA_is_front(s)) kb2main(kbA_pt(s[0], s[1])) ];
function bp_b_holes() = [ for (s = kbpcb_standoffs) if (!kbA_is_front(s)) [main_kbpcb_origin[0] + s[0], main_kbpcb_origin[1] + s[1]] ];
module kb_bridge_plate(placed = false) {
    F = main_front_y;
    zb = kbpcb_screw_boss_h;             // main end: on board B's bosses
    za = kbA_pcb_z - kb_dz;              // keyboard end: on board A's bosses (kb z -> main z)
    dz = zb - za;
    bx0 = main_kbpcb_origin[0];  bx1 = main_kbpcb_origin[0] + kbpcb_w - 0.2;
    ax0 = kb_x0 + kb_w - (kbA_x_hi + kbA_bay_clr - 0.3);
    ax1 = kb_x0 + kb_w - (kbA_x_lo - kbA_bay_clr + 0.3);
    yb0 = min([for (h = bp_b_holes()) h[1]]) - 6;
    ya1 = max([for (h = bp_a_holes()) h[1]]) + 6;
    y_r0 = F + 1;                        // riser start (in the cable bay, between the two walls)
    translate(placed ? [0, 0, 0] : [-(bp_latch ? min(ax0, board_w/2 - fp_len/2) : ax0), -yb0, -za])
    difference() {
        union() {
            translate([bx0, yb0, zb]) cube([bx1 - bx0, y_r0 + 0.01 - yb0, bp_t]);                     // main end
            hull() {                                                                                   // 45-degree step
                translate([max(ax0, bx0), y_r0, zb]) cube([min(ax1, bx1) - max(ax0, bx0), 0.01, bp_t]);
                translate([max(ax0, bx0), y_r0 + dz, za]) cube([min(ax1, bx1) - max(ax0, bx0), 0.01, bp_t]);
            }
            translate([ax0, y_r0 + dz - 0.01, za]) cube([ax1 - ax0, ya1 - (y_r0 + dz) + 0.01, bp_t]); // keyboard end
            if (bp_latch) kb_place() bp_latch_kb();
        }
        for (h = bp_b_holes())   // slotted front-to-back (bp_slot each way) so the snap and the wall bolts can't fight the plate
            hull() for (s = [-1, 1]) translate([h[0], h[1] + s*bp_slot, zb - 1]) cylinder(d = bp_hole_d, h = bp_t + 2);
        for (h = bp_a_holes()) translate([h[0], h[1], za - 1]) cylinder(d = bp_hole_d, h = bp_t + 2);
    }
}

// ---- Spring latch into the keyboard (bp_latch) ----
// Clicks into the snap grooves the keyboard_faceplate uses (fp_grooves in the keyboard window's end walls), so the keyboard
// shell is unchanged. A crossbar across the cable bay, on the plate's keyboard-end plane, carries a flat finger at each
// window end that runs forward through the bay into the wall's window, with the faceplate's barb on its tip. The fingers lie
// in the plate's plane and flex sideways (along the layers, as the faceplate's do). The barbs only need to overlap the
// grooves: they fill the groove's top bp_barb_zl (the groove spans z fp_z0+0.25 .. +4.55, the plate starts at kbA_pcb_z).
// The finger tips stop 0.2 short of the solid behind the window ends. Assembly: plate loosely screwed into the main bottom,
// push the keyboard home (click), drive the 3 wall bolts, then tighten the plate. Release: bolts out, pull firmly (the
// barb's back flank is ~50 deg), or pry the fingers inward from the cable bay.
bp_latch = true;
bp_slot = 1;            // main-end screw holes slotted this far each way (Y)
bp_fin_w = fp_finger_w; // finger width (X) -- same section as the faceplate's
bp_fin_h = 6;           // finger height (Z), from the plate's underside
bp_fin_gap = fp_slot_w; // gap between finger and crossbar
bp_barb_zl = 1.2;       // barb height (Z)
bp_cross_d = 7;         // crossbar depth (along the bay) -- reaches the keyboard-end plate past the riser
module bp_latch_kb() {  // keyboard frame
    z = kbA_pcb_z;
    y_tip = kb_plate_y0;          // the faceplate's inner face = where its barbs sit
    y_root = kb_d - 0.3;          // just inside the keyboard's back face
    x0 = kb_plate_x0;  x1 = kb_plate_x1;
    // crossbar, stopping short of the fingers
    translate([x0 + bp_fin_w + bp_fin_gap, y_root - bp_cross_d, z])
        cube([x1 - x0 - 2*(bp_fin_w + bp_fin_gap), bp_cross_d, bp_t]);
    for (e = [0, 1]) {
        xf = e == 0 ? x0 : x1 - bp_fin_w;
        translate([xf, y_tip, z]) cube([bp_fin_w, y_root - y_tip, bp_fin_h]);                  // finger
        translate([e == 0 ? x0 : x1 - bp_fin_w - bp_fin_gap - 1, y_root - 1.2, z])            // root tab joining it to the crossbar
            cube([bp_fin_w + bp_fin_gap + 1, 1.2, bp_t]);
    }
    // barb at the TOP of the groove (the barb zone the faceplate uses, kb_plate_z0-relative), ending at its nominal top
    bz1 = kb_plate_z0 + fp_barb_z0 + fp_barb_zl;
    assert(bz1 - bp_barb_zl >= z, "latch barb would hang below the bridge plate's underside");
    translate([0, 0, bz1 - bp_barb_zl]) linear_extrude(height = bp_barb_zl) {
        translate([x0, y_tip]) mirror([1, 0]) fp_barb_2d();
        translate([x1, y_tip]) fp_barb_2d();
    }
}

// ============================================================================
// KEYBOARD <-> MAIN JOINER KEYS -- stepped bow-tie keys across the front/back seam, on the underside
// ============================================================================
// Like the seam keys between the keyboard halves, but the keyboard sits kb_dz (5mm) lower than the main case (which stands on stick-on
// feet), so the key is JOGGED: a bow-tie tab in the keyboard's underside at its own level, a bow-tie tab in the main bottom's underside
// 5mm higher, and a short riser between them at the seam. The riser is the only part of the key you can see, in the gap under the main
// case's front edge (where a foot would go). Both pockets open at the seam with their narrow "neck" at the mouth, so each tab is
// dovetailed in. Pockets are always cut, keys are optional; glue them in from below.
//   * keyboard tab: 45-degree flanks, short -- the keyboard halves print on their sides, so anything steeper would need support
//   * main tab: 17-degree flanks, longer -- the main bottom prints flat, so its pockets are just holes in the bed face
//   * the main bottom gets a small pad inside over each pocket (its floor is only 2.4mm)
// Keys sit at main X = km_x: clear of the faceplate window (70..210), the floor vents and both sets of magnets.
km_x = [46, 242];
km_depth = 3;                      // pocket depth, both shells
km_neck = 7;
km_kb_len = 6;   km_kb_end = km_neck + 2*km_kb_len;      // 19 wide at the far end (45 degrees)
km_main_len = 14; km_main_end = 15;
km_riser_t = 2.8;
km_clr = 0.2;
km_t = km_depth - 0.2;             // tab thickness
module km_kb_2d(grow = 0) {        // plan of the keyboard tab: (lateral x, y = distance INTO the keyboard from the seam)
    offset(delta = grow) polygon([[-km_neck/2, -km_riser_t], [km_neck/2, -km_riser_t], [km_neck/2, 0],
                                  [km_kb_end/2, km_kb_len], [-km_kb_end/2, km_kb_len], [-km_neck/2, 0]]);
}
module km_main_2d(grow = 0) {      // plan of the main tab: y = distance INTO the main case from the seam is -y
    offset(delta = grow) polygon([[-km_neck/2, 0], [km_neck/2, 0], [km_main_end/2, -km_main_len], [-km_main_end/2, -km_main_len]]);
}
module km_key() {                  // in the assembled frame: x lateral, y across the seam (+ = keyboard side), z = main frame
    translate([0, 0, -kb_dz]) linear_extrude(height = km_t) km_kb_2d();
    translate([-km_neck/2, -km_riser_t, -kb_dz]) cube([km_neck, km_riser_t, kb_dz + km_t]);
    linear_extrude(height = km_t) km_main_2d();
}
module keyboard_main_keys() {      // printed on its side (lateral axis vertical) so nothing overhangs
    for (i = [0 : len(km_x) - 1])
        translate([kb_dz, i*(km_kb_end + 8), km_main_end/2]) rotate([0, 90, 0]) km_key();
}
module kb_km_pockets() {           // keyboard frame
    for (X = km_x)
        translate([kb_x0 + kb_w - X, kb_d, -0.01]) mirror([0, 1, 0]) linear_extrude(height = km_depth + 0.01) km_kb_2d(km_clr);
}
module main_km_pads() {            // inside the main bottom, on the floor against the front wall
    for (X = km_x)
        translate([X - (km_main_end/2 + 2), main_front_y - km_main_len - 2, 0])
            cube([km_main_end + 4, km_main_len + 2 - wall + 0.5, km_depth + 2]);
}
module main_km_pockets() {
    for (X = km_x)
        translate([X, main_front_y, -0.01]) linear_extrude(height = km_depth + 0.01) {
            km_main_2d(km_clr);
            translate([-km_neck/2 - km_clr, -0.5]) square([km_neck + 2*km_clr, 1.5]);
        }
}

// ============================================================================
// SEAM JOINER KEYS -- bow-tie (butterfly) keys let into the UNDERSIDE across the seam
// ============================================================================
// Extra strength between the halves out toward the front and back, on top of the pins and the back plate. The recesses
// are small dovetail-shaped pockets in the underside: a 17-degree flank, so each half prints them without support, and
// they are all but invisible (and sit under the stick-on feet's clearance) if the keys are never fitted.
// Print keyboard_joiner_keys, glue one into each pocket (thickness kb_joiner_t, flush with the underside).
kb_joiner_l = 26;  kb_joiner_w_end = 15;  kb_joiner_w_neck = 7;
kb_joiner_depth = 2;                     // pocket depth into the 3mm floor
kb_joiner_clr   = 0.2;
kb_joiner_t     = kb_joiner_depth - 0.2;
kb_joiner_ys    = [10, 38, 118];         // front rim, the solid strip between the hollows, and just ahead of the controller tunnel
module kb_joiner_2d(grow = 0) {
    offset(delta = grow) polygon([[-kb_joiner_l/2, -kb_joiner_w_end/2], [-kb_joiner_l/2, kb_joiner_w_end/2],
                                  [0, kb_joiner_w_neck/2], [kb_joiner_l/2, kb_joiner_w_end/2],
                                  [kb_joiner_l/2, -kb_joiner_w_end/2], [0, -kb_joiner_w_neck/2]]);
}
module kb_joiner_pockets() {
    for (y = kb_joiner_ys)
        translate([kb_w/2, y, -0.01]) linear_extrude(height = kb_joiner_depth + 0.01) kb_joiner_2d(kb_joiner_clr);
}
module kb_joiner_keys() {
    for (i = [0 : len(kb_joiner_ys) - 1])
        translate([0, i*(kb_joiner_w_end + 4), 0]) linear_extrude(height = kb_joiner_t) kb_joiner_2d();
}

// Split-line pins (left half gets pins, right half gets holes): in the solid
// strip between the two hollows, ahead of the board-A bay, and low enough to
// sit under the sloped pocket floor there.
kb_pin_y0 = max(38, ceil(9 / tan(kb_slope_deg)) + 2);   // far enough back that the plane is >= 9mm up (pin sits at z=4.5)
kb_pins = [
    [kb_pin_y0,      4.5],
    [kb_pin_y0 - 12, 4.5],   // forward of the first: behind it (y+12) the ribbon relief opens the strip up and left the peg half in the air
    // NEW: in the roof over where the board's back end sits -- the seam otherwise had nothing
    // holding the two halves in line back there
    [(kb_pocket_y1 + kbA_wall_y0) / 2, (kbA_roof_z + kb_cap_h) / 2],
    // and one out in the overhang over the cable bay, where the seam otherwise has nothing keeping the halves level
    [kb_d - 8, (kbA_roof_z + kb_cap_h) / 2],
];
module kb_split_pins() {
    for (p = kb_pins)
        translate([kb_w/2, p[0], p[1]]) rotate([0,90,0]) cylinder(d = 5, h = 8);
}
module kb_split_pin_holes() {
    for (p = kb_pins)
        translate([kb_w/2 - 0.01, p[0], p[1]]) rotate([0,90,0]) cylinder(d = 5.4, h = 10);
}

module kb_case_bottom(joiners = true) {   // joiners = false for the one-piece print: no bow-tie pockets on the seam
    difference() {
        union() {
            difference() {
                kf_shell();
                kb_boardA_bay();
                kb_cable_bay();
                kb_boardA_access();
                kb_plate_slot();
                kb_plate_grooves();
                if (de9_enabled) kb_de9();
                if (kb_join_magnets && lip_socket_tabs_enabled) kb_socket_pockets();
            }
            kb_boardA_floor();
            kb_boardA_bosses();
            if (kbA_back_ledges) kb_boardA_back_lips();   // the two low ledges the back corners used to rest on: the bosses replace them
            if (kb_print_on_side) kb_wedge_gussets();
        }
        kb_boardA_pilots();
        kb_bezel_screw_holes();
        kb_art_m2_head_recesses();
        if (joiners) kb_joiner_pockets();   // after the floor refill, which would otherwise fill the one at y=118
        if (kb_join_keys) kb_km_pockets();
        // cut LAST, after the blocks are unioned in, so nothing can fill them
        if (kb_join_magnets) kb_magnet_pockets();
        if (kb_join_bolts)   kb_bolt_pilots();
    }
}

module kb_case_bottom_left() {
    union() {
        intersection() {
            kb_case_bottom();
            translate([-500,-500,-500]) cube([kb_w/2+500, 2000, 2000]);
        }
        kb_split_pins();
    }
}
module kb_case_bottom_right() {
    difference() {
        intersection() {
            kb_case_bottom();
            translate([kb_w/2,-500,-500]) cube([2000, 2000, 2000]);
        }
        kb_split_pin_holes();
    }
}

// ============================================================================
// KEYBOARD BEZELS (OEM and Artemis)
// ============================================================================
// Both sit in the keyboard pocket, top flush with the shell's top surface, held by the four M3 bezel screws
// (kb_bezel_screws) coming up from under the shell. Built in KEYBOARD-PLANE coords -- u = shell X, v = along the
// slope from the shell's front (same v as kb_bezel_screws / the pocket), w = up, square to the pocket floor --
// and put on the slope by kb_plane() for the preview.
//
//  - OEM bezel: the stock keyboard has its own thick body/surround (outline = the Artemis STL's outer outline; body =
//    the STL's face outline stretched kb_oem_body_grow in X, kb_oem_open_r corners; top kb_oem_surround_top above
//    the pocket floor). The bezel is one solid ring around that body, from the keyboard frame (kb_oem_frame_top) up
//    to flush with the surround, with the screw pilots and brace voids in it.
//  - Artemis bezel: the Artemis PCB (OEM-sized, mounting holes on the same pattern) lies on the pocket floor and
//    "Artemis v3 bezel.stl" sits on it. The file is modelled upside down: turned over about its long (X) axis, its
//    wide 1.6mm layer (OEM outline) is the UNDERSIDE on the PCB -- left as-is, its window/notches clear PCB parts --
//    and its 5mm narrow layer is the face. Right way up the key window's narrow (~8mm) tab is at the FRONT (spacebar /
//    arrow keys) and the wide (~18mm) tab at the upper right. The bezel is that STL with everything above it filled
//    solid to the common top (kb_bz_top) -- only the key window and the LED hole (upper left, tapered) stay open --
//    plus solid ends, the skirt, and the wing holes plugged for the screws.
kb_oem_frame_top    = 3.0;    // OEM keyboard frame top at the screw holes, above the pocket floor (4.8mm holes)
kb_oem_surround_top = 13.5;   // OEM keyboard's own surround top above the pocket floor
kb_oem_open_r       = 8;      // corner radius of the OEM surround's opening (the bezel's opening follows it)
kb_oem_body_grow    = 2.25;   // the OEM module's thick body is this much longer PER SIDE (X only) than the STL's face layer:
                              // first print's opening was exactly 5 short on the long axis (depth and corners right),
                              // second print's +5 was 0.5 too long
// triangular braces on the OEM keyboard's wings, between the wing (frame top) and the thick body: each spans this range
// back from the keyboard's front edge, reaches kb_oem_brace_out out along the wing and kb_oem_brace_h up the body.
// Two per side, both sides; the bezel's solid ends get a triangular void over each.
kb_oem_braces_v   = [[37, 44], [76, 84]];
kb_oem_brace_out  = 7;
kb_oem_brace_h    = 6;
kb_oem_brace_clr  = 0.5;
kb_bz_top_w = kb_pocket_depth * cos(kb_slope_deg);   // shell top surface above the pocket floor, square to the plane
kb_bz_proud = -1.0;           // bezel top relative to the shell's top: 1 BELOW it, flush with the OEM module's surround
                              // (was +1; the first print left the module ~2 sunken in the bezel)
kb_bz_top   = kb_bz_top_w + kb_bz_proud;
kb_bz_wall_clr = 0.25;        // bezel outline inside the pocket walls
kb_bz_kb_clr   = 0.3;         // skirt clear of the keyboard's outline; OEM opening clear of the surround's opening
kb_bz_pilot_d  = 2.5;         // M3 self-tapping pilot
kb_bz_pilot_top = 0.6;        // skin left over the blind pilot
kb_bz_min_w    = 1.2;         // thinner skin than this is dropped (won't print)
// Artemis STL. Everything below is in its RIGHT-WAY-UP coords (the raw file turned over about X: y -> -y, z -> 6.6-z):
kb_art_stl    = "Artemis v3 bezel.stl";
kb_art_h      = 6.6;
kb_art_wide_h = 1.6;          // underside layer (OEM outline) on the PCB; the face layer above it is the other 5mm
kb_art_pcb_t  = 1.6;          // Artemis PCB, on the pocket floor
kb_art_hole_c = [2.98, -7.78];              // hole pattern centre (304.67 x 60.02, measured from the mesh)
kb_art_face_x = [-141.18, 148.43];          // X extent of the face layer (measured) -- the ends outside it are made solid
// the wide tab at the BACK of the key window (upper right) is 18.0 wide in the STL (x 103.59..121.58, coming forward
// from the window's back edge: y 20.82..40.23); the user asked for 1mm off each side -> 16.0
kb_art_tab_x    = [103.59, 121.58];
kb_art_tab_y    = [20.82, 40.23];
kb_art_tab_trim = 1;
// M2 self-tappers from under the Artemis PCB, through it, into the bezel (stiffness). Positions from the KiCad bezel-layer
// SVGs ("2511 Artemis v3-Bezel Layers": BOTTOM r1.5 / MIDDLE r0.9), relative to the SVG's own M3 mounting holes
// (55.35/360.15 x 76.65/136.65, centre 207.75,106.65 -- which sit on kb_bezel_screws). SVG y runs toward the FRONT.
kb_art_m2_svg   = [[128.01, 50.50], [282.01, 50.50], [128.01, 161.00], [282.01, 161.00]];
kb_art_m2_svg_c = [207.75, 106.65];
kb_art_m2_pilot = 1.6;        // M2 self-tapping pilot
kb_art_m2_depth = 8;          // pilot depth above the PCB -> M2 x 8 (1.6 PCB + 6.4 bite) or x 10
kb_art_m2_head_d = 5.5;       // recess in the keyboard shell's pocket floor for each M2 head (the PCB lies on the floor)
kb_art_m2_head_h = 2.2;
// the STL's own blind 2.7 holes near these spots (0.25-0.45 off the SVG positions, too big to bite): plugged
kb_art_stl_m2_holes = [[-77.04, -62.59], [77.48, -62.59], [-77.04, 47.91], [77.48, 47.91]];   // right-way-up STL coords

module kb_plane() { translate([0, 0, kb_raise]) rotate([kb_slope_deg, 0, 0]) children(); }
// right-way-up STL coords -> plane coords: its hole pattern lands on the screw pattern
module kb_art_frame() {
    translate([kb_w/2, kb_pocket_y0 + (kb_bezel_screw_v[0] + kb_bezel_screw_v[1])/2]) translate(-kb_art_hole_c) children();
}
module kb_art_solid() { translate([0, 0, kb_art_h]) rotate([180, 0, 0]) import(kb_art_stl); }   // right way up, z 0..6.6
module kb_bz_pocket_2d() {
    translate([(kb_w - kb_pcb_w)/2 - kb_pocket_left_ext, kb_pocket_y0 - kb_pocket_front_ext])
        offset(r = kb_pocket_corner_r) offset(delta = -kb_pocket_corner_r)
            square([kb_pcb_w + kb_pocket_left_ext, kb_pcb_d + kb_pocket_front_ext]);
}
module kb_bz_in_2d() { offset(delta = -kb_bz_wall_clr) kb_bz_pocket_2d(); }        // bezel outline
module kb_kbd_outline_2d() { kb_art_frame() hull() projection() kb_art_solid(); }   // OEM keyboard / Artemis PCB = STL outline
module kb_art_face_cut_2d() { kb_art_frame() projection(cut = true) translate([0, 0, -(kb_art_h - 1)]) kb_art_solid(); }  // 1mm under the face
module kb_art_face_2d() { hull() kb_art_face_cut_2d(); }                              // face outline (~290x119.5 = OEM opening)
module kb_art_open_2d() { difference() { kb_art_face_2d(); kb_art_face_cut_2d(); } }  // key window + LED hole, as seen from the top
// the bands left and right of the face (full depth): the solid ends
function kb_body_u() = [kb_w/2 - kb_art_hole_c[0] + kb_art_face_x[0] - kb_oem_body_grow,   // OEM thick body's X edges
                        kb_w/2 - kb_art_hole_c[0] + kb_art_face_x[1] + kb_oem_body_grow];
module kb_oem_body_2d(clr = 0) {   // OEM thick body = the face outline stretched kb_oem_body_grow each way in X
    hull() for (s = [-1, 1]) translate([s*kb_oem_body_grow, 0]) offset(delta = clr) kb_art_face_2d();
}
function kb_art_m2_pts() = [ for (q = kb_art_m2_svg)    // plane coords (u, v)
    [kb_w/2 + (q[0] - kb_art_m2_svg_c[0]), kb_pocket_y0 + (kb_bezel_screw_v[0] + kb_bezel_screw_v[1])/2 - (q[1] - kb_art_m2_svg_c[1])] ];
module kb_art_m2_head_recesses() {
    kb_plane() for (p = kb_art_m2_pts()) translate([p[0], p[1], -kb_art_m2_head_h]) cylinder(d = kb_art_m2_head_d, h = kb_art_m2_head_h + 1, $fn = 32);
}
module kb_bz_skirt(h) {       // fills the pocket around the keyboard's outline (only where there's room: the ~0.4 strip
                              // down each side is under kb_bz_min_w, won't slice, and is dropped)
    translate([0, 0, 0.3]) linear_extrude(height = h - 0.3)
        intersection() {   // (re-growing after the thin-strip filter bulges ~0.1 past the clearance line: clip it back)
            kb_bz_in_2d();
            offset(delta = kb_bz_min_w/2) offset(delta = -kb_bz_min_w/2)
                difference() { kb_bz_in_2d(); offset(delta = kb_bz_kb_clr) kb_kbd_outline_2d(); }
        }
}
module kb_bz_pilots(w0) {
    for (s = kb_bezel_screws) translate([s[0], s[1], w0]) cylinder(d = kb_bz_pilot_d, h = kb_bz_top - kb_bz_pilot_top - w0, $fn = 24);
}
module kb_bezel_oem() {
    // one solid ring: everything outside the module's body opening (r8 corners), from the keyboard frame
    // (kb_oem_frame_top) up to the top. The underside is flat all round -- the old front/rear skirt ran on down to
    // the pocket floor and stood 2.7 proud of it, fouling the module -- and the top sits flush with the module's
    // own surround (kb_bz_top)
    difference() {
        translate([0, 0, kb_oem_frame_top]) linear_extrude(height = kb_bz_top - kb_oem_frame_top)
            offset(delta = kb_bz_min_w/2) offset(delta = -kb_bz_min_w/2) difference() { kb_bz_in_2d();
                offset(r = kb_oem_open_r) offset(delta = -kb_oem_open_r) kb_oem_body_2d(kb_bz_kb_clr); }
        kb_bz_pilots(kb_oem_frame_top - 0.1);
        kb_oem_brace_voids();
    }
}
// right-angled triangle in the wing/body corner (legs along the wing and up the body), grown by kb_oem_brace_clr
module kb_oem_brace_voids() {
    c = kb_oem_brace_clr;
    for (b = kb_oem_braces_v, side = [0, 1]) {
        edge = kb_body_u()[side];
        out = side == 0 ? -1 : 1;                                  // along the wing, away from the body
        y0 = kb_pocket_y0 + kb_kbd_front_clr + b[0] - c;           // keyboard front edge + measured range
        hull() for (p = [[-c, -0.1], [kb_oem_brace_out + 2*c, -0.1], [-c, kb_oem_brace_h + 2*c]])
            translate([edge + out*p[0] - 0.005, y0, kb_oem_frame_top + p[1]]) cube([0.01, b[1] - b[0] + 2*c, 0.01]);
    }
}
module kb_bezel_artemis() {
    w_art = kb_art_pcb_t;              // STL underside
    w_face = w_art + kb_art_h;         // STL face
    // trimmed to the pocket: with its holes on the screw pattern the STL's outline sits 0.6 off-centre and pokes
    // ~0.2 into the left wall
    intersection() {
        translate([0, 0, -1]) linear_extrude(height = kb_bz_top + 2) kb_bz_in_2d();
        difference() {
            union() {
                translate([0, 0, w_art]) kb_art_frame() kb_art_solid();
                kb_bz_skirt(kb_bz_top);
                // everything outside the face layer, from the underside layer's top up
                translate([0, 0, w_art + kb_art_wide_h - 0.01]) linear_extrude(height = kb_bz_top - (w_art + kb_art_wide_h) + 0.01)
                    difference() { kb_bz_in_2d(); offset(delta = -0.2) kb_art_face_2d(); }   // overlaps the face layer's edge
                // over the face: solid to the top, only the key window and LED hole open
                translate([0, 0, w_face - 0.01]) linear_extrude(height = kb_bz_top - w_face + 0.01)
                    difference() { kb_art_face_2d(); kb_art_open_2d(); }
                for (s = kb_bezel_screws) translate([s[0], s[1], w_art]) cylinder(d = 5, h = kb_art_wide_h + 0.01, $fn = 32);   // plug the wing hole
                translate([0, 0, w_art]) kb_art_frame() for (h = kb_art_stl_m2_holes)                                           // plug the STL's 2.7 holes
                    translate(h) cylinder(d = 4.2, h = 3.8, $fn = 32);
            }
            kb_bz_pilots(w_art - 0.1);
            // trim the back tab's two sides (all the way up: below the face layer that area is window anyway)
            kb_art_frame() for (x = [kb_art_tab_x[0], kb_art_tab_x[1] - kb_art_tab_trim])
                translate([x - 0.01, kb_art_tab_y[0] - 0.01, -1]) cube([kb_art_tab_trim + 0.01, kb_art_tab_y[1] - kb_art_tab_y[0], kb_bz_top + 2]);
            for (p = kb_art_m2_pts()) translate([p[0], p[1], w_art - 0.1]) cylinder(d = kb_art_m2_pilot, h = kb_art_m2_depth + 0.1, $fn = 20);
        }
    }
}
// print orientation: top face down on the bed, so the top comes out smooth and nothing overhangs. A real 180-degree
// turn about the long axis, so the printed part IS the design. (This used to be mirror([0,0,1]) -- which prints the
// design's mirror image: the first Artemis print came out left/right reversed, LED hole back-right.)
module kb_bz_print() { translate([0, 0, kb_bz_top]) rotate([180, 0, 0]) translate([0, -2 * kb_pocket_y0 - kb_pcb_d, 0]) children(); }
// The OEM bezel keeps the old MIRRORED output on purpose: that print was test-fitted and is right (the model's 0.6
// off-centre body, taken from the Artemis STL, is evidently the wrong way round for the real OEM module).
module kb_bz_print_oem() { translate([0, 0, kb_bz_top]) mirror([0, 0, 1]) children(); }
module kb_bz_half(right) {
    intersection() {
        children();
        translate([right ? kb_w/2 : kb_w/2 - 1000, -500, -500]) cube([1000, 2000, 2000]);
    }
}

// ============================================================================
// ONE-PIECE BOTTOM -- main bottom + keyboard shell as a single print (one_piece_bottom = true)
// ============================================================================
// The keyboard shell in its docked position (kb_place), fused to the main bottom. With kb_feet on, both stand on z=0.
// The seam strip fills the V-groove the main bottom's 2mm bottom fillet would leave along the joint. It stops just above
// the fillet: higher up the wall has the PCB-edge lip relief at its top, which must stay. The shared faceplate window
// stays open, so the cable bay still connects the two boards and the keyboard faceplate goes in through the main
// case's window.
module one_piece_seam_fill() {
    h = bottom_fillet_r + 1;
    difference() {
        intersection() {
            solid_from_footprint(case_margin, 0, h, rear_margin);   // clipped to the main case's plan (its rounded corners)
            translate([-500, main_front_y - wall, 0]) cube([1000, wall + 0.01, h]);
        }
        translate([board_w/2 - fp_len/2, main_front_y - wall - 1, fp_z0]) cube([fp_len, wall + 2, h]);
    }
    translate([kb_x0 + kb_corner_r, main_front_y - 0.01, 0]) cube([kb_w - 2*kb_corner_r, 1, kb_base_t]);   // keyboard side: 1mm under its back floor edge
}
// Square front corners on the main base: the keyboard's back face covers them, and the rounding only left a notch
// between the two. Fills just the sliver outside the rounded outline (0.2 into the wall, never into the cavity).
module one_piece_front_corners() {
    for (x0 = [-case_margin, board_w + case_margin - corner_r])
        difference() {
            translate([x0, main_front_y - corner_r, 0]) cube([corner_r, corner_r, parting_h]);
            translate([0, 0, -1]) linear_extrude(parting_h + 2) offset(delta = -0.2) main_footprint_2d(case_margin, rear_margin);
        }
}
// CoCo4-style floor: the keyboard's width carries on back past the main case to its rear face as a low plinth, with a
// cove (concave quarter-round) up into the main base's side walls. Only outside the main footprint -- under the main
// case it would plug the floor vents. The cove is stacked outline offsets, so it follows the main's rounded rear
// corners, and is cut off flush with the rear face.
one_piece_plinth_h = kb_base_t;   // plinth top = the keyboard's floor top
one_piece_cove_r   = 8;
module one_piece_plinth_plan() {
    y1 = main_front_y + kb_corner_r;   // under the keyboard's rounded back corners, so the plinth carries its side line straight on
    hull() {
        translate([kb_x0 + kb_corner_r, -rear_margin + kb_corner_r]) circle(r = kb_corner_r);
        translate([kb_x0 + kb_w - kb_corner_r, -rear_margin + kb_corner_r]) circle(r = kb_corner_r);
        translate([kb_x0, y1 - 0.01]) square([kb_w, 0.01]);
    }
}
function one_piece_cove_off(t) = one_piece_cove_r - sqrt(max(0, one_piece_cove_r^2 - (one_piece_cove_r - t)^2));
module one_piece_plinth() {
    n = 12;  R = one_piece_cove_r;  z0 = one_piece_plinth_h;
    difference() {
        union() {
            linear_extrude(z0) one_piece_plinth_plan();
            intersection() {
                union() for (i = [0 : n - 1])
                    hull() for (t = [i*R/n, (i + 1)*R/n])
                        translate([0, 0, z0 - 0.01 + t]) linear_extrude(0.01)
                            offset(delta = one_piece_cove_off(t)) main_footprint_2d(case_margin, rear_margin);
                translate([-500, -rear_margin, 0]) cube([1000, main_front_y + rear_margin, z0 + R + 1]);
                linear_extrude(z0 + R + 1) one_piece_plinth_plan();
            }
        }
        translate([0, 0, -1]) linear_extrude(z0 + R + 3) offset(delta = -0.2) main_footprint_2d(case_margin, rear_margin);
    }
}
module bottom_one_piece() {
    assert(one_piece_bottom, "part \"bottom_one_piece\" needs one_piece_bottom = true (it sets kb_feet so the undersides line up)");
    union() {
        main_bottom_part();
        kb_place() kb_case_bottom(joiners = false);
        one_piece_seam_fill();
        one_piece_front_corners();
        one_piece_plinth();
    }
}

// ============================================================================
// FUJINET DRIVE TRAY (part "fujinet_tray")
// ============================================================================
// A 3.5"-drive-sized open frame for the CoCo FujiNet board (CoCo-FujiNet-Rev000.stl, 86 x 55.4, 4 x 3.2 holes) plus a
// 0.91" 128x32 SSD1306 OLED, for one of the floppy bays: front panel, open bottom frame, left/right sides, a rear
// ridge. Screws into the bay rails like a drive (upper hole row). Tray frame: x across (0 = left seen from the front),
// y = depth from the front face, z up from the tray's bottom (printed as it sits, bottom down).
// The board's front edge (buttons, microSD, LEDs) faces out: its button plungers stand fuji_btn_proud past the front
// face, the LEDs behind them show through small windows above the buttons, and the microSD slot has its own opening.
// OLED on the left, board on the right (fuji_oled_left; per the user, operated right-handed, so the hand doesn't cover
// the display). false puts them the other way round.
fuji_pcb_bx = [0, 85.98];  fuji_pcb_by = [-0.92, 54.45];  fuji_pcb_t = 1.51;   // from the STL
fuji_holes  = [[18.44, 2.70], [70.12, 2.70], [18.44, 50.83], [70.12, 50.83]];  // board frame, 3.2mm
fuji_btn_tip = 88.92;                         // plunger tips (board X)
fuji_btns   = [[3.82, 6.96], [46.59, 49.73]]; // plunger Y spans; Z 3.52..6.67 above the PCB's underside
fuji_btn_z  = [3.52, 6.67];
fuji_led_z1 = 9.89;                           // LED tops (they stand ~9mm behind the plungers, same Y)
fuji_sd_y   = [19.66, 34.36];  fuji_sd_z = [1.65, 3.50];   // microSD socket mouth
tray_w = floppy_w;  tray_h = floppy_h;
tray_panel_t = 2.5;
tray_wall_t  = 2.4;
tray_side_h  = 16;
tray_floor_t = 2;
fuji_btn_proud = 0.14;
fuji_zp = 5.0;                                // PCB underside above the tray bottom: its solder tails (2.4) clear the 2mm floor, and
                                              // the front-left board screw's head tops out ~0.9 under the side screw boss above it
fuji_oled_left = true;
fuji_x0 = fuji_oled_left                      // tray x of the board's by = fuji_pcb_by[0] edge
    ? tray_w - tray_wall_t - 0.5 - (fuji_pcb_by[1] - fuji_pcb_by[0])   // board against the right wall
    : tray_wall_t + 0.5;                                                 // ... or the left
fuji_y0 = fuji_btn_tip - fuji_pcb_bx[1] - fuji_btn_proud;   // tray y of the board's front edge (bx = 85.98)
fuji_ye = fuji_y0 + (fuji_pcb_bx[1] - fuji_pcb_bx[0]);      // ... and of its back edge
tray_d  = fuji_ye + 2.7;                      // rear ridge just behind the board
function fuji_pt(bx, by) = [fuji_x0 + (by - fuji_pcb_by[0]), fuji_y0 + (fuji_pcb_bx[1] - bx)];
module fuji_place() {   // board STL -> tray frame (a rotation, no mirror)
    multmatrix([[0, 1, 0, fuji_x0 - fuji_pcb_by[0]], [-1, 0, 0, fuji_y0 + fuji_pcb_bx[1]], [0, 0, 1, fuji_zp], [0, 0, 0, 1]]) children();
}
// Bay mounting: the bays' side rails take screws at floppy_screw_front_offsets back from the front face, at the UPPER
// row (floppy_screw_z_offsets[1]; the lower row's bosses ran into the board's own front-left standoff) -- M3 x 8
// through the 3mm rail into a 5mm-deep pilot.
tray_boss_d = 6.4;  tray_boss_depth = 5;      // pilot depth from the side's outer face; the boss makes up the rest
tray_screw_z = floppy_screw_z_offsets[1];
// Floor: a 2mm plate with voronoi cut-outs (fixed seeds, so the pattern is stable between renders), solid around the
// rim, under the walls / front panel / rear ridge, and around each board standoff.
tray_vor_rib  = 2.4;                           // rib width between cells
tray_vor_rim  = 5;                             // solid border
tray_vor_nx = 5;  tray_vor_ny = 6;  tray_vor_seed = 7;
function tray_vor_pts() = let (
        x0 = tray_vor_rim, x1 = tray_w - tray_vor_rim, y0 = 9, y1 = tray_d - 4,
        r = rands(-0.35, 0.35, 2*tray_vor_nx*tray_vor_ny, tray_vor_seed))
    [ for (i = [0 : tray_vor_nx - 1], j = [0 : tray_vor_ny - 1])
        let (k = 2*(i*tray_vor_ny + j), cx = (x1 - x0)/tray_vor_nx, cy = (y1 - y0)/tray_vor_ny)
        [x0 + cx*(i + 0.5 + r[k]), y0 + cy*(j + 0.5 + r[k + 1])] ];
module tray_vor_halfplane(a, b) {   // points closer to a than to b
    m = (a + b)/2;  d = b - a;
    translate(m) rotate(atan2(d[1], d[0])) translate([-400, -200]) square([400, 400]);
}
module tray_vor_cells() {
    pts = tray_vor_pts();
    for (i = [0 : len(pts) - 1])
        offset(r = 1) offset(delta = -tray_vor_rib/2 - 1)
            intersection_for (j = [for (k = [0 : len(pts) - 1]) if (k != i) k]) tray_vor_halfplane(pts[i], pts[j]);
}
module tray_floor_2d() {
    difference() {
        square([tray_w, tray_d]);
        difference() {
            intersection() {
                tray_vor_cells();
                translate([tray_vor_rim, tray_vor_rim]) square([tray_w - 2*tray_vor_rim, tray_d - 2*tray_vor_rim]);
            }
            square([tray_w, 9]);                                                   // under the front panel and OLED pocket
            translate([0, tray_d - 4]) square([tray_w, 4]);                        // under the rear ridge
            for (h = fuji_holes) translate(fuji_pt(h[0], h[1])) circle(r = 6);    // around the standoffs
        }
    }
}
// 0.96" 128x64 SSD1306 OLED, GoldenMorning GME12864-11 (user's spec sheet): PCB 27.5 wide x 27.8 tall x 1.2, 3.5 max
// with the glass, 4-pin header along the top edge (4.27 down), viewing area 23.744 x 12.864 centred across the width
// and 5.37 down from the top edge. It is TALLER than a drive (27.8 vs 25.4, and the bay opening is only 26.7), so it
// stands up past the tray's top -- and therefore sits oled_glass_y back from the front face, behind the bay face's
// 4mm bulkhead (floppy_bulkhead_t), with the front panel thickened out to meet the glass around the window. Header up
// (the module's normal orientation), pins pointing back over the pocket's low back wall.
// Fitting: put the display in the tray first, then install the tray from INSIDE the case (top off / lid open): lower
// it between the rails and slide it forward into the opening -- with the display in, it no longer passes through the
// opening from the front.
oled_pcb = [27.5, 27.8];  oled_t = 3.5;          // width, height; max thickness with the glass
oled_va = [23.744, 12.864];  oled_va_top = 5.37; // viewing area, and its top edge below the module's top edge
oled_header_dn = 4.27;                           // header row below the top edge
oled_clr = 0.3;
oled_glass_y = floppy_bulkhead_t + 0.3;          // glass face back from the tray's front face
oled_z0 = 1.0;                                   // module bottom above the tray bottom (the floor is recessed under it)
oled_x0 = (fuji_oled_left                     // centred in the space beside the board
    ? (tray_wall_t + fuji_pt(0, fuji_pcb_by[0])[0]) / 2
    : (fuji_pt(0, fuji_pcb_by[1])[0] + (tray_w - tray_wall_t)) / 2) - oled_pcb[0]/2;
oled_win_m = 0.5;                                // window margin around the viewing area
function oled_va_z() = oled_z0 + oled_pcb[1] - oled_va_top - oled_va[1];   // viewing area's bottom edge (tray z)
module fujinet_tray() {
    ox0 = oled_x0 - oled_clr;  ox1 = oled_x0 + oled_pcb[0] + oled_clr;
    oy1 = oled_glass_y + oled_t + oled_clr;           // back face of the pocket
    wz1 = oled_z0 + oled_pcb[1] - oled_header_dn - 2.5;   // back wall top: under the header's plastic
    screw_ys = [for (o = floppy_screw_front_offsets) o];
    difference() {
        union() {
            cube([tray_w, tray_panel_t, tray_h]);                                            // front panel
            for (x = [0, tray_w - tray_wall_t]) translate([x, 0, 0]) cube([tray_wall_t, tray_d, tray_side_h]);   // sides
            linear_extrude(tray_floor_t) tray_floor_2d();                                     // voronoi floor
            translate([0, tray_d - 2, 0]) cube([tray_w, 2, 8]);                                // rear ridge
            for (h = fuji_holes) { p = fuji_pt(h[0], h[1]); translate([p[0], p[1], 0]) cylinder(d = 6.5, h = fuji_zp); }
            for (x = [0, tray_w], y = screw_ys)                                               // side screw bosses
                translate([x, y, tray_screw_z]) rotate([0, 90, 0])
                    translate([0, 0, x == 0 ? 0 : -tray_boss_depth - 1]) cylinder(d = tray_boss_d, h = tray_boss_depth + 1);
            // OLED pocket: the front panel thickened back to the glass, side walls, a low back wall, a floor under it
            translate([ox0 - 1.2, tray_panel_t - 0.01, 0]) cube([ox1 - ox0 + 2.4, oled_glass_y - tray_panel_t + 0.01, tray_h]);
            for (x = [ox0 - 1.2, ox1]) translate([x, tray_panel_t, 0]) cube([1.2, oy1 + 1.4 - tray_panel_t, tray_h]);
            translate([ox0 - 1.2, oy1, 0]) cube([ox1 - ox0 + 2.4, 1.4, wz1]);
            translate([ox0 - 1.2, tray_panel_t, 0]) cube([ox1 - ox0 + 2.4, oy1 + 1.4 - tray_panel_t, tray_floor_t]);
        }
        // front openings: button plungers, LED windows above them, microSD
        for (b = fuji_btns) {
            x0 = fuji_x0 + b[0] - fuji_pcb_by[0];  x1 = fuji_x0 + b[1] - fuji_pcb_by[0];
            translate([x0 - 0.3, -1, fuji_zp + fuji_btn_z[0] - 0.3]) cube([x1 - x0 + 0.6, tray_panel_t + 2, fuji_btn_z[1] - fuji_btn_z[0] + 0.6]);
            translate([x0 - 0.3, -1, fuji_zp + fuji_btn_z[1] + 1.1]) cube([x1 - x0 + 0.6, tray_panel_t + 2, fuji_led_z1 + 0.6 - fuji_btn_z[1] - 1.1]);
        }
        translate([fuji_x0 + fuji_sd_y[0] - fuji_pcb_by[0] - 0.4, -1, fuji_zp + fuji_sd_z[0] - 0.5])
            cube([fuji_sd_y[1] - fuji_sd_y[0] + 0.8, tray_panel_t + 2, fuji_sd_z[1] - fuji_sd_z[0] + 1.0]);
        // OLED: window (flared 45 degrees toward the outside, so the deep panel doesn't shade the edges), and the pocket
        hull() {
            translate([oled_x0 + (oled_pcb[0] - oled_va[0])/2 - oled_win_m, oled_glass_y - 0.01, oled_va_z() - oled_win_m])
                cube([oled_va[0] + 2*oled_win_m, 0.02, oled_va[1] + 2*oled_win_m]);
            f = min(1.5, tray_h - 0.8 - (oled_va_z() + oled_va[1] + oled_win_m));   // flare, kept inside the panel's height
            translate([oled_x0 + (oled_pcb[0] - oled_va[0])/2 - oled_win_m - f, -1, oled_va_z() - oled_win_m - f])
                cube([oled_va[0] + 2*oled_win_m + 2*f, 1.01, oled_va[1] + 2*oled_win_m + 2*f]);
        }
        translate([ox0, oled_glass_y, oled_z0 - oled_clr]) cube([ox1 - ox0, oy1 - oled_glass_y, tray_h + 10]);
        // pilots
        for (h = fuji_holes) { p = fuji_pt(h[0], h[1]); translate([p[0], p[1], tray_floor_t]) cylinder(d = m3_pilot_d, h = fuji_zp); }
        for (x = [0, tray_w], y = screw_ys)
            translate([x, y, tray_screw_z]) rotate([0, 90, 0])
                translate([0, 0, x == 0 ? -1 : -tray_boss_depth]) cylinder(d = m3_pilot_d, h = tray_boss_depth + 1);
    }
}
// board outline must not run into the side wall or the OLED pocket
assert(fuji_oled_left ? fuji_pt(0, fuji_pcb_by[0])[0] > oled_x0 + oled_pcb[0] + oled_clr + 1.2
                      : fuji_pt(0, fuji_pcb_by[1])[0] < oled_x0 - oled_clr - 1.2, "FujiNet board overlaps the OLED pocket");
assert(oled_x0 - oled_clr - 1.2 > tray_wall_t - 0.01 && oled_x0 + oled_pcb[0] + oled_clr + 1.2 < tray_w - tray_wall_t + 0.01,
       "OLED pocket runs into a side wall");
assert(oled_va_z() + oled_va[1] + oled_win_m < tray_h - 0.8, "OLED viewing area runs off the top of the front panel");
assert(tray_d <= floppy_d, "tray deeper than the bay's drive depth");

// ============================================================================
// PART SELECTOR
// ============================================================================
// Set to one of:
//   "preview"              -- everything laid out together, for looking at
//   "main_bottom_left"     -- printable piece
//   "main_bottom_right"    -- printable piece
//   "main_bottom_whole"    -- unsplit (only fits printers >= ~300mm)
//   "main_top_left"        -- printable piece
//   "main_top_right"       -- printable piece
//   "main_top_whole"       -- unsplit (only fits printers >= ~300mm)
//   "keyboard_bottom_left" -- printable piece (magnet or bolted variant, per keyboard_attached)
//   "keyboard_bottom_right"-- printable piece
//   "keyboard_bottom_whole"
//   "keyboard_magnet_plugs"  -- 4 small plugs, glued into the underside magnet slots
//   "keyboard_faceplate"     -- plate with USB/LED/button openings for the KEYBOARD's back wall (press-fit/snap)
//   "main_faceplate"         -- taller version of the same plate for the MAIN bottom's front wall (screwed, no thin wall sliver above it)
//   "keyboard_bridge_plate"  -- stepped plate joining keyboard and main bottom for the permanently-attached build
//   "keyboard_joiner_keys"   -- 3 bow-tie keys for the underside seam pockets
//   "keyboard_main_keys"     -- 2 stepped bow-tie keys joining the keyboard to the main bottom (underside, across the front/back seam)
//   "bezel_oem_whole/_left/_right"      -- bezel over the stock keyboard (print orientation: top face down)
//   "bezel_artemis_whole/_left/_right"  -- Artemis STL + filler/skin, one piece (same orientation)
//   "bezel_fit_oem" / "bezel_fit_artemis" -- the bezel sitting in the keyboard shell, for looking at
//   "usbc_clip"            -- clip plate for the 16.2 x 10.6 USB-C power board, screws onto the rear-left bosses
//   "fujinet_tray"         -- 3.5"-bay tray for the CoCo FujiNet board + a 0.91" OLED ("fujinet_tray_fit" shows the board in it)
//   "bottom_one_piece"     -- main bottom + keyboard shell as one part (needs one_piece_bottom = true; ~334 x 341)
//                             -> print main_top_* with one_piece_bottom = true as well (its skirt is 5mm taller)
part = "fujinet_tray";

// exploded gap between the bottom tray and top shell in "preview" only, so
// the parting line and connector notches are visible; they sit flush (no
// gap) in every actual printable part.
preview_explode_z = 0;
// Y gap between the main case's front face and the keyboard shell's back
// face in "preview" (0 = as assembled, magnets/bolts touching).
kb_preview_gap = 0;

// ============================================================================
// ORIENTATION LABELS -- "preview" only, never part of a printable piece.
// Flat text laid on the floor plane (readable top-down, and still legible
// at most orbit angles) plus a small RGB axis triad at the model origin
// (red=X, green=Y, blue=Z -- standard CAD convention), so orientation is
// visually self-evident when you rotate the model in the GUI instead of
// having to trust a render's camera angle.
// ============================================================================
label_h = 12;
label_z = 2;
module label_text(msg, size = 12) {
    linear_extrude(height = 1.2)
        text(msg, size = size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}
module orientation_labels() {
    color("Crimson") {
        translate([board_w/2, -case_margin - 14, label_z])
            label_text("REAR (Y=0) -- SW1/JK1-4/J5A-B/SW2-3", 7);
        translate([board_w/2, main_front_y + 14, label_z])
            label_text("FRONT / KEYBOARD SIDE (+Y)", 9);
        translate([-case_margin - 16, board_d/2, label_z])
            rotate([0,0,90])
                label_text("RIGHT SIDE -- CART SLOT CN1 (-X)", 9);
        translate([board_w + case_margin + 16, board_d/2, label_z])
            rotate([0,0,90])
                label_text("LEFT SIDE (+X)", 9);
    }
    // RGB axis triad at the board-frame origin (X=0,Y=0,Z=0)
    axis_len = 40;
    translate([0,0,0]) {
        color("Red")   rotate([0,90,0])  cylinder(d=2, h=axis_len);      // +X
        color("Red")   translate([axis_len,0,0]) label_text("+X", 8);
        color("Green") rotate([-90,0,0]) cylinder(d=2, h=axis_len);      // +Y
        color("Green") translate([0,axis_len,0]) label_text("+Y", 8);
        color("Blue")  cylinder(d=2, h=axis_len);                        // +Z
        color("Blue")  translate([0,0,axis_len+4]) label_text("+Z", 8);
    }
}

if (part == "preview") {
    color("SlateGray") main_bottom_part();
    color("LightSteelBlue")
        translate([0, 0, preview_explode_z])
            main_top_part();
    color("Orange")
        translate([0, 0, preview_explode_z])
            main_pizero_hdmi_mount(); // reference only -- see main_case_top()'s own comment
    orientation_labels();
    color("DimGray")
        translate([0, kb_preview_gap, 0])
            kb_place() kb_case_bottom();
} else if (part == "main_bottom_left") {
    main_case_bottom_left();
} else if (part == "main_bottom_right") {
    main_case_bottom_right();
} else if (part == "main_bottom_whole") {
    main_bottom_part();
} else if (part == "main_top_left") {
    main_case_top_left();
} else if (part == "main_top_right") {
    main_case_top_right();
} else if (part == "main_top_whole") {
    main_top_part();
} else if (part == "keyboard_bottom_left") {
    kb_case_bottom_left();
} else if (part == "keyboard_bottom_right") {
    kb_case_bottom_right();
} else if (part == "keyboard_bottom_whole") {
    kb_case_bottom(joiners = false);
} else if (part == "keyboard_magnet_plugs") {
    kb_magnet_plugs();
} else if (part == "keyboard_faceplate") {
    kb_faceplate();
} else if (part == "main_faceplate") {
    main_faceplate();
} else if (part == "keyboard_bridge_plate") {
    kb_bridge_plate();
} else if (part == "keyboard_main_keys") {
    keyboard_main_keys();
} else if (part == "keyboard_joiner_keys") {
    kb_joiner_keys();
} else if (part == "bezel_oem_whole") {
    kb_bz_print_oem() kb_bezel_oem();
} else if (part == "bezel_oem_left") {
    kb_bz_print_oem() kb_bz_half(false) kb_bezel_oem();
} else if (part == "bezel_oem_right") {
    kb_bz_print_oem() kb_bz_half(true) kb_bezel_oem();
} else if (part == "bezel_artemis_whole") {
    kb_bz_print() kb_bezel_artemis();
} else if (part == "bezel_artemis_left") {
    kb_bz_print() kb_bz_half(false) kb_bezel_artemis();
} else if (part == "bezel_artemis_right") {
    kb_bz_print() kb_bz_half(true) kb_bezel_artemis();
} else if (part == "fujinet_tray") {
    fujinet_tray();
} else if (part == "fujinet_tray_fit") {   // tray + the board and the OLED (as a box) in place, for looking at
    color("SteelBlue") fujinet_tray();
    color("Green") fuji_place() import("CoCo-FujiNet-Rev000.stl");
    color("Black") translate([oled_x0, oled_glass_y, oled_z0]) cube([oled_pcb[0], oled_t, oled_pcb[1]]);
} else if (part == "usbc_clip") {
    translate([0, 0, -usbc_trigger_boss_h]) usbc_clip();   // plate on the bed
} else if (part == "bottom_one_piece") {
    bottom_one_piece();
} else if (part == "bezel_fit_oem" || part == "bezel_fit_artemis") {   // bezel in place in the keyboard shell, for looking at
    color("DimGray") kb_case_bottom();
    color("Goldenrod") kb_plane() if (part == "bezel_fit_oem") kb_bezel_oem(); else kb_bezel_artemis();
}
