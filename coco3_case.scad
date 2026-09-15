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
$fn             = 48;     // circle resolution (raise for final render, lower for fast preview)

/* [Keyboard attachment mode] */
// true  = keyboard shell is structurally merged with the main shell (one
//         continuous printed seam, reinforced rib, NOT separable)
// false = keyboard shell is a separate, detachable part: lip-and-socket +
//         magnets join it to the main shell
keyboard_attached = false;
// Rectangular lip/socket lugs (main_lip_socket / kb_socket_pockets) --
// separate from the magnet pockets, which stay on either way. Per
// direction, turned off for now (magnets alone are enough of an
// interlock to test with); flip back to true to bring the tabs back.
lip_socket_tabs_enabled = false;

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
front_deck_h       = 42;   // low front section height (over keyboard/front 2/3)
                            // (raised from 26 -> 42 when the main case became a
                            // top/bottom clamshell: needs to clear parting_h with
                            // a bit of top-shell roof left over -- see below)
rear_tower_h       = 62;   // tall rear section height (louvered "spine")
rear_break_front   = 0.52; // fraction of board depth where the ramp begins
rear_break_back    = 0.74; // fraction of board depth where the ramp reaches full height
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
// KEYBOARD-CONTROLLER PCB GEOMETRY (real, from Coco_pico_keyb.step)
// ============================================================================
function kbpcb_pt(x,y) = [x - 79.5, -y - 28];

kbpcb_outline_raw = [
 [190.000,-31.000],[187.000,-28.000],[82.500,-28.000],[79.500,-31.000],
 [79.500,-31.443],[81.000,-33.600],[79.500,-32.557],[79.500,-105.500],
 [82.500,-108.500],[187.000,-108.500],[190.000,-105.500]
];
kbpcb_outline = [ for (p = kbpcb_outline_raw) kbpcb_pt(p[0], p[1]) ];
kbpcb_w = 110.5; kbpcb_d = 80.5; kbpcb_thickness = 1.56; // real

kbpcb_standoffs = [
  for (h = [ [84.000,-102.000,3.2],[186.000,-102.000,3.2],[186.000,-52.000,3.2],
             [151.960,-42.500,3.2],[176.960,-42.500,3.2] ])
    [ kbpcb_pt(h[0],h[1])[0], kbpcb_pt(h[0],h[1])[1], h[2] ]
];

pico_pos = kbpcb_pt(98.58, -53.97); // TODO verify USB-connector edge/orientation against real board

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

// ============================================================================
// MAIN (MOTHERBOARD) SHELL
// ============================================================================
main_depth = board_d + case_margin + rear_margin;
main_break1_y = main_depth * rear_break_front;
main_break2_y = main_depth * rear_break_back;

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
    margin = 50;
    hull() {
        translate([x0, -margin, 0]) cube([x1-x0, main_break1_y+margin, max(h_rear, 0.01)]);
        translate([x0, main_break2_y, 0]) cube([x1-x0, (main_depth-main_break2_y)+margin, max(h_front, 0.01)]);
    }
}

// ---- BOTTOM shell: a plain shallow tray up to parting_h, flat, no wedge --
// per a photo of a real stock case bottom (floor, standoffs, no connector
// cutouts, no styling). Much simpler than the wedge: just the rounded-rect
// footprint, extruded straight up.
module main_bottom_outer_solid() {
    rounded_footprint_solid(case_margin, 0, parting_h, rear = rear_margin, br = bottom_fillet_r);
}
module main_bottom_inner_cavity() {
    // open at the top rim (pokes through by 5mm so there's no ceiling)
    solid_from_footprint(case_margin - wall, new_floor_t, parting_h + 5, rear = rear_margin - wall);
}

// ---- TOP shell: the styled wedge (tower/ramp/deck + louvers), spanning
// from parting_h up to the roofline. Same footprint-extrude +
// height-clipping-wedge-block technique as before, just z-shifted to start
// at parting_h instead of 0.
module main_top_outer_solid() {
    // Padded 2mm above the wedge block's own max height so the two solids
    // being intersected never share an exactly coincident flat top plane --
    // see main_bottom/top_inner_cavity below for why that matters (CGAL
    // treats an exact coincidence as degenerate and renders visible sliver
    // artifacts).
    intersection() {
        solid_from_footprint(case_margin, parting_h, max(rear_tower_h, front_deck_h) + 2, rear = rear_margin);
        y_wedge_block(-500, board_w+500, rear_tower_h, front_deck_h);
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

module main_louvers() {
    // The tall tower sits at LOW Y (rear panel side). Vents go on its rear
    // vertical face (min Y, the true back of the machine) and its left
    // vertical face (min X). Only the portion of the tower that's part of
    // the TOP shell (parting_h..rear_tower_h) is available for the bank now.
    min_y = -rear_margin;
    min_x = -case_margin;
    max_x = board_w + case_margin;
    mid_x = (min_x+max_x)/2;
    run_len = (max_x-min_x)*0.8;

    // Fit the bank within the top shell's tower wall height, leaving margin
    // at the roofline and at the parting-line rim, so slots never poke
    // through either.
    louver_margin_top = 6;
    louver_margin_bottom = 6;
    tower_top_span = rear_tower_h - parting_h;
    available_h = tower_top_span - louver_margin_top - louver_margin_bottom;
    pitch = louver_w + louver_gap;
    fit_count = max(1, min(louver_count, floor((available_h + louver_gap) / pitch)));
    bank_center_z = parting_h + louver_margin_bottom + available_h/2;

    // rear face vents (true back of the machine)
    translate([mid_x, min_y, bank_center_z])
        louver_bank(fit_count, louver_w, louver_gap, run_len, louver_depth*4);

    // Side vents, over the tower's Y-extent only (0..break1), on the
    // max-X wall -- deliberately the wall WITHOUT the cart slot (which is
    // on the min-X wall after the board_pt mirror fix), so the two don't
    // spatially collide.
    translate([max_x, main_break1_y/2, bank_center_z])
        rotate([0,0,90])
            louver_bank(fit_count, louver_w, louver_gap, main_break1_y*0.9, louver_depth*4);
}

// U-shaped notches open at the TOP shell's own bottom rim (parting_h),
// rising `height` above it -- per a photo of a real stock case, which cuts
// all its connector-panel openings in the TOP shell, not the bottom. This
// also happens to be far more printable than a fully-enclosed round hole
// mid-wall: printed upside down (rim facing up on the bed), each notch is
// just an open channel with zero overhang, no supports needed. Sizes are
// still the same placeholder commodity-connector envelopes flagged in the
// file header -- only the shape (closed hole -> open notch) changed here.
module rim_notch_y(x, wall_y, width, height, depth) {
    translate([x - width/2, wall_y, parting_h - 1])
        cube([width, depth, height + 1]);
}
module rim_notch_x(wall_x, y, width, height, depth, dir = -1) {
    // dir=-1: wall_x is a max-X (right, in the old pre-mirror sense) wall,
    //         cut inward toward -X.
    // dir=+1: wall_x is a min-X wall, cut inward toward +X. Cart slot uses
    //         this now that it's on the min-X wall (post board_pt mirror).
    x0 = (dir < 0) ? wall_x - depth : wall_x;
    translate([x0, y - width/2, parting_h - 1])
        cube([depth, width, height + 1]);
}

// Rear-panel USB-C power input -- replaces the OEM power header (out of
// scope to reuse, see file header). Position along the rear wall is a
// placeholder: parked left of SW1 in open space, clear of every real
// connector; move it once you've picked an actual USB-C panel-mount part.
usbc_power_x = 20;

// Separate USB-C PD "trigger" board mount, back-left corner (per
// direction) -- clear of SW1 (the leftmost real rear connector, X~232) --
// so the board can be installed and powered with the case closed and
// nothing else populated yet; the trigger board's own USB-C port is
// accessible through this rear cutout, and everything else it needs
// (buttons, LEDs, output pads) lives on the board itself. First-pass
// generic dimensions -- common small USB-C PD trigger boards run around
// 22x22mm -- true up once you've picked the real part.
usbc_trigger_x        = 272;
usbc_trigger_cut_w     = 14; // rear cutout for the USB-C port + cable clearance
usbc_trigger_cut_h     = 7;
usbc_trigger_cut_z     = 6;  // cutout vertical center above the floor
usbc_trigger_board_w   = 22;
usbc_trigger_board_d   = 22;
usbc_trigger_boss_h    = 3;  // flush/low-profile, same reasoning as the kbpcb bosses
usbc_trigger_hole_d    = 2.5;
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

module main_connector_cutouts_top() {
    notch_depth = case_margin*3;
    for (c = board_connectors) {
        refdes = c[0]; x = c[1]; y = c[2]; kind = c[5];
        if (kind == "din6" || kind == "din4" || kind == "din5" || kind == "rgb_din8")
            rim_notch_y(x, -rear_margin, 15.9, 20, notch_depth);
        else if (kind == "rca")
            rim_notch_y(x, -rear_margin, 10.5, 16, notch_depth);
        else if (kind == "power_switch")
            rim_notch_y(x, -rear_margin, 14, 14, notch_depth);
        else if (kind == "slide_switch")
            rim_notch_y(x, -rear_margin, 10, 11, notch_depth);
        else if (kind == "reset_button")
            rim_notch_y(x, -rear_margin, 8, 12, notch_depth);
        else if (kind == "cart_slot")
            rim_notch_x(-case_margin, y, 92, 13 + 6, notch_depth, dir = 1);
        // "cart_slot" exits the RIGHT-SIDE panel (min X, post board_pt mirror, still case_margin), all others exit the REAR panel (min Y, now rear_margin)
    }
    rim_notch_y(usbc_power_x, -rear_margin, 10, 5, notch_depth);
}

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
    translate([board_w*0.5, (main_front_y + 130)/2, parting_h*0.4])
        rect_cutout(20, 11, main_front_y - 130 + case_margin*2); // depth along Y
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

module main_standoffs_solid() {
    for (s = board_standoffs)
        standoff_peg_solid(s[0], s[1], s[2], standoff_height);
}
module main_standoffs_holes() {
    for (s = board_standoffs)
        standoff_peg_hole(s[0], s[1], s[2], standoff_height);
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
// that new brace"), EXCEPT directly over the raceway's own open channel
// (Z0-5 there only), so the hollow cable path stays clear -- everywhere
// else, including over the raceway's solid legs, it's a real floor-to-12
// wall, not just a thin slab bridging across.
cn1_raceway_brace_w  = 3;
cn1_raceway_brace_h  = 12;
cn1_raceway_brace_x1 = 32; // past the raceway's far leg (raceway_x+~6) with clearance
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
                    cube([raceway_w + 1, cn1_raceway_brace_w + 2, raceway_h + 1]);
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
    for (i = [1:n]) {
        x = board_w*i/(n+1);
        if (x < kb_x0 || x > kb_x1)
            translate([x - beam_brace_w/2, beam_y(), 0])
                cube([beam_brace_w, front_wall_inner_y - beam_y(), standoff_height]);
    }
    // The kbpcb gap splits the beam into two stubs (see main_support_beam):
    // a long one to the left (beam_margin..kb_x0) that still gets 2 braces
    // above (i=1,2), and a short one to the right (kb_x1..board_w-
    // beam_margin) that previously got NONE, since none of the 4 evenly-
    // spaced positions land in its short span. Per direction, one brace in
    // the middle is enough for that short a run -- same solid-block style
    // as the rest of this beam's braces.
    short_stub_mid = (kb_x1 + (board_w - beam_margin)) / 2;
    translate([short_stub_mid - beam_brace_w/2, beam_y(), 0])
        cube([beam_brace_w, front_wall_inner_y - beam_y(), standoff_height]);
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
rear_rib_depth = 5;
function rear_rib_x(refdes) = [for (c = board_connectors) if (c[0]==refdes) c[1]][0];
rear_rib_positions = [
    (rear_rib_x("SW1") + rear_rib_x("JK1")) / 2,
    (rear_rib_x("JK2") + rear_rib_x("JK3")) / 2,
    (rear_rib_x("JK4") + rear_rib_x("J5A")) / 2, // "other side of JK4" from JK3
    (rear_rib_x("J5A") + rear_rib_x("J5B")) / 2, // between video and sound
];
module main_rear_support_ribs() {
    inner_wall_y = -(rear_margin - wall);
    for (x = rear_rib_positions)
        translate([x - rear_rib_w/2, inner_wall_y, 0])
            cube([rear_rib_w, rear_rib_depth, standoff_height]);
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
// Position: kept entirely BEHIND the main support beam in Y (front edge at
// Y=145.5, beam is at Y=149.26) so only the one cross brace needed
// removing, not the beam itself. X is chosen so the Pico's USB connector
// (pico_pos, real data from Coco_pico_keyb.step) lines up with the
// EXISTING front-panel USB passthrough cutout (main_usb_passthrough_front,
// at the middle of the front wall, X=board_w/2=140) -- per direction, "USB
// poking out the middle front." The board itself stays clear of the wall;
// a short cable/coupler (same idea as the passthrough cutout's own name)
// bridges the remaining ~25mm gap from the Pico to the panel -- standard
// practice, and avoids having to flip the board's orientation to get the
// Pico flush against the wall, which would instead push its OTHER mounting
// holes (some closer to local Y=0 than the Pico is) past the wall entirely.
main_kbpcb_origin = [board_w/2 - pico_pos[0], 65];
kbpcb_screw_boss_d = 7;
kbpcb_screw_pilot_d = 2.6; // self-tap pilot for the board's 3.2mm holes
kbpcb_screw_boss_h = 3; // flush/low-profile -- was 10 (a tall freestanding
                         // pillar); per direction, these sit low to the
                         // floor instead. Still tall enough for a couple mm
                         // of real self-tap thread engagement.
// Reuses all 5 of the board's REAL mounting holes (kbpcb_standoffs) -- this
// is the actual physical Pico keyboard-controller PCB's own hole pattern,
// so every hole should get a boss unless there's a real fit conflict.
kbpcb_boss_brace_w = 4;
kbpcb_boss_brace_run = 5; // short -- these bosses are only 3mm tall to begin with
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
cart_support_span_y = 100;
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
// the support platform above (wall to CN1), for the same reason. First-pass
// height/spacing (just outside the 92mm slot opening); verify against a
// real cartridge edge/Multipak card before finalizing.
cart_guide_h    = 18;
cart_guide_t    = 2.5;
cart_guide_span = 96;
module main_cart_guide_walls() {
    xy = cn1_xy();
    inner_wall_x = -(case_margin - wall);
    for (side = [-1, 1])
        translate([inner_wall_x, xy[1] + side*cart_guide_span/2 - cart_guide_t/2, standoff_height])
            cube([xy[0] - inner_wall_x, cart_guide_t, cart_guide_h]);
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
raceway_x  = cn3_xy()[0] + 3;
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
// moves back (toward the rear), and the whole right wall moves in (toward
// center). Back and left stay at their original position. Tuned by hand
// directly in this file to 5mm front / 6mm right -- both still leave the
// collar's remaining footprint short of the access-cut hole (42x42,
// unchanged, see main_cn3_access_cut() below) on those two sides, so
// there's no wall material near the hole there -- open on the front and
// right (by a few mm now, not the full inset), still a real 2.4mm frame
// on the back and left.
cn3_collar_front_inset = 5;
cn3_collar_right_inset = 6;
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
cn3_pedestal_drop   = 8;
cn3_pedestal_base_h = standoff_height - cn3_pedestal_drop;
module main_cn3_access_cut() {
    // Subtractive: wider lead-in step near the floor, then the true
    // 42x42 opening the rest of the way up to standoff_height.
    xy = cn3_xy();
    translate([xy[0] - cn3_open/2 - cn3_step_extra+8, xy[1] - cn3_open/2 - cn3_step_extra, -1])
        cube([cn3_open + 2*cn3_step_extra-10, cn3_open + 2*cn3_step_extra-6, cn3_step_h + 1]);
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
    cn3_xy()[1] - cn3_open/2 - cn3_collar_t + cn3_pedestal_back_recede
];
module main_cn3_shelf() {
    xy = cn3_xy();
    p0 = main_cn3_pedestal_xy0();
    x0 = p0[0]; y0 = p0[1];
    difference() {
        translate([xy[0] - cn3_open/2+4, xy[1] - cn3_open/2, cn3_pedestal_base_h])
            cube([cn3_open-4, cn3_open-3, cn3_wall_min]);
        translate([x0 + cn3_wall_min, y0 + cn3_wall_min, cn3_pedestal_base_h - 1])
            cube([cn3_pedestal_w - 2*cn3_wall_min, cn3_pedestal_d - 2*cn3_wall_min, cn3_wall_min + 2]);
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
cn3_new_standoff_hole_d = 3.5;
function cn3_new_standoff_xy() = [cn3_xy()[0] - cn3_open/2 + 8, cn3_xy()[1] + cn3_open/2 - 7];
module main_cn3_new_standoff() {
    p = cn3_new_standoff_xy();
    translate([0, 0, cn3_pedestal_base_h])
        standoff_peg(p[0], p[1], cn3_new_standoff_hole_d, standoff_height - cn3_pedestal_base_h);
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

magnet_d = 6; magnet_h = 2.5; // standard 6x2.5mm disc magnets
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
main_magnet_x = [30, 90, 165, 220];
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

// ---- TOP/BOTTOM fastening ----
// Self-tapping screws driven from OUTSIDE the bottom shell's underside
// (same convention as the real machine: flip the assembled case over to
// service it), up through floor clearance holes into bosses that hang down
// from the top shell's ceiling. First-pass positions (3 along the rear
// edge, 3 along the front edge, inset 25mm from the rim so they clear the
// connector notches, which cut 18mm deep into the same wall); fit-check and
// retune like the other first-pass joints in this file (lip/socket, magnets).
main_topbottom_screw_xy = [
    for (fx = [0.15, 0.5, 0.85]) [board_w*fx, 25]
]; //rear-side row only, unioned with the front-side row below
// 4 more, right in the extreme corners -- per direction, so there's a
// solid top/bottom connection point right at each corner too, not just
// along the rear/front edges. Measured from the case's own TRUE corners
// (the actual outer footprint corners, before corner_r rounding) rather
// than the board frame the row above uses, since "how close to the real
// corner" is what actually matters here -- pushed in to 6mm per direction
// (down from an initial 15mm), still clear of the corner_r=5 rounding and
// sitting entirely on continuous floor past every wall's inner face.
main_topbottom_screw_corner_inset = 6;
main_topbottom_screw_corners = [
    for (cx = [-case_margin + main_topbottom_screw_corner_inset,
                board_w + case_margin - main_topbottom_screw_corner_inset])
    for (cy = [-rear_margin + main_topbottom_screw_corner_inset,
                main_front_y - main_topbottom_screw_corner_inset])
        [cx, cy]
];
main_topbottom_screw_positions = concat(
    main_topbottom_screw_xy,
    [ for (p = main_topbottom_screw_xy) [p[0], main_depth - 25] ], // mirrored to the front-side row
    main_topbottom_screw_corners
);

module main_topbottom_screw_boss_top() {
    // Each boss spans the FULL available height at its own Y, from the
    // parting-line rim up to the underside of the roof there (the roofline
    // varies with Y across the wedge/ramp) -- a boss that doesn't actually
    // reach the roof is structurally disconnected from the shell (this bit
    // us once already: floating pegs with no roof contact).
    for (p = main_topbottom_screw_positions) {
        boss_h = local_wedge_h(p[1], rear_tower_h, front_deck_h) - wall - parting_h;
        translate([p[0], p[1], parting_h])
            difference() {
                cylinder(d = 8, h = boss_h);
                translate([0,0,-1]) cylinder(d = 2.8, h = boss_h + 2); // self-tap pilot, M3-ish
            }
    }
}
module main_topbottom_screw_clearance_bottom() {
    for (p = main_topbottom_screw_positions)
        translate([p[0], p[1], -1])
            union() {
                cylinder(d = 3.6, h = new_floor_t + 2);  // shaft clearance through the floor
                cylinder(d = 7, h = 3);                  // countersink for the screw head
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
                main_cn3_collar();
                main_support_beam();
                main_beam_cross_braces();
                main_rear_support_ribs();
                main_cn4_rib();
                main_kbpcb_mount();
                main_usbc_trigger_standoffs_solid();
                if (!keyboard_attached) main_magnet_pads();
                if (!keyboard_attached && lip_socket_tabs_enabled) main_lip_socket();
            }
            main_usb_passthrough_front();
            main_topbottom_screw_clearance_bottom();
            main_cn3_access_cut();
            main_cable_raceway_end_cuts();
            main_cable_raceway_floor_cut();
            main_pcb_edge_lip_relief();
            main_usbc_trigger_cutout();
            main_standoffs_holes(); // cut LAST, after every other solid is unioned in,
                                     // so nothing (e.g. the cart support platform,
                                     // which overlaps a couple of these) can silently
                                     // fill a pilot hole back in
            main_usbc_trigger_standoffs_holes(); // same reason, cut last
            main_floor_vents();
            if (!keyboard_attached) main_magnet_pockets();
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
        main_cn3_shelf();
        main_cn3_pedestal();
        main_cn3_new_standoff();
    }
}

module main_case_top() {
    union() {
        difference() {
            union() {
                difference() { main_top_outer_solid(); main_top_inner_cavity(); }
                main_topbottom_screw_boss_top();
            }
            main_louvers();
            main_connector_cutouts_top();
        }
        main_pizero_hdmi_mount(); // bosses only (additive); shown for reference/preview
    }
}

// ---- bed-size splitting (board is 280mm > 250mm bed) ----
main_split_x = board_w/2 + BOARD_X_OFF*0; // split roughly at the midpoint; move to
                                          // dodge the cartridge slot / tall tower if needed
module main_case_bottom_left() {
    intersection() {
        main_case_bottom();
        translate([-500,-500,-500]) cube([main_split_x+500, 2000, 2000]);
    }
    // Simple alignment pins + bolt bosses at the seam, each rooted to the
    // FLOOR with a vertical post. Confirmed via the STL connected-
    // components check that this matters: at yy=30 the pin sits in open
    // interior space (no wall, standoff, or other feature anywhere near
    // it), so the pin was floating -- disconnected from the body entirely
    // -- regardless of how far it overlapped past the split plane (tried
    // 1mm of overlap first; didn't help, because the problem was never
    // about the split-plane boundary, it was that nothing solid was there
    // at all). The floor (Z=0 to new_floor_t) is the one thing that's
    // reliably solid EVERYWHERE in the footprint, so rooting each pin to
    // it with a post guarantees connectivity regardless of what's nearby.
    pin_post_d = 8;
    for (yy = [30, main_depth-30]) {
        translate([main_split_x - 1, yy, parting_h/2])
            rotate([0,90,0]) cylinder(d=6, h=9);
        translate([main_split_x - 1, yy, 0])
            cylinder(d=pin_post_d, h=parting_h/2);
    }
}
module main_case_bottom_right() {
    difference() {
        intersection() {
            main_case_bottom();
            translate([main_split_x,-500,-500]) cube([2000, 2000, 2000]);
        }
        for (yy = [30, main_depth-30])
            translate([main_split_x, yy, parting_h/2])
                rotate([0,90,0]) cylinder(d=6.4, h=10);
    }
}
module main_case_top_left() {
    intersection() {
        main_case_top();
        translate([-500,-500,-500]) cube([main_split_x+500, 2000, 2000]);
    }
    for (yy = [30, main_depth-30])
        translate([main_split_x, yy, parting_h + (rear_tower_h-parting_h)/2])
            rotate([0,90,0]) cylinder(d=6, h=8);
}
module main_case_top_right() {
    difference() {
        intersection() {
            main_case_top();
            translate([main_split_x,-500,-500]) cube([2000, 2000, 2000]);
        }
        for (yy = [30, main_depth-30])
            translate([main_split_x, yy, parting_h + (rear_tower_h-parting_h)/2])
                rotate([0,90,0]) cylinder(d=6.4, h=10);
    }
}

// ============================================================================
// KEYBOARD SHELL  (mechanical keyboard dims are PLACEHOLDER — see header)
// ============================================================================
kb_outer_w = keyboard_unit_w + 2*(keyboard_deck_margin);
kb_outer_d = keyboard_unit_d + 2*(keyboard_deck_margin);
kb_shell_h = keyboard_unit_h + wall*2 + 6;

module kb_outer_solid() {
    linear_extrude(height = kb_shell_h)
        offset(r = corner_r) offset(delta = -corner_r)
            square([kb_outer_w, kb_outer_d]);
}
module kb_inner_cavity() {
    translate([0,0,wall])
        linear_extrude(height = kb_shell_h)
            offset(r = corner_r) offset(delta = -corner_r)
                square([kb_outer_w - 2*wall, kb_outer_d - 2*wall]);
}
module kb_window() {
    translate([keyboard_deck_margin, keyboard_deck_margin, -1])
        linear_extrude(height = kb_shell_h+2)
            square([keyboard_unit_w, keyboard_unit_d]);
}

module kb_pcb_standoffs() {
    // positions relative to the controller PCB's own local frame, placed
    // toward one corner of the keyboard tray floor -- move kb_pcb_origin to
    // taste once tray size is finalized.
    kb_pcb_origin = [kb_outer_w - kbpcb_w - 10, 10];
    for (s = kbpcb_standoffs)
        translate([kb_pcb_origin[0]+s[0], kb_pcb_origin[1]+s[1], 0])
            standoff_peg(0, 0, s[2], 6);
}

module kb_rear_cutouts() {
    // USB (Pico) + DE-9 joystick access on the BACK of the keyboard case.
    // TODO: confirm exact Pico USB edge/orientation and J6 DE-9 pin mapping
    // against the physical board before finalizing X positions.
    kb_pcb_origin = [kb_outer_w - kbpcb_w - 10, 10];
    usb_x = kb_pcb_origin[0] + pico_pos[0];
    translate([usb_x, kb_outer_d, kb_shell_h*0.4])
        rect_cutout(12, 7, wall*3); // depth already runs along Y - no rotation needed

    de9_x = kb_pcb_origin[0] + 40; // placeholder offset from J6 position
    translate([de9_x, kb_outer_d, kb_shell_h*0.5])
        rect_cutout(20, 12, wall*3); // DE-9 shell envelope, depth along Y
}

module kb_socket_pockets() {
    // recesses cut into the tray's rear (mating) wall that main_lip_socket()'s
    // lugs drop into. Positions mirror main_lip_socket()'s spacing formula --
    // re-check alignment once both shell widths (board_w vs kb_outer_w) are
    // finalized, since the two spacings are computed from different widths.
    // Z now flush to the tray's own floor (0..lug_h) and i=3 (the center
    // slot) skipped, to match main_lip_socket()'s rebuilt flush-to-floor
    // lugs -- same reasoning: keep the mating recess aligned with wherever
    // the lug itself actually is.
    lug_w = 10; lug_d = 6; lug_h = 6;
    spacing = kb_outer_w / 6;
    for (i = [1, 2, 4, 5]) {
        x = i*spacing;
        translate([x - lug_w/2 - tol, kb_outer_d - lug_d, -tol])
            cube([lug_w+2*tol, lug_d+tol, lug_h+2*tol]);
    }
}
// ADDITIVE backing pad, mirroring main_magnet_pads() -- must be unioned in
// separately from kb_magnet_pockets() below (the actual holes), which is
// used subtractively.
module kb_magnet_pads() {
    if (magnet_pad_extra > 0) {
        n = 4;
        spacing = kb_outer_w/(n+1);
        for (i=[1:n])
            translate([i*spacing, kb_outer_d - wall - magnet_pad_extra, kb_shell_h*0.3])
                rotate([-90,0,0]) cylinder(d = magnet_pad_d, h = magnet_pad_extra);
    }
}
module kb_magnet_pockets() {
    // Blind pocket bored -Y into the tray's rear wall, mating flush
    // against main_magnet_pockets() on the main shell's front wall, but
    // now stopping magnet_face_t short of the true outer face instead of
    // cutting all the way through it -- same reasoning as the main shell's
    // version: not visible from outside, and the pad above makes up for
    // the wall (2.4mm) being thinner than the magnet (2.5mm).
    n = 4;
    spacing = kb_outer_w/(n+1);
    for (i=[1:n])
        translate([i*spacing, kb_outer_d - magnet_face_t - magnet_bore_len, kb_shell_h*0.3])
            rotate([-90,0,0])
            cylinder(d = magnet_d + 0.2, h = magnet_bore_len);
}

module kb_case_bottom() {
    difference() {
        union() {
            difference() { kb_outer_solid(); kb_inner_cavity(); }
            kb_pcb_standoffs();
            if (!keyboard_attached) kb_magnet_pads();
        }
        kb_window();
        kb_rear_cutouts();
        if (!keyboard_attached) {
            kb_magnet_pockets();
            if (lip_socket_tabs_enabled) kb_socket_pockets();
        }
    }
}

// bed-size split for the keyboard tray too (placeholder width already > 250mm)
kb_split_x = kb_outer_w/2;
module kb_case_bottom_left() {
    intersection() {
        kb_case_bottom();
        translate([-500,-500,-500]) cube([kb_split_x+500, 2000, 2000]);
    }
}
module kb_case_bottom_right() {
    difference() {
        intersection() {
            kb_case_bottom();
            translate([kb_split_x,-500,-500]) cube([2000, 2000, 2000]);
        }
    }
}

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
//   "keyboard_bottom_left" -- printable piece (only if keyboard_attached=false)
//   "keyboard_bottom_right"-- printable piece
//   "keyboard_bottom_whole"
part = "main_bottom_whole";

// exploded gap between the bottom tray and top shell in "preview" only, so
// the parting line and connector notches are visible; they sit flush (no
// gap) in every actual printable part.
preview_explode_z = 0;

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
    color("SlateGray") main_case_bottom();
    color("LightSteelBlue")
        translate([0, 0, preview_explode_z])
            main_case_top();
    orientation_labels();
    if (!keyboard_attached)
        color("DimGray")
            translate([0, main_front_y + 15, 0])
                kb_case_bottom();
} else if (part == "main_bottom_left") {
    main_case_bottom_left();
} else if (part == "main_bottom_right") {
    main_case_bottom_right();
} else if (part == "main_bottom_whole") {
    main_case_bottom();
} else if (part == "main_top_left") {
    main_case_top_left();
} else if (part == "main_top_right") {
    main_case_top_right();
} else if (part == "main_top_whole") {
    main_case_top();
} else if (part == "keyboard_bottom_left") {
    kb_case_bottom_left();
} else if (part == "keyboard_bottom_right") {
    kb_case_bottom_right();
} else if (part == "keyboard_bottom_whole") {
    kb_case_bottom();
}
