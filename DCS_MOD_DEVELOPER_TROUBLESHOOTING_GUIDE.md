# DCS World Mod Development: Fault & Resolution Guide

## Document Overview
This document serves as an engineering post-mortem and developer reference guide for troubleshooting critical crashes, engine assertions, and database errors during DCS World 3rd-party aircraft mod development.

---

## Fault Incident #001: Fatal `db_scan` Assertion Crash on Startup

### 1. Error Signatures in `dcs.log`
```text
2026-09-13 12:43:39.393 ERROR   Scripting (Main): unit B-2 Spirit not found
2026-09-13 12:43:39.468 ALERT   Dispatcher (Main): Error running db_scan: [string "./Scripts/Database/db_main.lua"]:393: assertion failed!
2026-09-13 12:43:39.990 INFO    APP (Main): application shutdown
```

### 2. Root Cause Analysis
- During DCS World engine initialization, the `Dispatcher` runs `db_scan` (located inside `./Scripts/Database/db_main.lua`).
- `db_scan` parses every installed module's `entry.lua` manifest, specifically examining the `LogBook` table:
  ```lua
  -- Faulty implementation in entry.lua
  LogBook = {
      {
          name = _("B-2_Spirit"),
          type = "B-2_Spirit",
      },
      {
          name = _("B-2 Spirit"),
          type = "B-2 Spirit", -- FAULT: No unit registered with Name = 'B-2 Spirit'
      },
  }
  ```
- In the aircraft descriptor (`B-2.lua`), the unit was registered as:
  ```lua
  B_2_Spirit = {
      Name = 'B-2_Spirit', -- Key in db.Units.Planes.Plane
      ...
  }
  add_aircraft(B_2_Spirit)
  ```
- When `db_scan` evaluated the second LogBook entry (`type = "B-2 Spirit"`), it performed a table index lookup `db.Units.Planes.Plane["B-2 Spirit"]`. Because the key with a space did not exist in the database, the lookup returned `nil`.
- DCS immediately logged `ERROR Scripting (Main): unit B-2 Spirit not found`.
- In `db_main.lua:393`, an internal assertion `assert(unit ~= nil)` evaluated to `false`, throwing a fatal Lua error that triggered immediate `application shutdown`.

### 3. Resolution
In `entry.lua`, ensure that the `type` field in `LogBook` strictly matches the unit's internal `Name` string defined in the aircraft descriptor:
```lua
-- Corrected entry.lua
LogBook = {
    {
        name = _("B-2 Spirit"),
        type = "B-2_Spirit", -- Matches Name = 'B-2_Spirit' exactly
    },
}
```

---

## Fault Incident #002: Nil Hole Corruption in `attribute` Tuple

### 1. Root Cause Analysis
- In `B-2.lua`, the classification attribute was initially defined as:
  ```lua
  attribute = {wsType_Air, wsType_Airplane, wsType_Bomber, WSTYPE_PLACEHOLDER, "Strategic bombers"}
  ```
- Checking `Scripts/Database/wsTypes.lua` reveals that **`wsType_Bomber` does not exist in the DCS World type system**:
  ```lua
  -- wsTypes.lua Level 3 Aircraft Objects:
  wsType_Fighter     = 1
  wsType_F_Bomber    = 2  -- Fighter-Bombers & Tactical Strike
  wsType_Intercepter = 3
  wsType_Intruder    = 4
  wsType_Cruiser     = 5  -- Heavy / Strategic Bombers
  ```
- Referencing undefined `wsType_Bomber` in Lua evaluates silently to `nil`. In Lua table arrays, inserting a `nil` creates an array hole:
  `{1, 1, nil, WSTYPE_PLACEHOLDER, ...}`.
- This corrupts type indexing and classification queries inside `db_countries.lua`.

### 2. Resolution
Always use verified `wsTypes.lua` constants. For heavy and tactical bombers, use `wsType_F_Bomber`:
```lua
attribute = {wsType_Air, wsType_Airplane, wsType_F_Bomber, WSTYPE_PLACEHOLDER, "Strategic bombers", "Bombers"},
```

---

## Fault Incident #003: Pylon Weapon CLSID Syntax Incompatibilities

### 1. Root Cause Analysis
- Using custom or informal weapon identifiers in `Pylons` (e.g., `{GBU31_JDAM}`) causes mission load failures or silent pylon omission if the CLSID is unmapped.
- Official Eagle Dynamics weapon definitions reside in `CoreMods/aircraft/AircraftWeaponPack/`.

### 2. Resolution
Use standard, validated GUIDs or CLSIDs from `JDAM.lua` and `common_bombs.lua`:
- **GBU-31 (2,000 lb JDAM)**: `{ CLSID = "{GBU-31}" }`
- **GBU-38 (500 lb JDAM)**: `{ CLSID = "{GBU-38}" }`
- **GBU-12 (Paveway II LGB)**: `{ CLSID = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}" }`

---

## Fault Incident #004: Blender 4.2 EDM Material Enum Values

### 1. Root Cause Analysis
- When scripting headless EDM export using the Blender `io_scene_edm` addon, assigning integer values (e.g., `0` or `1`) to shader properties triggers a Python RNA Enum TypeError:
  ```text
  TypeError: bpy_struct: item.attr = val: enum "0" not found in ('OPAQUE', 'ALPHA_BLENDING', 'Z_TEST', 'SUM_BLENDING', 'SUM_BLENDING_SI', 'SHADOWED_BLENDING')
  ```

### 2. Resolution
Always assign the explicit string constants:
```python
# Opaque Airframe Surface
edm_node.transparency = 'OPAQUE'
edm_node.shadow_caster = 'SHADOW_CASTER_YES'

# Transparent Glass / Canopy
edm_node.transparency = 'ALPHA_BLENDING'
edm_node.shadow_caster = 'SHADOW_CASTER_NO'
```

---

## Developer Quick Reference Checklist

| Step | Check Item | Critical Requirement |
|---|---|---|
| **1** | `entry.lua` LogBook | `LogBook[i].type == aircraft.Name` character-for-character. |
| **2** | `entry.lua` View Settings | `make_view_settings('UnitName', ...)` matches `aircraft.Name`. |
| **3** | `entry.lua` Flyable Call | `make_flyable('UnitName', ...)` matches `aircraft.Name`. |
| **4** | `B-2.lua` Attributes | Check `Scripts/Database/wsTypes.lua` — never pass unverified globals. |
| **5** | Syntax Verification | Run `D:\Eagle Dynamics\DCS World\bin-mt\luae.exe -e "loadfile('...')"`. |
