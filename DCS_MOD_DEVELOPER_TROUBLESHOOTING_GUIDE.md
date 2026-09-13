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

## Fault Incident #002: Missing Aircraft in Mission Editor Dropdown (`Can not decipher engine type`)

### 1. Error Signatures in `dcs.log`
```text
2026-09-13 12:47:57.728 ERROR   WORLDGENERAL (Main): Error: Unit [B-2_Spirit]: Can not decipher engine type "Turbofan".
```

### 2. Root Cause Analysis
- DCS World's flight model parser is strictly case-sensitive for the `SFM_Data.engine.type` property.
- The string `"Turbofan"` (with lowercase `f`) is not recognized by the internal engine parser.
- Because DCS cannot determine the thermodynamics model to use, it aborts registration of the aircraft into the world unit database.
- As a consequence, the aircraft never populates into the Mission Editor `TYPE` dropdown for any country.
- In addition, the Mission Editor filters the `TYPE` dropdown based on the group's assigned `TASK`. If the group task is set to `CAS` (Close Air Support) and the aircraft descriptor does not include `aircraft_task(CAS)` in its `Tasks` table, the aircraft is filtered out.

### 3. Resolution
1. Set the engine type to PascalCase `"TurboFan"` (with capital `F`):
   ```lua
   SFM_Data = {
       engine = {
           type = "TurboFan", -- Must be PascalCase "TurboFan"
           ...
       },
   }
   ```
2. Add `aircraft_task(CAS)` and all primary operational tasks to the `Tasks` table in `B-2.lua` so the aircraft remains available regardless of the task filter selected in the Mission Editor.
3. Use a distinctive `DisplayName` (e.g. `_('B-2 Spirit (Flyable)')`) so it displays in yellow as a player-flyable aircraft and avoids conflicts with AI-only mods.

---

## Fault Incident #003: Nil Hole Corruption in `attribute` Tuple

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
attribute = {wsType_Air, wsType_Airplane, wsType_F_Bomber, WSTYPE_PLACEHOLDER, "Strategic bombers", "Refuelable"},
```

---

## Fault Incident #004: Missing Aircraft from Country Dropdown (`country.Units.Planes.Plane`)

### 1. Error Signatures
The mod passes Lua validation, DCS boots without errors, but the aircraft does not appear in the Mission Editor `TYPE` dropdown under USA or any other coalition country.

### 2. Root Cause Analysis
- In DCS World (`MissionEditor/modules/me_aircraft.lua:1056`), the Mission Editor populates available aircraft by iterating directly over:
  ```lua
  aircrafts = country.Units.Planes.Plane
  for _tmp, plane in pairs(aircrafts) do
      local unit = DB.unit_by_type[plane.Name]
      ...
  ```
- While `add_aircraft(self)` is supposed to read `self.Countries = {"USA", ...}`, if third-party modules are loaded after country initialization or if deferred loading occurs, DCS does not automatically append the unit into `country.Units.Planes.Plane`.
- If the unit name is not present in that table, the Mission Editor treats it as belonging to no country and completely hides it from the dropdown.
- Furthermore, if `load_immediately = true` is omitted from `declare_plugin`, the module load sequence can be deferred until after the UI database cache has already completed its scan.

### 3. Resolution
1. Set `load_immediately = true` in `declare_plugin`:
   ```lua
   declare_plugin(self_ID, {
       ...
       load_immediately = true,
   })
   ```
2. In `B-2.lua`, append an explicit country registration loop immediately after `add_aircraft(B_2_Spirit)` to ensure the aircraft is injected into both `country:get("USA").Units.Planes.Plane` and `db.CountriesByName["USA"].Units.Planes.Plane`:
   ```lua
   local countries_to_add = {"USA", "USAF Aggressors", "UK", "France", "Germany", "Italy", "Israel", "Australia", "Canada"}
   for _, c_name in ipairs(countries_to_add) do
       local c = (country and country.get and country:get(c_name)) or (db and db.CountriesByName and db.CountriesByName[c_name])
       if c and c.Units and c.Units.Planes and c.Units.Planes.Plane then
           local found = false
           for _, p in pairs(c.Units.Planes.Plane) do
               if p.Name == "B-2_Spirit" then found = true; break end
           end
           if not found then
               table.insert(c.Units.Planes.Plane, {
                   Name = "B-2_Spirit",
                   in_service = 0,
                   out_of_service = 40000.0,
               })
           end
       end
   end
   ```
3. Initialize `Categories = {}` in the aircraft descriptor to prevent `nil` category lookups during mission briefing generation.
4. Set `image = "FC3.bmp"` in `declare_plugin` to use the standard, built-in FC3 icon sprite for cockpit-modded aircraft.

---

## Fault Incident #005: Pylon Weapon CLSID Syntax Incompatibilities

### 1. Root Cause Analysis
- Using custom or informal weapon identifiers in `Pylons` (e.g., `{GBU31_JDAM}`) causes mission load failures or silent pylon omission if the CLSID is unmapped.
- Official Eagle Dynamics weapon definitions reside in `CoreMods/aircraft/AircraftWeaponPack/`.

### 2. Resolution
Use standard, validated GUIDs or CLSIDs from `JDAM.lua` and `common_bombs.lua`:
- **GBU-31 (2,000 lb JDAM)**: `{ CLSID = "{GBU-31}" }`
- **GBU-38 (500 lb JDAM)**: `{ CLSID = "{GBU-38}" }`
- **GBU-12 (Paveway II LGB)**: `{ CLSID = "{DB769D48-67D7-42ED-A2BE-108D566C8B1E}" }`

---

## Fault Incident #006: Blender 4.2 EDM Material Enum Values

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
| **2** | `B-2.lua` Engine Type | Must be exact case `"TurboFan"` (not `"Turbofan"`). |
| **3** | `B-2.lua` Tasks | Must include `aircraft_task(CAS)` to prevent Mission Editor filter omission. |
| **4** | `entry.lua` Immediate Load | Set `load_immediately = true` in `declare_plugin` so DCS scans it synchronously. |
| **5** | Country Injection | Inject `{ Name = unit_name }` into `country.Units.Planes.Plane` if `add_aircraft` does not auto-bind. |
| **6** | `entry.lua` View Settings | `make_view_settings('UnitName', ...)` matches `aircraft.Name`. |
| **7** | `entry.lua` Flyable Call | `make_flyable('UnitName', ...)` matches `aircraft.Name`. |
| **8** | `B-2.lua` Attributes | Check `Scripts/Database/wsTypes.lua` — never pass unverified globals. |
| **9** | Syntax Verification | Run `D:\Eagle Dynamics\DCS World\bin-mt\luae.exe -e "loadfile('...')"`. |
