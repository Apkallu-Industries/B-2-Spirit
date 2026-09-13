# B-2 Spirit — Completion Status & Roadmap

_Last updated: 2026-09-13. Scope: everything needed to take this mod from
"loads and flies as an SFM flyable" to "looks and behaves as close to the real
B-2 Spirit as DCS allows."_

This document is the single source of truth for what is **done**, what is
**blocked**, and what is **left**. Where a remaining item is model- or
platform-dependent (and therefore risky to put in live code from a Linux CI
box), ready-to-paste code is provided in the Appendices so a Windows/Blender
session can drop it straight in.

---

## 1. Executive summary

The mod is a **Standard Flight Model (SFM) flyable** aircraft. As of now it:

- Loads as a DCS plugin and registers into the Mission Editor (module load,
  country injection, `load_immediately`).
- Has a complete, validated aircraft descriptor (mass/geometry, SFM aero &
  engine tables, sensors, radio), a three-seat crew model, a validated weapons
  set with ME payload presets, and a logical damage model.
- Ships a real, animated **exterior** EDM plus a PBR texture set, liveries,
  quick-start/single missions, and full input profiles.

The single biggest gap to "looks like the real thing" is the **cockpit**: a
detailed interior has been built in Blender source form but **cannot be
exported to `.EDM` on Linux** (see §3). The second biggest is a **clickable,
systems-driven cockpit** (avionics), which is currently stubbed (§4.4).

**Confidence key:** ✅ done · 🟡 partial/needs verification · ⛔ blocked here ·
⬜ not started.

---

## 2. Current state (done)

| Area | Status | Notes |
|---|---|---|
| Plugin load / ME registration | ✅ | `entry.lua`: `load_immediately=true`, VFS mounts, `make_flyable`. `B-2.lua`: explicit country injection loop. |
| Aircraft descriptor | ✅ | Mass, geometry, flight envelope, gear geometry, 4× F118 engine layout. |
| SFM aerodynamics | 🟡 | Plausible flying-wing table, but hand-tuned, not CFD/flight-test derived (§4.6). |
| Engines (SFM) | 🟡 | 4× TurboFan, thrust table ~308 kN total; needs tuning vs. real perf. |
| Crew model (3 seats) | ✅ | Pilot / Mission Commander(WSO) / Relief, all `can_be_playable`. |
| Weapons / pylons | ✅ | Two internal bays, 9 validated CLSIDs each (JDAM family, LGB, JSOW, CBU). |
| UnitPayloads presets | ✅ | 8 ME loadouts. |
| Damage model (logical) | 🟡 | Cell/critical-damage table present; **visual** battle damage needs EDM args (§4.3). |
| Exterior EDM | 🟡 | Real animated model (bay doors, elevons, decelerons, gear). LODs/collision/destroyed model unverified (§4.1). |
| Textures (exterior PBR) | ✅ | Airframe/Mech/Glass diffuse+normal+roughmet. |
| Liveries | 🟡 | 5 squadrons. Duplicated across 3 folder names; only `B-2_Spirit` is loaded (§4.2). |
| Missions | ✅ | QuickStart + Single, weather fields fixed. |
| Input profiles | ✅ | Keyboard/joystick/TrackIR, Reaper/Su-25T labels cleaned. |
| Encyclopedia / GUI art | ✅ | Text + true-PNG icons. |
| **Cockpit interior** | ⛔ | Detailed Blender source built; **not exported to EDM** (§3). |
| Cockpit avionics/systems | ⬜ | Device scripts are stubs (§4.4). |
| Lights | ⬜ | No `lights_data` yet; needs model connectors (§4.5, Appendix A). |
| Sound | ⬜ | No custom sounds (§4.8). |
| Multicrew AI seat-swap | ⛔ | Needs EFM + systems (§4.7). |

---

## 3. Hard blocker: EDM export is Windows-only

DCS's `.EDM` format can only be **written** by Eagle Dynamics' official
`io_scene_edm` Blender addon, whose binary serializer is a compiled **Windows
DLL** (`pyedm_311.pyd` / `pyedm_313.pyd`). On any non-Windows OS the addon
loads an intentional dummy stub and refuses to export with its own error:

```
couldn't proceed edm export because it's python dummy plugin, not native.
```

This was confirmed here by running the real addon headless in Blender 4.0 on
Linux. **Consequence:** every task that produces or edits an `.EDM`
(cockpit interior, exterior LODs, collision/destroyed shells, animation-arg
changes, added light/weapon connectors) must be finished in **Blender on
Windows**. All the *source* and *Lua wiring* for those tasks can be — and here
has been — prepared cross-platform.

Required Windows toolchain:
- Blender **4.2 LTS or 4.5 LTS** (addon's supported versions).
- `io_scene_edm` from <https://github.com/EagleDynamics/Blender-EDM-Exporter>
  (Releases → `edm_tools_blender_plugin.zip` → Preferences → Add-ons →
  Install From Disk).
- DCS **ModelViewer 2** (ships with DCS) to inspect the exported EDM,
  arguments, connectors, and materials before loading in-sim.

---

## 4. Remaining work by area

### 4.1 3D models (exterior) — 🟡  ⛔export
- [ ] Verify/author **LODs** (LOD1/2/3) for performance at range.
- [ ] Verify **collision shell** and **shadow** geometry exist in the EDM.
- [ ] **Destroyed model** (`shape_table_data` second entry + `desrt`) — currently
      `desrt = 'self'`; a dedicated wreck model is better.
- [ ] Confirm **animation arguments** baked into the exterior EDM match DCS
      standards (Appendix B). The model already contains the animated nodes
      (`ar_H_BayDoor_*`, `ar_H_Elevon_*`, `ar_H_Deceleron_*`, `ar_H_NoseGear_*`,
      `ar_H_MainGear_*`, `ar_H_BeaverTail_Trim`), but the arg numbers must line
      up with the FM or surfaces won't move in-sim.
- [ ] Add **weapon-bay connector points** and **light connectors** (Appendix A).

### 4.2 Textures / materials — 🟡  (partly ⛔ for cockpit)
- [ ] **Cockpit UV unwrap + textures** (diffuse/normal/roughmet + emissive for
      MFDs/annunciators). The cockpit source currently has flat materials only.
- [ ] **Damage decal textures** to accompany the damage args (§4.3).
- [ ] De-duplicate liveries: keep `Liveries/B-2_Spirit`, remove the
      byte-identical `Liveries/B-2 Spirit` and `Liveries/B-2A` copies (deletion
      needs a human/CI with delete permission — see §7).
- [ ] Per-squadron unique liveries (currently share the base texture set).

### 4.3 Damage model — 🟡
- The **logical** model exists (`Damage` table in `B-2.lua`): systems fail and
  propagate inboard when cells take damage.
- [ ] **Visual** battle damage requires damage arguments in the EDM (torn skin,
      scorch decals) matched to the cell `args` numbers, plus optional
      `DamageParts` for detachable wings/control surfaces (needs named model
      parts). Add these in Blender, then extend the `Damage`/`DamageParts`
      tables to reference them.

### 4.4 Cockpit avionics / systems (clickable cockpit) — ⬜  (largest effort)
Currently `Cockpit/Scripts/*` are stubs (`devices.lua` = 2 device ids,
`clickabledata.lua`/`materials.lua`/`fonts.lua` empty, `mainpanel_init.lua`
points at the exterior shape). To make the cockpit *functional*:
- [ ] **Device scripts** for each system: electrical, hydraulics, fuel, 4×
      engine/APU start, flight-control (FBW) page, environmental, and a nav/FMS.
- [ ] **MFD pages** (the B-2 has a glass cockpit — engine/systems, flight,
      stores, nav/mission, threat) rendered via the indicator/page framework
      (see the BGDAM Stage 09 `Cockpit.HUD` sample for the page/indicator
      pattern).
- [ ] **`clickabledata.lua`** entries binding each 3D switch/knob (by model arg)
      to a `command_defs.lua` command (Appendix C). `command_defs.lua` already
      defines the command ids; they need clickable bindings and device handlers.
- [ ] **`mainpanel_init.lua`**: switch `shape_name` to the cockpit EDM
      (Appendix D) and declare panel indicators/controllers.
- [ ] Sensor displays: AN/APQ-181 (LPI SAR) page, DAS/EW page. Note the real
      jet is emission-managed/stealth — model accordingly (§4.9).

### 4.5 Lights — ⬜  (Appendix A ready)
- [ ] Add `lights_data` to `B-2.lua` (nav/position, anticollision beacons,
      landing/taxi, formation/slime). **Requires matching light connectors in
      the EDM** — hence kept out of live code for now (a `lights_data` that
      points at missing connectors risks load errors). Appendix A is ready to
      paste once the connectors exist.

### 4.6 Flight model — 🟡  (decision point)
- Current SFM is adequate for an FC3-style flyable and is internally consistent.
- [ ] **Tune** the aero/engine tables against real B-2 performance (service
      ceiling 50k ft, ~Mach 0.95, range ~6,000 nm, MTOW 170,600 kg) — the
      current tables are plausible placeholders.
- [ ] **Decision:** stay SFM, or invest in an **AFM/EFM** (external flight-model
      DLL). EFM is a prerequisite for a true systems-driven cockpit and for
      multicrew AI seat-swap (§4.7). EFM is a large C++ effort and is Windows-
      toolchain bound.

### 4.7 Multicrew / AI seat-swap — ⛔ (needs EFM)
- Human multicrew seats are declared (`can_be_playable` on all 3).
- [ ] "AI flies while the client swaps to the weapons seat" (AH-64D/Ka-50/F-14
      style) is **not** an SFM capability — it needs the module's EFM + cockpit-
      systems code to run an AI pilot in the flight seat. Scope this only if the
      EFM path (§4.6) is chosen.

### 4.8 Sound — ⬜
- [ ] Engine (4× F118 turbofan) exterior/interior loops, cockpit ambience,
      switch/click sounds, warning tones (master caution), gear/flap actuators.
      DCS uses `.ogg` banks + a sound descriptor; wire via the sound params.

### 4.9 Sensors / systems realism — 🟡
- [ ] Replace placeholder `Sensors.RADAR = "AN/APG-63"` with the correct
      **AN/APQ-181** designation (must map to an existing DCS sensor entry, or
      be added). Model the LPI/stealth behaviour: minimal RF emissions, passive
      **AN/APR-50 / ZSR-63 DAS** for threat warning rather than an active radar
      lock game.
- [ ] RWR/DAS display + `RWR` sensor tuned for a low-observable platform.

### 4.10 Weapons realism — 🟡 (DCS content limits)
- [ ] Model the **full rotary launcher**: up to 16× GBU-31 (8/bay) or 80× GBU-38
      on the Smart Bomb Rack — needs 8 stations/bay with model connectors.
- [ ] **Not available in DCS** (document as out of scope unless added by ED):
      B61-12 / B83 nuclear, GBU-57 MOP, AGM-158 JASSM. Current set uses only
      real, in-game stores.

---

## 5. Suggested execution order

1. **Cockpit EDM export (Windows)** from the provided source → wire
   `mainpanel_init.lua` (Appendix D). Unblocks a visible cockpit. _(small,
   unblocks everything visual)_
2. **Animation-arg verification** on exterior + cockpit in ModelViewer
   (Appendix B). _(small, high impact)_
3. **Lights** (Appendix A) once connectors are added. _(small)_
4. **Cockpit textures/UVs**. _(medium)_
5. **Clickable cockpit + device scripts + MFD pages** (§4.4). _(large)_
6. **Flight-model tuning**, then the **SFM-vs-EFM decision** (§4.6). _(large)_
7. **Sound**, **damage visuals**, **per-squadron liveries**, **full rotary
   launcher**. _(medium each)_
8. **EFM + multicrew AI** only if chosen. _(very large)_

---

## 6. Testing checklist (needs Windows DCS + `dcs.log`)

- [ ] Mod loads with no `dcs.log` ERROR/ALERT; appears in ME under USA.
- [ ] Spawns on runway and airborne (both mission types) without crash.
- [ ] External model: gear, bay doors, elevons, decelerons animate.
- [ ] Cockpit view shows the interior EDM (post-export), correct eye point.
- [ ] All 8 payload presets load; weapons release.
- [ ] Damage: systems degrade under fire; no script errors.
- [ ] Multiplayer: seats selectable; confirm real multicrew behaviour.
- [ ] Lights toggle (post-connectors).

> The most valuable single artifact for the next iteration is a **`dcs.log`**
> from loading and flying this build in DCS on Windows — it surfaces runtime-
> only errors that neither Lua syntax checks nor headless Blender can catch.

---

## 7. What can vs. cannot be done from this environment

**Can (and has been) done here:** all Lua (descriptor, weapons, damage, crew,
input, missions), cockpit **mesh source** in Blender (headless, verified with
renders), validated weapon/data lookups, and documentation.

**Cannot be done here:**
- **`.EDM` binary export** — Windows-only vendor DLL (§3).
- **In-sim testing / `dcs.log`** — needs DCS on Windows.
- **Large-scale texture painting / UV art** — needs an artist + image tools.
- **EFM (C++ flight-model DLL)** — Windows build toolchain + ED SDK.
- **Deleting tracked files** (e.g. duplicate livery folders) — blocked by this
  environment's safety policy; a human or CI with delete rights must do it, e.g.
  `git rm -r "B-2 Spirit/Liveries/B-2 Spirit" "B-2 Spirit/Liveries/B-2A" "B-2 Spirit/Input/B-2_Spirit"`.

---

## Appendix A — `lights_data` (paste into `B-2.lua` once EDM has the connectors)

Requires these connectors in the EDM: `BEACON_TOP`, `BEACON_BOTTOM`,
`NAV_LEFT`, `NAV_RIGHT`, `NAV_TAIL`, `LANDING_L`, `LANDING_R`, `FORM_L`,
`FORM_R`. Light animation args (190–209) follow the DCS convention used by the
BGDAM reference.

```lua
lights_data = {
    typename = "collection",
    lights = {
        [1] = { typename = "collection", lights = { -- anticollision beacons (red)
            {typename="natostrobelight", connector="BEACON_TOP",    argument_1=198, period=1.2, phase_shift=0},
            {typename="natostrobelight", connector="BEACON_BOTTOM", argument_1=199, period=1.2, phase_shift=0.6},
        }},
        [2] = { typename = "collection", lights = { -- landing / taxi
            {typename="spotlight", connector="LANDING_L", argument=208, dir_correction={elevation=math.rad(-2)}},
            {typename="spotlight", connector="LANDING_R", argument=208, dir_correction={elevation=math.rad(-2)}},
        }},
        [3] = { typename = "collection", lights = { -- navigation / position
            {typename="omnilight", connector="NAV_LEFT",  color={0.99,0.11,0.30}, argument=190},
            {typename="omnilight", connector="NAV_RIGHT", color={0.00,0.89,0.60}, argument=191},
            {typename="omnilight", connector="NAV_TAIL",  color={1.00,1.00,1.00}, argument=192},
        }},
        [4] = { typename = "collection", lights = { -- formation / slime
            {typename="omnilight", connector="FORM_L", color={0.4,0.9,0.7}, argument=200},
            {typename="omnilight", connector="FORM_R", color={0.4,0.9,0.7}, argument=201},
        }},
    }
}
```

## Appendix B — Animation argument map (verify in ModelViewer)

The exterior EDM already contains these animated nodes; confirm each is bound to
the DCS-standard argument so the flight model drives it. **Treat the numbers as
the target convention and verify against the arg actually baked into the EDM and
against the current DCS `_Common` set — re-assign in Blender if they differ.**

| Function | EDM node(s) | DCS arg (verify) |
|---|---|---|
| Landing gear (retract) | `ar_H_NoseGear_Strut`, `ar_H_MainGear_L/R` | 0 |
| Nose gear door | `ar_H_NoseGear_Door`, `ar_H_NoseGear_BayDoor` | 1 / 2 |
| Ailerons (roll, via elevons) | `ar_H_Elevon_L_Out`, `ar_H_Elevon_R_Out` | 15 |
| Elevator (pitch, via elevons) | `ar_H_Elevon_R_In` (+ paired) | 16 |
| Rudder (yaw, via decelerons) | `ar_H_Deceleron_L`, `ar_H_Deceleron_R` | 17 |
| Airbrake (split decelerons open) | `ar_H_Deceleron_L/R` (2nd channel) | 21 |
| Weapon bay doors | `ar_H_BayDoor_L_Outer/Inner`, `ar_H_BayDoor_R_Outer/Inner` | 86 / 87 (matches `Pylons`) |
| Trim (beavertail / GLAS) | `ar_H_BeaverTail_Trim` | 200-range (custom) |
| Canopy | (add node) | 38 |

## Appendix C — clickable binding template (`clickabledata.lua`)

`command_defs.lua` already defines the command ids used below. Each clickable
needs the matching **model argument** (from the cockpit EDM) as `arg`.

```lua
local cmd = dofile(LockOn_Options.script_path.."command_defs.lua")
elements = {}
-- Example: landing-gear lever (model arg 300 on the cockpit EDM)
elements["PNT_GEAR_LEVER"] = default_2_position_tumb(
    devices.WEAPON_SYSTEM,      -- owning device
    cmd.Button.LandingGearToggle,
    300,                        -- cockpit EDM argument for the lever
    0.0)                        -- animation speed / arg step
-- Repeat per switch: master caution reset, parking brake, canopy,
-- engine start 1-4, APU, flaps up/down (all ids already in command_defs.lua).
```

## Appendix D — point the cockpit view at the exported EDM

Once `Shapes/B-2_Spirit_Cockpit.EDM` exists, edit
`Cockpit/Scripts/mainpanel_init.lua`:

```lua
shape_name  = "B-2_Spirit_Cockpit"   -- was "B-2_Spirit" (exterior-only shell)
is_internal = true                   -- true when using a dedicated interior EDM
```

and confirm `entry.lua` mounts the cockpit shape path (the `Shapes/` mount
already covers it if the EDM is placed there).

## Appendix E — regenerating the cockpit source

The cockpit is procedurally built and reproducible cross-platform:
`Shapes/Cockpit_Source/build_cockpit.py` (run headless in Blender) rebuilds the
`.blend`/`.fbx`; `render_check.py` produces the verification renders. See
`Shapes/Cockpit_Source/README.md` for coordinate conventions and the
export-on-Windows steps.
