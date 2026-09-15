# CoCo3 "CoCo4-style" 3D Printed Case — Project Brief

This project was scoped in a long claude.ai chat (no OpenSCAD/render access there).
This file carries that context into Claude Code, which DOES have real render/mesh
tooling available via the `openscad` CLI. Read this fully before touching the .scad.

## Goal

A 3D-printable replacement case for a Tandy Color Computer 3 (26-3334) motherboard,
styled after the never-released "CoCo4" prototype (photo: `coco4_reference.jpg`) —
a monolithic wedge: low flat front over the keyboard, tall louvered rear tower over
the connector panel — rather than a literal reproduction of the stock CoCo3 case.

**Immediate priority:** get OpenSCAD actually installed and rendering in this
environment, then iterate on `coco3_case.scad` visually. The current file was authored
blind (hand-traced logic, never rendered) and the user has confirmed it does not look
like a case and has misaligned connectors. Do NOT assume the existing geometry is
close to correct — re-derive/fix it with actual render feedback, starting from the
real data below (which IS trustworthy) rather than the current shell-building modules
(which are NOT).

## Hard requirements (from the original spec)

- Fits a 250x250x250 printer via parametric splitting; single-piece printing as an
  option for bigger printers.
- Cartridge slot (CN1) must land at the correct height for a standard CoCo Multipak
  to plug in — this is a physical constraint, not aesthetic. See height stack below.
- Keyboard section: fixed OR removable, controlled by an OpenSCAD parameter
  (`keyboard_attached`). Removable = lip/socket + magnets between the two shells.
- Front of main case: USB passthrough (from the keyboard's Pico controller).
- Back of keyboard case: USB (Pico) access + DE-9 joystick socket access.
- Rear of main case: USB-C power input cutout (replaces the OEM power header —
  do not try to reuse the OEM power connector/header, it's out of scope).
- Provision for EITHER a Raspberry Pi Zero (RGBtoHDMI) OR a bulkhead HDMI coupler
  on the main case.

## REAL data — verified, trust this

### Source files
- `coco3.step` — KiCad STEP export of the 26-3334 motherboard (populated),
  from github.com/qbancoffee/coco_motherboards. ~40MB, many duplicate anonymous
  component instances (this is almost certainly what breaks naive STEP importers
  like Bambu Studio — don't be surprised if it's heavy to load).
- `Coco_pico_keyb.step` — KiCad STEP export of a custom Raspberry-Pi-Pico-based
  keyboard interface board (reads the ORIGINAL CoCo keyboard's matrix via ribbon
  headers, presents USB). U1 = RaspberryPi_Pico footprint.
- `coco4_reference.jpg` — the only visual reference for the target aesthetic.

Both STEP files are plain-text AP214 STEP (ASCII), NOT binary — they can be parsed
directly with regex/text tools; no CAD kernel (OCP/cadquery/FreeCAD) was available
in the claude.ai sandbox, so all geometry below was extracted that way. If Claude
Code has real STEP tooling available (FreeCAD, cadquery, build123d, etc.), consider
re-extracting from scratch and cross-checking against these numbers rather than
trusting the parsing was perfect — the coordinate math was hand-verified but not
independently confirmed by a second method.

### Coordinate convention used throughout `coco3_case.scad`
- Units: mm.
- `board_pt(x,y) = [x + 31.48, -y]` maps the motherboard STEP's native coordinates
  into a first-quadrant frame where **Y=0 is the REAR (connector) edge** and Y
  increases toward the FRONT (keyboard side). X+ = rightward as viewed from the
  front (matches the real cartridge-slot side).
- Board outline bounding box after transform: X 0–280mm, Y 0–156.26mm. It is NOT
  a rectangle — there's a ~42mm-wide tab hanging off the left side for part of the
  depth, plus small relief notches and a stepped top-right corner. Full 39-point
  polygon is in the .scad file (`board_outline_raw`).
- Board thickness: 1.55mm.

### Motherboard standoff holes (real): `[x, y, diameter]` in board frame
```
[239.389, -93.963, 4.0]
[239.389, -28.558, 4.0]
[-27.050, -103.160, 3.5]   <- on the left tab
```

### Motherboard connectors (real position+rotation, confirmed identity by user)
| Refdes | Function | Panel | Notes |
|---|---|---|---|
| SW1 | Power switch | Rear | |
| JK1 | Joystick 1 (DIN-6) | Rear | |
| JK2 | Joystick 2 (DIN-6) | Rear | |
| JK3 | Serial (DIN-4) | Rear | real bbox ~22.1x24.4x15.5mm |
| JK4 | Cassette (5-pin DIN) | Rear | |
| J5A1001 | Composite video (RCA) | Rear | both A and B are populated, NOT alternates |
| J5B1001 | Composite audio (RCA) | Rear | |
| SW3 | Ch3/4 selector (slide switch) | Rear | |
| SW2 | Reset button | Rear | right next to cartridge slot, as expected |
| CN1 | Cartridge edge connector | **RIGHT SIDE**, not rear | confirmed by Tandy service manual: "receptacle on the right side of the unit" |
| CN2 | Keyboard ribbon header | n/a (interior) | NOT used in this redesign — keyboard now goes through the Pico board instead |
| CN3 | RGB (DIN-8 likely) | Rear, bottom-mounted | near rear-right, exits through rear panel despite bottom-side pads |

Exact XYZ + rotation for all of these are in `board_connectors` in the .scad file —
copy from there rather than retyping, to avoid transcription drift.

Power to the board was originally via a header near JK1 — **out of scope**, replaced
by a new USB-C cutout on the rear panel (position not yet finalized).

### Height stack (Multipak compatibility — must preserve)
- OEM boss height (standoff, floor to top of boss): **22.25mm** — measured by user
  from a real stock case.
- OEM case wall/floor thickness: **2.4mm ABS** — measured/estimated by user.
- OEM foot height: **UNKNOWN / not found** in the service manual (mechanical
  drawings are image-only, OCR couldn't reach them). Currently a placeholder
  (~3mm) in the .scad file. Low risk: card-edge slots have several mm of vertical
  play, but flag this as something to true up if the user can measure a stock foot.
- Formula used: `target_pcb_top_above_desk = foot_height + floor_thickness + boss_height`,
  held constant; the new design's own foot height and floor thickness can differ
  from OEM as long as the resulting standoff height is solved to keep the total
  the same. See `standoff_height` calc in the .scad file.

### Keyboard-controller PCB (real, from Coco_pico_keyb.step)
- `kbpcb_pt(x,y) = [x - 79.5, -y - 28]`. Outline bbox 110.5 x 80.5mm (not a plain
  rectangle — small relief notch top-left). Thickness 1.56mm.
- 5 standoff holes, 3.2mm dia: `(84,-102) (186,-102) (186,-52) (151.96,-42.5) (176.96,-42.5)`
  (in the board's own local frame before `kbpcb_pt` transform — see .scad for the
  already-transformed version).
- U1 (RaspberryPi_Pico footprint) at local (98.58, -53.97), rot 0°. **The exact
  edge the Pico's USB connector faces was never resolved** from the STEP nesting —
  positions are real, orientation is not confirmed. Verify against the physical
  board before finalizing the keyboard-case rear cutout.
- J1/J3: two 1x16 headers, rot 90° — almost certainly the two halves of the
  original CoCo keyboard matrix ribbon.
- J6: 2x5 header — likely DE-9 joystick breakout (10 pins ~ DE-9's 9 pins).
- J4 (1x4), J5 (1x2): smaller aux connectors, function unconfirmed.
- SW1: tactile switch. D1/D2 + R1/R2: two LEDs with current-limit resistors.

### Overall OEM cabinet reference (from Tandy service manual, archive.org)
375mm (W) x 79mm (H) x 264mm (D), 2.3kg. Useful for keeping new design's
proportions in the spirit of the original scale, not a hard constraint since the
new case is a different (CoCo4-style) shape.

## PLACEHOLDER data — do not treat as trustworthy

- **Real physical CoCo keyboard (keys/switches/mylar) mechanical envelope**: NOT
  YET MEASURED. User said they'd dig up real numbers "tomorrow" (relative to when
  this brief was written) — check with them before assuming placeholder values in
  `keyboard_unit_w/d/h` are usable. The keyboard tray geometry is designed to
  re-derive automatically from these 4 parameters once real numbers are dropped in.
- Panel cutout sizes for DIN4/5/6, RCA, cartridge slot, power switch, reset,
  slide switch: only JK3 and the two power-jack-shaped connectors resolved to
  real bounding boxes from the STEP file; everything else uses generic standard
  commodity connector dimensions as a starting point. Fine as a first pass, should
  be checked against the user's actual parts.
- Pico USB cutout position/orientation and J6 DE-9 pin mapping on the keyboard
  case rear panel (see above).
- oem_foot_height (see height stack above).

## Known-bad in the current `coco3_case.scad` — user has confirmed it doesn't work

User's exact words: "there's a lot wrong with that openscad. It doesn't look
anything like a case, the connectors aren't lined up, etc." This was written and
"reviewed" entirely by hand-tracing OpenSCAD semantics with no renderer available —
treat the REAL DATA section above as trustworthy, but treat every shell-building
module (`main_outer_solid`, `main_inner_cavity`, the hull-based wedge/loft
approach, the louver cutting, the lip/socket coupling, all cutout placements) as
unverified and likely wrong in ways that weren't caught by manual code review.

**Recommended approach**: don't try to patch the existing hull()-based wedge —
get OpenSCAD rendering ASAP (`openscad -o preview.png --imgsize=1200,900
--camera=0,0,0,55,0,25,600 --colorscheme=Tomorrow coco3_case.scad` or similar,
iterate on camera args), look at what actually comes out, and rebuild the shell
geometry from the real board outline / standoff / connector data with actual
visual feedback in the loop. Multiple render-check-fix cycles per session, not
one blind pass.

## Workflow note

There is no automatic way to import the claude.ai conversation this project came
from into Claude Code — the two products don't share conversation history. This
file is the deliberate substitute: everything load-bearing from that conversation
that isn't already obvious from the source files is captured above. If something
seems missing or ambiguous, ask the user rather than guessing — they have the
original chat to refer back to.
