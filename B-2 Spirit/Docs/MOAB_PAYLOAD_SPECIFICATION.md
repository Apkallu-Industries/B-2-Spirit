# B-2 Spirit — GBU-43/B MOAB Heavy Ordnance & Personal Statement Specification

**Apkallu Industries • Autonomous Drone Asset Pack (ADAP)**  
*Document Version:* 1.0.0  
*Platform:* Northrop Grumman B-2 Spirit Stealth Strategic Bomber (Flyable DCS Mod)  
*Ordnance Designation:* GBU-43/B Massive Ordnance Air Blast (MOAB)  
*Assigned Unit:* 13th Bomb Squadron "Grim Reapers", 509th Bomb Wing, Whiteman AFB  

---

## 1. Executive Summary

The **GBU-43/B MOAB (Massive Ordnance Air Blast)** is a premier 21,600 lb (9,798 kg) precision-guided heavy thermobaric blast weapon. Through the ADAP engineering pipeline, the MOAB has been integrated into the B-2 Spirit's internal rotary bays, offering players unprecedented bunker-busting and area-denial blast capability in DCS World.

Every weapon deployed in this package is rendered as an individualized "personal statement," featuring authentic military hand-inscribed marker-pen graffiti, dedicated 3D EDM shapes compiled in Blender 4.2 LTS, realistic explosive blast mechanics, and an interactive in-cockpit achievement broadcast.

---

## 2. Munition Ballistics & Blast Physics

| Parameter | Value | Engineering Notes |
|:---|:---|:---|
| **Total Munition Mass** | `9,797.59 kg` (21,600 lbs) | Fully loaded store weight |
| **Explosive Filler** | `8,482.17 kg` (18,700 lbs) | Cast H-6 high explosive (1.35x TNT relative effectiveness) |
| **TNT Blast Equivalence** | **~11.45 Tons TNT** | Overpressure impulse equivalent to tactical yield |
| **Transversal Blast Radius**| `400.0 meters` | Annihilation envelope in DCS damage model |
| **Concrete Demolition Factor** | `8.0` / `6.0` / `4.0` | Heavy reinforced concrete / hardened bunker penetration |
| **Physical Dimensions** | Length: 9.18m (30.1 ft) • Diameter: 1.03m (40.5 in) | Ogive nose, cylindrical body, 4 cruciform grid fins |
| **Guidance Package** | GPS / Inertial Navigation System (INS) | High-altitude precision coordinate glide |
| **Release Parameters** | Min Alt: 1,500m (4,920 ft) • Max Alt: 15,000m (49,200 ft) | Optimized for high-altitude B-2 stealth ingress |

---

## 3. Personalized Marker-Pen Graffiti Variants

In combat aviation history, USAF weapons loaders and aircrew personalize heavy ordnance with hand-written chalk and felt-tip marker messages prior to combat sorties. Five distinct variants have been produced, each with a dedicated 3D model and texture:

| Variant ID | CLSID | Inscribed Marker-Pen Message | 3D EDM Model |
|:---|:---|:---|:---|
| **1. Standard Reaper** | `{GBU-43_MOAB}` | *"Signed by the Grim Reapers — Reaper's Harvest"*<br>Whiteman AFB • 13th BS | `GBU-43_MOAB.EDM` |
| **2. "Eat Shit!"** | `{GBU-43_MOAB_EATSHIT}` | *"Eat Shit!"*<br>— 13th Bomb Squadron Whiteman AFB | `GBU-43_MOAB_EatShit.EDM` |
| **3. "Enjoy!"** | `{GBU-43_MOAB_ENJOY}` | *"Enjoy! Direct Airmail Delivery"*<br>— Courtesy of 509th BW | `GBU-43_MOAB_Enjoy.EDM` |
| **4. "Present from USA"** | `{GBU-43_MOAB_PRESENT}` | *"Present from the USA ★"*<br>Special Delivery via B-2 Spirit • 13th BS | `GBU-43_MOAB_PresentUSA.EDM` |
| **5. "New Toy"** | `{GBU-43_MOAB_NEWTOY}` | *"Hope you like our new toy! (USAF)"*<br>21,600 lbs of Pure Whiteman Love | `GBU-43_MOAB_NewToy.EDM` |
| **6. Custom Inscription** | `{GBU-43_MOAB_CUSTOM}` | **Any Custom 32-Character Text** typed by the pilot!<br>Bakes dynamically to 3D casing via `tools/set_moab_inscription.bat` | `GBU-43_MOAB_Custom.EDM` |

---

## 4. Mission Editor & Ground Crew Loadout Presets

Located in `UnitPayloads/B-2_Spirit.lua`, the following pre-configured loadouts are selectable in the Mission Editor or via the in-game Ground Crew Rearm / Refuel window (`\ -> F8`):

* **Preset #9:** `13th BS - 2x GBU-43/B MOAB (Reaper's Harvest)`
  * Bay 1: Standard 13th BS Grim Reapers MOAB
  * Bay 2: Standard 13th BS Grim Reapers MOAB
* **Preset #10:** `13th BS - 2x MOAB ('Eat Shit!' + 'Enjoy!')`
  * Bay 1: *"Eat Shit!"* variant
  * Bay 2: *"Enjoy!"* variant
* **Preset #11:** `13th BS - 2x MOAB ('Present from USA' + 'New Toy')`
  * Bay 1: *"Present from the USA ★"* variant
  * Bay 2: *"Hope you like our new toy! (USAF)"* variant
* **Preset #12:** `13th BS - 2x GBU-43/B MOAB (Custom Pilot Inscription)`
  * Bay 1: Custom 32-character pilot inscription
  * Bay 2: Custom 32-character pilot inscription

Pilots may also mix-and-match any MOAB with standard JDAMs, JSOWs, or Paveways.

---

## 5. Live In-Cockpit Achievement: "Personal Statement Delivered"

Implemented in `Cockpit/Scripts/Systems/Weapon_System.lua`, the aircraft weapon system detects when a MOAB is pickled in flight with Master Arm active. The system increments the release count and announces the exact personal statement written on that bomb across the pilot's HUD:

```
🏆 [ACHIEVEMENT UNLOCKED] 'PERSONAL STATEMENT DELIVERED' (Drop #1)
18,700 lb GBU-43/B MOAB Cleared from Internal Bay!
"Eat Shit!" — 13th Bomb Squadron Whiteman AFB
```

Subsequent drops cycle through the personal statement registry, ensuring every weapon delivery is recognized as a personalized combat strike.

---

## 6. Architecture & File Registry

```
B-2 Spirit/
├── Shapes/
│   ├── GBU-43_MOAB.EDM             # Standard 13th BS Grim Reapers EDM
│   ├── GBU-43_MOAB_EatShit.EDM      # "Eat Shit!" graffiti EDM
│   ├── GBU-43_MOAB_Enjoy.EDM        # "Enjoy!" graffiti EDM
│   ├── GBU-43_MOAB_PresentUSA.EDM   # "Present from the USA" graffiti EDM
│   ├── GBU-43_MOAB_NewToy.EDM       # "Hope you like our new toy" graffiti EDM
│   ├── GBU-43_MOAB_GrimReapers.EDM  # Signature Reaper EDM
│   └── GBU-43_MOAB_Custom.EDM       # Dynamic custom inscription EDM
├── Textures/
│   └── Weapons/
│       ├── 13th_BS_Grim_Reapers_Patch.png  # Official squadron patch (4K)
│       ├── MOAB_Grim_Reapers_Casing.png    # Base MIL-SPEC stencil texture
│       ├── MOAB_Casing_EatShit.png         # Marker graffiti texture
│       ├── MOAB_Casing_Enjoy.png           # Marker graffiti texture
│       ├── MOAB_Casing_PresentUSA.png      # Marker graffiti texture
│       ├── MOAB_Casing_NewToy.png          # Marker graffiti texture
│       └── MOAB_Casing_Custom.png          # Dynamic custom inscription texture
├── Weapons/
│   └── B2_Heavy_Ordnance.lua        # DCS weapon & loadout registrations
├── Cockpit/Scripts/Systems/
│   └── Weapon_System.lua            # Pickle detection & achievement announcer
├── UnitPayloads/
│   └── B-2_Spirit.lua               # Presets 9, 10, 11, and 12
└── tools/
    ├── set_moab_inscription.bat     # 1-Click pilot inscription tool
    └── set_moab_inscription.py      # Dynamic font rendering engine
```

---

## 7. Pilot Screenshot Workflow: "My Message on the Bomb"

To capture a screenshot showing your personal inscription on the MOAB in flight:

1. **Step 1: Write Your Inscription**
   * Double-click `tools/set_moab_inscription.bat` (or run `python tools/set_moab_inscription.py "Your Message"`).
   * Type any custom text up to 32 characters (e.g. `"Eat Shit! - From Whiteman"`).
   * The tool automatically renders authentic felt-tip marker handwriting onto the 3D bomb casing texture and updates both the mod repository and live DCS installation in 0.2 seconds.
2. **Step 2: Load the Bomb in DCS**
   * In the Mission Editor or Ground Crew Rearm menu (`\ -> F8`), select:
     `GBU-43/B MOAB (Custom Pilot Inscription)` or Payload Preset #12.
3. **Step 3: Fly & Pickle**
   * Ingress over target area at 15,000–40,000 ft.
   * Open bay doors (`B`), Master Arm `ARM`, and depress the weapon pickle button (`RAlt + Space`).
   * The in-cockpit broadcast will announce:
     `🏆 [ACHIEVEMENT UNLOCKED] 'PERSONAL STATEMENT DELIVERED' (Bay 1 / Drop #1)`
4. **Step 4: Capture the Screenshot**
   * Immediately press **`F6`** (Weapon Tracking View) to follow the released MOAB.
   * Use mouse or numpad to orbit around the bomb casing. The pilot's custom 32-character message, 13th Bomb Squadron "Grim Reapers" patch, and yellow military stenciling are all visible in full 3D!
   * Press **`PrintScreen`** (`SysRq`) to take your screenshot. DCS will save a 4K screenshot in `Saved Games/DCS/Screenshots/`.

