"""Phase 15: Generic DCS Ordnance Personalization Framework — Multi-Weapon PBR Compositor.
Generates complete physical PBR texture sets (Diffuse, RoughMet, Normal) for both:
1. GBU-43/B MOAB (21,600 lb Heavy Blast Ordnance)
2. GBU-31(V)1/B & GBU-31(V)3/B JDAM (2,000 lb GPS/INS Guided Munition)

Supports delivery-system-aware dual-slot configuration, physical mediums
(Marker, Chalk, Grease, Stencil), procedural thermal ablation coating, and weathering.
"""

import json
import math
import os
import random
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(r"c:\Dev\AutonomousDronePack\B-2 Spirit")
DEV_TEX_DIR = HERE / "B-2 Spirit" / "Textures" / "Weapons"
PATCH_DIR = DEV_TEX_DIR
SAVED_GAMES_TEX_DIR = Path(r"C:\Users\danym\Saved Games\DCS\Mods\aircraft\B-2_Spirit\Textures\Weapons")
CUSTOM_JSON_PATH = HERE / "tools" / "ordnance_customizer" / "customization.json"

# Import MOAB compositor logic
from moab_pbr_compositor import (
    COLOR_OD_BASE, COLOR_OD_PANEL, COLOR_YELLOW_BAND,
    COLOR_STENCIL_BLACK, COLOR_BARE_ALUMINUM,
    get_fonts, apply_physical_inscription, apply_weathering
)

# GBU-31 Colors
COLOR_JDAM_GRAY_TAIL = (78, 85, 88)     # FS 36118 Tactical Gray Guidance Kit
COLOR_JDAM_GPS_RADOME = (210, 215, 210)  # White/Off-white GPS dome
COLOR_THERMAL_ABLATION = (60, 68, 50)   # Textured rough thermal coating


def build_gbu31_base_maps(w=2048, h=2048):
    """Builds base diffuse, roughmet, and normal maps for GBU-31 JDAM."""
    # 1. Diffuse: Forward 65% is Olive Drab Bomb Body, Rear 35% is Gray Guidance Kit
    diff = Image.new("RGBA", (w, h), (*COLOR_OD_BASE, 255))
    draw_diff = ImageDraw.Draw(diff)

    # 2. RoughMet: Body has thermal coating (Roughness G=210), Tail is smooth metal/paint (G=145)
    rm = Image.new("RGBA", (w, h), (255, 205, 0, 255))
    draw_rm = ImageDraw.Draw(rm)

    # 3. Normal: Flat with strakes and nose plug relief
    norm = Image.new("RGBA", (w, h), (128, 128, 255, 255))
    draw_norm = ImageDraw.Draw(norm)

    # Guidance Kit Tail Section (Y from 0.68 * h to h)
    tail_top = int(h * 0.68)
    draw_diff.rectangle([0, tail_top, w, h], fill=(*COLOR_JDAM_GRAY_TAIL, 255))
    draw_rm.rectangle([0, tail_top, w, h], fill=(255, 145, 0, 255))
    # Bevel junction
    draw_norm.line([(0, tail_top), (w, tail_top)], fill=(128, 150, 255, 255), width=3)

    # Yellow High-Explosive Identification Band near Nose (Y: 0.12 * h to 0.16 * h)
    band_top = int(h * 0.12)
    band_bot = int(h * 0.16)
    draw_diff.rectangle([0, band_top, w, band_bot], fill=(*COLOR_YELLOW_BAND, 255))
    draw_rm.rectangle([0, band_top, w, band_bot], fill=(255, 160, 0, 255))
    draw_norm.line([(0, band_top), (w, band_top)], fill=(128, 145, 255, 255), width=2)
    draw_norm.line([(0, band_bot), (w, band_bot)], fill=(128, 110, 255, 255), width=2)

    # GPS Radome Disc on tail
    radome_r = int(w * 0.04)
    rx, ry = int(w * 0.5), int(h * 0.85)
    draw_diff.ellipse([rx - radome_r, ry - radome_r, rx + radome_r, ry + radome_r], fill=(*COLOR_JDAM_GPS_RADOME, 255))
    draw_rm.ellipse([rx - radome_r, ry - radome_r, rx + radome_r, ry + radome_r], fill=(255, 100, 0, 255))

    return diff, rm, norm


def apply_gbu31_stencils(diff, rm, norm, fonts, slot_cfg, mission_cfg):
    """Applies authentic USAF GBU-31 JDAM stenciling and 13th BS Grim Reapers patch."""
    w, h = diff.size
    draw_diff = ImageDraw.Draw(diff)
    draw_rm = ImageDraw.Draw(rm)
    font_mono = ImageFont.truetype(fonts["mono"], 26)
    font_clean = ImageFont.truetype(fonts["clean"], 34)

    serial = slot_cfg.get("serial", "JDAM-2026-031")
    callsign = mission_cfg.get("callsign", "GRIM 21")
    pilot = mission_cfg.get("pilot_name", "Capt Mitchell")
    date_str = mission_cfg.get("date", "14 SEP 2026")

    # Stencils on Port & Starboard body
    for qx, qy in [(int(w * 0.65), int(h * 0.22)), (int(w * 0.18), int(h * 0.22))]:
        lines = [
            "GUIDED BOMB UNIT: GBU-31(V)3/B",
            "WARHEAD: BLU-109/B PENETRATOR 2000 LB",
            "GUIDANCE: GPS / INS MIL-STD-1760",
            f"SERIAL: {serial} • {callsign}",
            f"SORTIE: {pilot.upper()} • {date_str}",
        ]
        curr_y = qy
        for l in lines:
            draw_diff.text((qx, curr_y), l, font=font_mono, fill=(*COLOR_STENCIL_BLACK, 240))
            draw_rm.text((qx, curr_y), l, font=font_mono, fill=(255, 210, 0, 240))
            curr_y += 32

    # Squadron Patch Decal
    patch_path = PATCH_DIR / "13th_BS_Grim_Reapers_Patch.png"
    if patch_path.exists():
        patch_img = Image.open(patch_path).convert("RGBA")
        patch_size = (220, 220)
        patch_scaled = patch_img.resize(patch_size, Image.Resampling.LANCZOS)
        for px, py in [(int(w * 0.54), int(h * 0.36)), (int(w * 0.08), int(h * 0.36))]:
            diff.paste(patch_scaled, (px, py), patch_scaled)
            patch_rm = Image.new("RGBA", patch_size, (255, 120, 0, 255))
            rm.paste(patch_rm, (px, py), patch_scaled)


def generate_gbu31_slot(slot_name: str, slot_cfg: dict, mission_cfg: dict):
    """Generates complete PBR maps for one GBU-31 slot."""
    bay = slot_cfg.get("bay", 1)
    seed = slot_cfg.get("seed", 1337)
    fonts = get_fonts()

    print(f"[PBR] === Generating GBU-31 {slot_name.upper()} (Bay {bay}) ===")
    diff, rm, norm = build_gbu31_base_maps()
    apply_gbu31_stencils(diff, rm, norm, fonts, slot_cfg, mission_cfg)

    # Apply Port Inscription
    port_text = slot_cfg.get("port_text", "NIGHT SHIFT ★")
    med = slot_cfg.get("medium", "marker")
    col = tuple(slot_cfg.get("color", [255, 255, 230]))
    apply_physical_inscription(diff, rm, norm, fonts, port_text, med, col, (int(2048 * 0.52), int(2048 * 0.44)), -4, seed)

    # Apply Starboard Inscription
    stbd_text = slot_cfg.get("starboard_text", "WHITEMAN AIRMAIL")
    apply_physical_inscription(diff, rm, norm, fonts, stbd_text, med, col, (int(2048 * 0.06), int(2048 * 0.44)), 4, seed + 100)

    # Apply Weathering
    wear = slot_cfg.get("weathering", 0.35)
    apply_weathering(diff, rm, norm, wear, seed)

    # Filenames
    prefix = f"GBU31_Slot{bay}"
    diff_name = f"{prefix}_Diffuse.png"
    rm_name = f"{prefix}_RoughMet.png"
    norm_name = f"{prefix}_Normal.png"

    # Save to Dev & Saved Games
    DEV_TEX_DIR.mkdir(parents=True, exist_ok=True)
    diff.save(DEV_TEX_DIR / diff_name, "PNG")
    rm.save(DEV_TEX_DIR / rm_name, "PNG")
    norm.save(DEV_TEX_DIR / norm_name, "PNG")
    print(f"[PBR] Saved GBU-31 Dev Maps: {diff_name}, {rm_name}, {norm_name}")

    if SAVED_GAMES_TEX_DIR.exists():
        diff.save(SAVED_GAMES_TEX_DIR / diff_name, "PNG")
        rm.save(SAVED_GAMES_TEX_DIR / rm_name, "PNG")
        norm.save(SAVED_GAMES_TEX_DIR / norm_name, "PNG")
        print(f"[PBR] Synced GBU-31 Live DCS Maps: {diff_name}, {rm_name}, {norm_name}")


def run_multi_weapon_compositor():
    # Import MOAB runner
    from moab_pbr_compositor import run_compositor as run_moab_compositor, load_manifest

    print("============================================================")
    print(" PHASE 15: GENERIC DCS ORDNANCE PERSONALIZATION COMPOSITOR")
    print("============================================================")

    # 1. Compile MOAB Suites
    print("\n--- 1. COMPILING GBU-43/B MOAB PBR SUITES ---")
    run_moab_compositor()

    # 2. Compile GBU-31 Suites
    print("\n--- 2. COMPILING GBU-31 JDAM PBR SUITES ---")
    manifest = load_manifest()
    mission = manifest.get("mission", {})
    slots = manifest.get("slots", {})
    for slot_id, slot_data in slots.items():
        generate_gbu31_slot(slot_id, slot_data, mission)

    print("\n============================================================")
    print(" [SUCCESS] ALL ORDNANCE SUITES (MOAB & GBU-31) COMPILED!")
    print("============================================================\n")


if __name__ == "__main__":
    run_multi_weapon_compositor()
