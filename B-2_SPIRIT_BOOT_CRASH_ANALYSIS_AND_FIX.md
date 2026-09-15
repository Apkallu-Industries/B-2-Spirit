# B-2 Spirit — Boot Crash Root Cause Analysis & Resolution Guide

**Incident Date/Time**: 2026-09-14 23:19 UTC (00:19 Local)  
**Target Environment**: DCS World 2.9.29.27468 (Multi-Threaded)  
**Mod Path**: `C:\Users\danym\Saved Games\DCS\Mods\aircraft\B-2_Spirit`  

---

## 1. The Exact Failure Symptom

During DCS World startup, the game process aborted after ~5 seconds with an engine-level Lua alert:

```text
2026-09-14 23:19:14.339 ALERT   Dispatcher (Main): Error running db_scan: [string "./Scripts/Database/db_main.lua"]:37: bad argument #5 to 'format' (number expected, got string)
2026-09-14 23:19:15.399 INFO    APP (Main): application shutdown
```

---

## 2. Root Cause Analysis

### A. Root Cause #1: String Literal in Loadout Attribute Tuple (`"Redacted"`)
* **Files**:
  * `Weapons/B2_Heavy_Ordnance.lua` (Line 110)
  * `OrdnancePersonalization/adapters/B2.lua` (Line 29)
* **The Defect**:
  ```lua
  attribute = {4, 5, 36, "Redacted"},
  ```
* **Engine Call Stack**:
  1. During early boot, the Dispatcher invokes `db_scan` in `Scripts/Database/db_main.lua`.
  2. `db_scan` loops over all declared aircraft and weapon loadouts.
  3. It formats the weapon 4-tuple:
     ```lua
     string.format("%d.%d.%d.%d", attr[1], attr[2], attr[3], attr[4])
     ```
  4. In Lua, argument #1 to `string.format` is the format string, #2 is `attr[1]`, #3 is `attr[2]`, #4 is `attr[3]`, and **argument #5 is `attr[4]`**.
  5. Because `attr[4]` was the string `"Redacted"` rather than an integer, Lua aborted with:
     `bad argument #5 to 'format' (number expected, got string)`.

### B. Root Cause #2: Archive Collision (`B-2 Spirit.zip`)
* **Location**: `C:\Users\danym\Saved Games\DCS\Mods\aircraft\B-2 Spirit.zip` (76 MB)
* **The Defect**: DCS VFS mounts `.zip` archives placed in `Mods/aircraft/`. Inside this archive was an older `B-2.lua` containing:
  ```lua
  attribute = {wsType_Air, wsType_Airplane, wsType_Bomber, WSTYPE_PLACEHOLDER, ...}
  ```
  `wsType_Bomber` does **not exist** in DCS `wsTypes.lua` (DCS uses `wsType_Battleplane` or `wsType_F_Bomber`). In Lua, undefined globals evaluate to `nil`, which displaced the table indices and triggered the identical `string.format` failure.

### C. Root Cause #3: Invalid Early Binary Hook
* **Location**: `entry.lua` (Line 18)
* **The Defect**: `load_immediately = true` was declared without a corresponding compiled C++ DLL (`binaries = { ... }`). This flag is reserved for modules linking native binaries.

---

## 3. Corrective Actions Applied

| Component | Defect | Corrective Action | Status |
|---|---|---|---|
| `B2_Heavy_Ordnance.lua` | `attribute = {4, 5, 36, "Redacted"}` | Replaced with `{4, 5, 36, WSTYPE_PLACEHOLDER}` | **FIXED** |
| `adapters/B2.lua` | `attribute = {4, 5, 36, "Redacted"}` | Replaced with `{4, 5, 36, WSTYPE_PLACEHOLDER}` | **FIXED** |
| `entry.lua` | `load_immediately = true` | Removed flag; added diagnostic logger | **FIXED** |
| Saved Games Archives | `B-2 Spirit.zip` collision | Moved to `Saved Games\DCS\_MOD_ZIP_ARCHIVES\` | **ISOLATED** |
| Saved Games Backups | `_B-2_Spirit_CONFLICT_BACKUP` | Moved to `Saved Games\DCS\_MOD_ZIP_ARCHIVES\` | **ISOLATED** |

---

## 4. Verification with DCS Native Lua Runtime (`luae.exe`)

We executed the complete registration chain directly through DCS World's internal engine binary:
`D:\Eagle Dynamics\DCS World\bin-mt\luae.exe`

```text
--- EXECUTING entry.lua via DCS luae.exe ---
>>> [B-2 Spirit] Loading entry.lua...
MOCK: declare_plugin -> B-2_Spirit
MOCK: make_flyable -> B-2_Spirit
MOCK: declare_weapon -> GBU-43_MOAB
MOCK: declare_loadout -> {GBU-43_MOAB} (format: 4.5.36.99999) -> PASS
MOCK: declare_loadout -> {GBU_31_SLOT1} (format: 4.5.36.99999) -> PASS
MOCK: declare_loadout -> {GBU_31_SLOT2} (format: 4.5.36.99999) -> PASS
>>> [B-2 Spirit] Executing B-2.lua...
MOCK: add_aircraft -> B-2_Spirit (format: 1.1.1.99999) -> PASS
>>> [B-2 Spirit] add_aircraft(B_2_Spirit) called successfully.
MOCK: make_view_settings -> B-2_Spirit
MOCK: plugin_done
--- ALL COMPLETED CLEANLY WITH ZERO ERRORS ---
```

---

## 5. Next Steps for Launch
1. Launch DCS World normally via your desktop shortcut or updater.
2. DCS should boot directly to the main menu without the `db_scan` alert.
3. Select **Mission** -> **`B-2_Spirit_Isolation_Test.miz`** -> click **Fly**.
