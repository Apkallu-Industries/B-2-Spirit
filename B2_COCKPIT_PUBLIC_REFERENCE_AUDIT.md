# B-2 Cockpit Public-Reference Audit

## Scope

This audit concerns visual modelling for a flight-simulation cockpit. It is
bounded to public footage, public photos, and the supplied video captures. It
does not infer non-public aircraft procedures, system architecture, software
behaviour, checklist logic, or control laws from a visible switch or display.

The supplied captures are consistent with the rare 2018 in-flight footage of a
B-2 crew station. The footage was publicly released in 2019; contemporary
reporting identifies it as the first public in-flight cockpit video and states
that it was filmed during an October 2018 flight. [The Aviationist](https://theaviationist.com/2019/07/05/exclusive-unpublished-video-with-in-depth-footage-and-commentary-inside-the-cockpit-of-a-flying-b-2-stealth-bomber/)
and [AirWingMedia](https://airwingmedia.com/videos/2019/b2-spirit-stealth-bomber-cockpit-tour-refueling/)
provide the provenance and context. Official USAF/DVIDS material independently
confirms the two-person cockpit and provides useful fixed-ground geometry
reference. [DVIDS cockpit photo](https://www.dvidshub.net/image/4990402/brian-rubio-climbs-into-b-2-spirit-stealth-bomber-cockpit-during-pilot-day)

## What the captures establish

### Forward instrument panel

The strongest evidence is for a shared, dense display bank rather than two
fully duplicated, loosely spaced instrument panels. The visible area has four
large, near-square displays arranged in two rows and two columns. Each display
has a deep rounded rectangular housing, a recessed dark/green screen, corner
fasteners, and individually boxed bezel keys around all four sides.

The capture does not show the entire flight deck at once. Four visible displays
therefore mean “four in this panel crop,” not a claimed total display count for
the aircraft. The new model represents this high-confidence crop only.

| Observable element | Evidence in captures | Modelling treatment | Confidence |
|---|---|---|---|
| Two-by-two primary display bank | Repeated close and wide views | Four matching MFD housings | Reference-backed |
| Recessed CRT-like dark-green displays | Multiple powered-on frames | Green emissive screen surfaces | Reference-backed |
| Bezel key housings and corner fasteners | Clear in close frames | Six physical keys per side plus fasteners | Reference-backed for form; estimated count/spacing |
| Lower display row | Clear in panel closeups | Same envelope as upper row | Reference-backed |
| Large blank/structural panel region beside displays | Repeatedly visible | Kept as plain panel space | Reference-backed |

### Visible display categories

The following categories are safe visual references. They are not a claim that
the labels form a complete authentic menu tree or define key behaviour.

| Visible visual category | Observable clues | Simulation-safe use |
|---|---|---|
| Systems overview | Headings visibly include `FUEL`, `FCS`, `ELEC`, `ECS`, and `ENG`; green matrix/table presentation | Generic systems-status page with non-authentic data |
| Flight/attitude | Blue/brown attitude presentation and flight scales | Generic PFD / attitude page |
| Navigation | Compass-rose, route/heading-style symbology | Generic navigation page |
| Status matrix | Grid and subsystem-state appearance | Generic system health/status page |
| Communications | Dedicated right-side display visibly presents communications text | Generic radio-management page |

The names used in the revision script (`SYS`, `FLT/ATT`, `NAV`, `STATUS`, and
`COMMS`) are intentionally short, generic simulation captions. They keep the
visual hierarchy without copying a supposed operational page structure.

### Right-side communications/control unit

To the right of the primary display bank, the captures show a smaller,
vertically oriented control/display unit. It has side keys around a green text
screen and a numeric/function keypad beneath. The visible text includes
communications-related labels such as `COMM 1`, `COMM 2`, `HF`, and `LINK 16`.
The model reproduces its geometry as a separate `COMMS_UFD` assembly, while its
text is a generic presentational placeholder.

### Lower controls

The lower panel has three visually distinct clusters:

1. A broad, diagrammatic switch/knob panel with a visible fuel-system heading
   and white linework.
2. A conspicuous guarded red control on the adjacent panel.
3. A keypad and paired rotary selectors marked with visible high-level legends
   including `BARO`, `CMD ALT`, `RALT SET`, `A/S SET`, `CRS SEL`, and `HDG SEL`.

These items support a dense, sloping lower-console model. The geometry and
visible text are reference-led; their exact interactions remain simulation
abstractions. One specific public official photograph documents a four-switch
AMAD panel on the left side and describes only its broad hydraulic/generator
connection role; it can corroborate the presence of a guarded switch cluster,
but should not be used to reverse-engineer a cockpit procedure.
[DVIDS AMAD photo](https://www.dvidshub.net/image/5073129/amad-switches-control)

## Model changes delivered

`B-2 Spirit/Shapes/Cockpit_Source/build_b2_cockpit_reference_revision.py`
creates a standalone Blender scene with:

- one reference-led central four-display bank;
- individual bezel keys, fasteners, dark green screens, and generic display
  strokes;
- a separate communications/control unit and keypad;
- sloped lower-console geometry, control rows, a guarded control, selectors,
  a compact throttle pedestal, two seats, and two control columns;
- material separation for painted panel, trim, CRT glass, keys, fasteners,
  metal, seat fabric, and safety controls;
- explicit Blender custom properties recording `PUBLIC_VISUAL_REFERENCE_ONLY`
  and `SIMULATION_UI_ABSTRACTION` provenance.

The generator produces these verified local outputs:

- `B2_Spirit_Cockpit_Reference_Revision.blend`
- `B2_Spirit_Cockpit_Reference_Revision.png`

It intentionally does **not** overwrite `B-2_Spirit_Cockpit.EDM`. The scene
must first be reviewed, fitted to the exterior airframe, and then exported with
the Windows DCS EDM exporter as a deliberate integration step.

## Reference-led next pass

Further modelling should prioritize shape before labels or functionality:

1. Fit the reference scene to the external airframe's canopy opening and
   pilot eye point.
2. Compare the top coaming, display-bank width, right-side UFD position, and
   lower-console angle against a full-resolution source frame.
3. Add panel seams, Dzus fasteners, molded keycaps, wiring/air vents, and
   readable-but-generic wear textures.
4. Establish Blender animation pivots and clickable areas only after the
   physical model is accepted.
5. Map UI functions to a documented simulation design rather than naming
   public visual details as authentic aircraft procedures.

The present captures leave the far left/right consoles, overhead controls,
throttle geometry, seat details, and rear cockpit weakly constrained. Those
areas should remain visibly plausible and clearly marked as estimated until
additional public reference views are available.

## Sources

1. U.S. Air Force / DVIDS. [“Brian Rubio Climbs into the B-2 Spirit Stealth Bomber Cockpit During Pilot for a Day.”](https://www.dvidshub.net/image/4990402/brian-rubio-climbs-into-b-2-spirit-stealth-bomber-cockpit-during-pilot-day) December 2018.
2. U.S. Air Force / DVIDS. [“AMAD switches control.”](https://www.dvidshub.net/image/5073129/amad-switches-control) December 2018.
3. David Cenciotti, The Aviationist. [“Exclusive: Unpublished Video With In-Depth Footage And Commentary Inside the Cockpit Of A Flying B-2 Stealth Bomber.”](https://theaviationist.com/2019/07/05/exclusive-unpublished-video-with-in-depth-footage-and-commentary-inside-the-cockpit-of-a-flying-b-2-stealth-bomber/) July 2019.
4. AirWingMedia. [“B-2 Spirit Stealth Bomber Cockpit Tour and Refueling.”](https://airwingmedia.com/videos/2019/b2-spirit-stealth-bomber-cockpit-tour-refueling/) 2019.
