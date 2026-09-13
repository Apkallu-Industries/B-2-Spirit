# B-2 Spirit Stealth Bomber — DCS World Standalone Module

<p align="center">
  <img src="assets/b2_spirit_github_banner.png" alt="B-2 Spirit DCS World Module Banner" width="100%">
</p>

<p align="center">
  <a href="https://github.com/Apkallu-Industries/B-2-Spirit/releases"><img src="https://img.shields.io/badge/Release-v0.0.1v-blue.svg?style=for-the-badge" alt="Release"></a>
  <img src="https://img.shields.io/badge/DCS_World-2.9+-green.svg?style=for-the-badge" alt="DCS World">
  <img src="https://img.shields.io/badge/Unit-509th_Bomb_Wing-darkred.svg?style=for-the-badge" alt="509th Bomb Wing">
  <img src="https://img.shields.io/badge/Motto-Mors_Ab_Alto-gold.svg?style=for-the-badge" alt="Mors Ab Alto">
  <img src="https://img.shields.io/badge/Status-Flyable_Fully_Animated-success.svg?style=for-the-badge" alt="Status">
</p>

---

## 🦅 Overview

The **Northrop Grumman B-2 Spirit** is a premier low-observable, strategic, long-range heavy stealth bomber. This high-fidelity community module brings the iconic "flying wing" to **DCS World**, featuring a calibrated **52.4-meter wingspan**, authentic flight physics, internal rotary weapons bays, custom cockpit views, fully rigged animation channels, and high-resolution 4K PBR stealth materials.

Developed and maintained by **Apkallu Industries** under the *Autonomous Drone Pack* initiative.

---

## ✨ Key Features

- ✈️ **Authentic Airframe Scaling**: Precision 1:1 scale (52.42 m wingspan, 21.0 m length, 5.18 m height) calibrated from engineering data.
- 🎨 **4K PBR Stealth Pipeline**: Custom Diffuse, Normal, and RoughMet maps simulating radar-absorbent material (RAM) coatings and canopy tinting.
- 🕹️ **13 Animated Argument Channels**: Fully rigged flight surfaces, landing gear retraction, and rotary weapons bay doors compiled to native DCS `.EDM`.
- 💣 **Dual Internal Rotary Bays**: Station 1 (Left) and Station 2 (Right) configured for precision-guided munitions (GBU-31/38 JDAM, AGM-154 JSOW, Mk-84, Mk-82, CBU-97/105).
- 💺 **Dual Crew Cockpit Views**: Pilot Seat (Left) and Mission Commander Seat (Right, SnapView 9) with calibrated cockpit eye horizons.
- 🎯 **Instant Action & Missions**: FL350 high-altitude ingress and Senaki-Kolkhi Runway 09 hot start missions with verified weather parameters.
- 🎖️ **Virtual Squadron Roster**: Authentic Whiteman AFB liveries with painted military aircraft decals and low-observable stealth stencils.

---

## 📐 Flight Model & Animation Arguments

All control surfaces and mechanical components are animated according to official DCS argument channel conventions:

| Arg ID | System Component | Deflection / State | Movement Type |
| :--- | :--- | :--- | :--- |
| **0** | **Nose Landing Gear** | `0.0` (Down/Locked) $\leftrightarrow$ `1.0` (Retracted) | Strut retraction & forward bay doors |
| **3** | **Left Main Landing Gear** | `0.0` (Down/Locked) $\leftrightarrow$ `1.0` (Retracted) | Main gear rotation & outer bay door |
| **5** | **Right Main Landing Gear** | `0.0` (Down/Locked) $\leftrightarrow$ `1.0` (Retracted) | Main gear rotation & outer bay door |
| **11** | **Left Outboard Elevon** | `-1.0` (Down $-25^\circ$) $\leftrightarrow$ `+1.0` (Up $+25^\circ$) | Pitch & Roll |
| **12** | **Right Outboard Elevon** | `-1.0` (Down $-25^\circ$) $\leftrightarrow$ `+1.0` (Up $+25^\circ$) | Pitch & Roll |
| **13** | **Left Split-Rudder Deceleron** | `0.0` (Closed) $\leftrightarrow$ `+1.0` (Split $+35^\circ$) | Yaw control & drag airbrake |
| **14** | **Right Split-Rudder Deceleron**| `0.0` (Closed) $\leftrightarrow$ `+1.0` (Split $+35^\circ$) | Yaw control & drag airbrake |
| **16** | **Inboard Elevons** | `-1.0` (Down $-25^\circ$) $\leftrightarrow$ `+1.0` (Up $+25^\circ$) | Pitch trim & roll augmentation |
| **17** | **Beaver-Tail Trim Flap** | `-1.0` (Down $-15^\circ$) $\leftrightarrow$ `+1.0` (Up $+15^\circ$) | Center pitch trim & gust alleviation |
| **86** | **Left Weapons Bay Doors** | `0.0` (Closed) $\leftrightarrow$ `+1.0` (Open $90^\circ$) | Dual clamshell rotary bay doors |
| **87** | **Right Weapons Bay Doors** | `0.0` (Closed) $\leftrightarrow$ `+1.0` (Open $90^\circ$) | Dual clamshell rotary bay doors |

---

## 🎨 Squadron Liveries & Markings

<p align="center">
  <img src="assets/squadrons/b2_509th_painted_decal_color.png" alt="509th Bomb Wing Heritage Decal" width="280">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/squadrons/b2_509th_subdued_stencil.png" alt="509th Subdued Tactical Stencil" width="280">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="B-2 Spirit/Theme/squadron_patch_hq.png" alt="Mission Award Patch" width="280">
</p>

The module includes four operational squadron paint schemes selectable from the DCS Mission Editor and in-game rearming menu:

1. **`USAF 509th Bomb Wing (Whiteman AFB)`**: Wing Flagship Command with full-color heritage crest on nose gear door and crew hatch.
2. **`13th Bomb Squadron 'Grim Reapers'`**: Combat strike line jet with subdued low-observable tactical markings.
3. **`393d Bomb Squadron 'Tigers'`**: Global strike mission jet with authentic squadron tail markings.
4. **`325th Weapons Squadron`**: USAF Weapons School operational tactics evaluation scheme.

---

## 🚀 Installation

### Option 1: Automatic Sync via PowerShell
```powershell
# Run from repository root:
robocopy ".\B-2 Spirit" "$HOME\Saved Games\DCS\Mods\aircraft\B-2 Spirit" /MIR /FFT /Z /W:5 /R:2 /XD .git
```
*(For DCS OpenBeta, target `$HOME\Saved Games\DCS.openbeta\Mods\aircraft\B-2 Spirit`)*

### Option 2: Manual Drag & Drop
1. Copy the **`B-2 Spirit`** folder.
2. Paste it into your DCS Saved Games aircraft mods directory:
   ```text
   C:\Users\<YourUsername>\Saved Games\DCS\Mods\aircraft\B-2 Spirit\
   ```
3. Restart DCS World.

---

## 🎮 Included Missions

- **`B-2_Spirit_Free_Flight.miz`**: Dual client slots featuring a high-altitude ingress over the Black Sea at FL350 (450 kts) and a runway-hot takeoff slot on Senaki-Kolkhi Runway 09.
- **`B-2_Spirit_High_Altitude.miz`**: Direct combat ingress at 35,000 ft with navigation waypoints.
- **`B-2_Spirit_Runway_Hot.miz`**: Scramble takeoff ready at the active runway hold line.

---

## 📂 Repository Structure

```text
B-2-Spirit/
├── B-2 Spirit/                       <-- Core DCS World Mod Root
│   ├── Cockpit/                      <-- Cockpit views and instrument configurations
│   ├── Encyclopedia/                 <-- In-game encyclopedia entry & high-res profile
│   ├── Input/B-2 Spirit/             <-- Keyboard, mouse, joystick, & Xbox controller diffs
│   ├── Liveries/B-2 Spirit/          <-- 509th BW, 13th BS, 393d BS, and 325th WPS liveries
│   ├── Missions/                     <-- QuickStart & Single Player .miz files
│   ├── Shapes/B-2_Spirit.EDM         <-- Compiled DCS 3D binary with 13 animated channels
│   ├── Textures/                     <-- 4K PBR texture sets (Diffuse, Normal, RoughMet)
│   ├── Theme/                        <-- UI backgrounds, transparent award badges, & icons
│   ├── B-2.lua                       <-- Aircraft aerodynamics, engine, sensors, & payload
│   ├── entry.lua                     <-- Module registration & DCS plugin hooks
│   └── Views.lua                     <-- Pilot & Mission Commander 6DOF camera horizons
├── assets/                           <-- High-res stencils, painted decals, & banners
├── source/                           <-- Raw Blender rigging scripts & 3D models
└── README.md                         <-- Project Documentation
```

---

## ⚖️ License & Attribution
Developed for the DCS World flight simulation community by **Apkallu Industries**.  
*For non-commercial flight simulation use only.*
