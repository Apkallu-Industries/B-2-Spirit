#!/usr/bin/env python3
"""
Ingest Community A-4E-C architecture knowledge into MongoDB DCS Modding DB.
"""

import datetime
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dcs_kb import get_db, init_indexes

def ingest():
    db = get_db()
    init_indexes(db)

    articles = [
        {
            "topic_id": "a4ec_cockpit_3d_sound_hosts",
            "category": "AUDIO_AND_SOUNDS",
            "title": "3D Spatialized Cockpit Sound Host Architecture (A-4E-C)",
            "tags": ["sound", "audio", "create_sound_host", "cockpitsounds", "switch_clicks", "vr", "spatial"],
            "overview": "DCS supports true 3D spatialized audio inside the cockpit by attaching sound hosts to physical coordinates (X, Y, Z), pioneered by Community A-4E-C.",
            "rules": [
                'Create spatial hosts: sndhost = create_sound_host("COCKPIT_CLICKS", "3D", x, y, z).',
                'Register sounds: click_sound = sndhost:create_sound("Aircrafts/A-4E-C/toggleclick_lf").',
                'Play on actuation: Inside SetCommand(command, value) in device scripts, call click_sound:play_once().',
                'Coordinates: +X = forward, +Y = up, +Z = right in cockpit model space.',
                'Distinct sounds per console: Left forward console (throttle/gear), Mid main instrument panel, Right console (radios/electrics).'
            ],
            "gotchas": [
                "Sound files must be mono 44.1kHz 16-bit WAV or OGG for 3D positional attenuation to work properly.",
                "Ensure sound paths are mounted in entry.lua under mount_vfs_sound_path()."
            ],
            "verified_examples": [
                "C:/Users/danym/Saved Games/DCS/Mods/aircraft/A-4E-C/Cockpit/Scripts/cockpitsounds.lua",
                "C:/Users/danym/Saved Games/DCS/Mods/aircraft/A-4E-C/Cockpit/Scripts/sound_class.lua"
            ],
            "updated_at": datetime.datetime.now(datetime.timezone.utc),
            "version": 1
        },
        {
            "topic_id": "a4ec_afcs_autopilot_stab_aug",
            "category": "FLIGHT_MODEL_AND_CONTROL",
            "title": "Fly-by-Wire Stability Augmentation & AFCS (A-4E-C)",
            "tags": ["afcs", "autopilot", "fly_by_wire", "sfm_extender", "stability", "attitude_hold", "heading_hold"],
            "overview": "A-4E-C sfm_extender intercepts raw pilot pitch/roll/rudder axis commands to apply stability dampening, artificial damping, altitude hold, and heading hold.",
            "rules": [
                "Listen to axis commands: dev:listen_command(device_commands.pitch_axis_mod), dev:listen_command(device_commands.roll_axis_mod).",
                "Read aircraft state via sensor_data.getRateOfPitch(), getRateOfRoll(), getPitch(), getRoll(), getBarometricAltitude().",
                "Compute correction delta using PID / proportional gain.",
                "Feed corrected control surface deflection via cockpit animation arguments (args 2001, 2002, 2003) or dispatch_action().",
                "Enables fly-by-wire stealth bomber (B-2) and drone (MQ-9) stability augmentation without requiring external C++ DLL."
            ],
            "gotchas": [
                "Axis inputs are normalized -1.0 to +1.0. Ensure gain multipliers do not exceed aerodynamic authority."
            ],
            "verified_examples": [
                "C:/Users/danym/Saved Games/DCS/Mods/aircraft/A-4E-C/Cockpit/Scripts/Systems/sfm_extender.lua",
                "C:/Users/danym/Saved Games/DCS/Mods/aircraft/A-4E-C/Cockpit/Scripts/Systems/afcs.lua"
            ],
            "updated_at": datetime.datetime.now(datetime.timezone.utc),
            "version": 1
        },
        {
            "topic_id": "a4ec_clickable_switch_patterns",
            "category": "CLICKABLE_COCKPIT",
            "title": "Clickable Elements & Guarded Multi-Position Switches (A-4E-C)",
            "tags": ["clickabledata", "switches", "knobs", "spring_loaded", "circuit_breakers", "tumble"],
            "overview": "Comprehensive clickable definitions for spring-loaded toggle switches, guarded red safety covers, multi-position rotary knobs, and circuit breakers.",
            "rules": [
                "Spring-loaded switches (momentary): use default_springloaded_switch with cyclic return to center 0.",
                "Guarded switches: Parent switch element to safety cover argument. Cover must be opened before switch can actuate.",
                "Circuit breakers: Use default_button or 2-position switch that pops outward on overload.",
                "Rotary knobs: use default_axis_limited or multi-step discrete angle tables."
            ],
            "gotchas": [
                "Clickable collision geometry in 3D model must be simple convex boxes; complex mesh geometry causes erratic cursor clicks."
            ],
            "verified_examples": [
                "C:/Users/danym/Saved Games/DCS/Mods/aircraft/A-4E-C/Cockpit/Scripts/clickabledata.lua",
                "C:/Users/danym/Saved Games/DCS/Mods/aircraft/A-4E-C/Cockpit/Scripts/clickable_defs.lua"
            ],
            "updated_at": datetime.datetime.now(datetime.timezone.utc),
            "version": 1
        }
    ]

    for art in articles:
        db.knowledge_items.update_one({"topic_id": art["topic_id"]}, {"$set": art}, upsert=True)
        print(f"[OK] Ingested: {art['topic_id']}")

    print("\n[OK] All A-4E-C architecture articles ingested into DCS Modding DB.")

if __name__ == "__main__":
    ingest()
