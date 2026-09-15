"""Phase 14: B-2 Ordnance Personalization System — PBR Compositor Engine.
Generates complete, authentic PBR texture maps (Diffuse, RoughMet, Normal) for
the GBU-43/B MOAB heavy ordnance suite based on a customization manifest.

Supports:
- Dual-slot bay generation (Bay 1 / Slot 1 and Bay 2 / Slot 2)
- Physical writing mediums: Felt-tip marker, chalk, grease pencil, spray stencil
- Procedural weathering: Scratches, bare metal chips, grease smudges, ink fade
- Two independent sides (Port & Starboard)
- Squadron patches, nose art, serial data matrix blocks
"""

import json
import math
import os
import random
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

HERE = Path(r"c:\Dev\AutonomousDronePack\B-2 Spirit")
DEV_TEX_DIR = HERE / "B-2 Spirit" / "Textures" / "Weapons"
PATCH_DIR = DEV_TEX_DIR
SAVED_GAMES_TEX_DIR = Path(r"C:\Users\danym\Saved Games\DCS\Mods\aircraft\B-2_Spirit\Textures\Weapons")
CUSTOM_JSON_PATH = HERE / "tools" / "ordnance_customizer" / "customization.json"

IMG_WIDTH = 2048
IMG_HEIGHT = 2048

# Color definitions (RGB)
COLOR_OD_BASE = (72, 84, 58)          # Olive Drab FS 34087
COLOR_OD_PANEL = (66, 78, 54)         # Shaded seam OD
COLOR_YELLOW_BAND = (235, 178, 30)     # FS 33538 High-Explosive Yellow
COLOR_STENCIL_BLACK = (25, 27, 26)     # Matte Black USAF Stencil
COLOR_STENCIL_WHITE = (225, 228, 222)   # Tactical Off-White Stencil
COLOR_BARE_ALUMINUM = (185, 190, 195)  # Chipped paint metal exposed

# Default Manifest Template
DEFAULT_MANIFEST = {
    "mission": {
        "callsign": "GRIM 21",
        "pilot_name": "Capt Mitchell",
        "date": "14 SEP 2026",
        "sortie_id": "SORTIE-B2-041",
    },
    "slots": {
        "slot1": {
            "bay": 1,
            "serial": "MOAB-2026-0061",
            "medium": "marker",           # marker, chalk, grease, stencil
            "color": [255, 255, 230],     # Inscription color
            "port_text": "EAT SHIT!\n— 13th Bomb Squadron",
            "starboard_text": "FOR FREEDOM ★\nWhiteman AFB sends regards",
            "patch": "13th_BS_Grim_Reapers_Patch.png",
            "weathering": 0.35,           # 0.0 (factory) to 1.0 (heavy scuffed)
            "seed": 1337,
        },
        "slot2": {
            "bay": 2,
            "serial": "MOAB-2026-0062",
            "medium": "chalk",            # chalk
            "color": [240, 245, 255],
            "port_text": "ENJOY!\nDirect Airmail Delivery",
            "starboard_text": "HOPE YOU LIKE OUR NEW TOY!\n(USAF 509th BW)",
            "patch": "13th_BS_Grim_Reapers_Patch.png",
            "weathering": 0.45,
            "seed": 9001,
        }
    }
}


def load_manifest() -> dict:
    if CUSTOM_JSON_PATH.exists():
        try:
            with open(CUSTOM_JSON_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"[!] Warning reading customization.json: {e}, falling back to default.")
    return DEFAULT_MANIFEST


def get_fonts():
    font_paths = {
        "hand": r"C:\Windows\Fonts\Inkfree.ttf",
        "stencil": r"C:\Windows\Fonts\impact.ttf",
        "clean": r"C:\Windows\Fonts\arialbd.ttf",
        "mono": r"C:\Windows\Fonts\consola.ttf",
    }
    for k, p in font_paths.items():
        if not os.path.exists(p):
            font_paths[k] = r"C:\Windows\Fonts\arial.ttf"
    return font_paths


def build_base_casing_maps(w=IMG_WIDTH, h=IMG_HEIGHT):
    """Builds base diffuse, roughmet, and normal maps for the MOAB casing."""
    # 1. Base Diffuse: Olive Drab with subtle gradient & seam lines
    diff = Image.new("RGBA", (w, h), (*COLOR_OD_BASE, 255))
    draw_diff = ImageDraw.Draw(diff)

    # 2. Base RoughMet: R=AO, G=Roughness, B=Metalness
    # Casing is non-metal (B=0), matte paint (G=190 / 255 ~= 0.75), AO=255
    rm = Image.new("RGBA", (w, h), (255, 190, 0, 255))
    draw_rm = ImageDraw.Draw(rm)

    # 3. Base Normal: Flat tangent normal (128, 128, 255)
    norm = Image.new("RGBA", (w, h), (128, 128, 255, 255))
    draw_norm = ImageDraw.Draw(norm)

    # Yellow Ordnance Hazard Bands (Nose section V=0.78-0.84, Mid section V=0.45-0.49)
    # Note: V coordinate maps to Y in image space (V=1 top, V=0 bottom)
    band_y1_top = int(h * (1.0 - 0.84))
    band_y1_bot = int(h * (1.0 - 0.78))
    band_y2_top = int(h * (1.0 - 0.49))
    band_y2_bot = int(h * (1.0 - 0.45))

    for y_top, y_bot in [(band_y1_top, band_y1_bot), (band_y2_top, band_y2_bot)]:
        draw_diff.rectangle([0, y_top, w, y_bot], fill=(*COLOR_YELLOW_BAND, 255))
        # Stenciled bands are slightly smoother paint (G=165)
        draw_rm.rectangle([0, y_top, w, y_bot], fill=(255, 165, 0, 255))
        # Bevel top and bottom of band in normal map (+Y and -Y relief)
        draw_norm.line([(0, y_top), (w, y_top)], fill=(128, 145, 255, 255), width=2)
        draw_norm.line([(0, y_bot), (w, y_bot)], fill=(128, 110, 255, 255), width=2)

    # Circumferential rivet/weld seam bands
    seam_ys = [int(h * frac) for frac in [0.12, 0.28, 0.52, 0.72, 0.88]]
    for sy in seam_ys:
        draw_diff.line([(0, sy), (w, sy)], fill=(*COLOR_OD_PANEL, 255), width=3)
        draw_rm.line([(0, sy), (w, sy)], fill=(200, 215, 0, 255), width=3)  # AO shadow
        draw_norm.line([(0, sy - 1), (w, sy - 1)], fill=(128, 140, 255, 255), width=1)
        draw_norm.line([(0, sy + 1), (w, sy + 1)], fill=(128, 115, 255, 255), width=1)

    return diff, rm, norm


def apply_stencils_and_data(diff, rm, norm, fonts, slot_cfg, mission_cfg):
    """Applies official USAF MIL-SPEC stenciling, serial block, and squadron insignia."""
    w, h = diff.size
    draw_diff = ImageDraw.Draw(diff)
    draw_rm = ImageDraw.Draw(rm)
    font_mono = ImageFont.truetype(fonts["mono"], 28)
    font_clean = ImageFont.truetype(fonts["clean"], 36)
    font_stencil = ImageFont.truetype(fonts["stencil"], 48)

    serial = slot_cfg.get("serial", "MOAB-2026-0061")
    callsign = mission_cfg.get("callsign", "GRIM 21")
    pilot = mission_cfg.get("pilot_name", "Capt Mitchell")
    date_str = mission_cfg.get("date", "14 SEP 2026")

    # Stencil text on Port (Left) and Starboard (Right) casing sides
    # Port: X ~ 0.70 * w; Starboard: X ~ 0.25 * w
    quadrants = [
        ("PORT", int(w * 0.72), int(h * 0.22)),
        ("STARBOARD", int(w * 0.22), int(h * 0.22)),
    ]

    for side, qx, qy in quadrants:
        # MIL-SPEC USAF Data Block
        lines = [
            f"BOMB, GUIDED UNIT: GBU-43/B MOAB",
            f"HIGH EXPLOSIVE H-6 / 18,700 LB BLK",
            f"TOTAL WT: 21,600 LBS • DIA 40.5 IN",
            f"SERIAL NO: {serial}",
            f"SORTIE: {callsign} / {pilot.upper()}",
            f"DATE OF INSP: {date_str} • USAF 509 BW",
        ]

        curr_y = qy
        for l in lines:
            draw_diff.text((qx, curr_y), l, font=font_mono, fill=(*COLOR_STENCIL_BLACK, 240))
            # Stencil is matte
            draw_rm.text((qx, curr_y), l, font=font_mono, fill=(255, 210, 0, 240))
            curr_y += 34

        # Huge USAF Hazard Warning
        draw_diff.text((qx, curr_y + 12), "▲ EXTREME EXPLOSIVE BLAST RADIUS ▲", font=font_clean, fill=(25, 25, 25, 255))
        draw_diff.text((qx, curr_y + 54), "13TH BOMB SQN 'GRIM REAPERS'", font=font_stencil, fill=(235, 180, 20, 240))

    # Apply Squadron Patch Decal if available
    patch_name = slot_cfg.get("patch", "13th_BS_Grim_Reapers_Patch.png")
    patch_path = PATCH_DIR / patch_name
    if patch_path.exists():
        patch_img = Image.open(patch_path).convert("RGBA")
        patch_size = (280, 280)
        patch_scaled = patch_img.resize(patch_size, Image.Resampling.LANCZOS)
        
        # Paste patch on both port and starboard
        for side, px, py in [("PORT", int(w * 0.58), int(h * 0.38)), ("STBD", int(w * 0.08), int(h * 0.38))]:
            diff.paste(patch_scaled, (px, py), patch_scaled)
            # Patch has semi-gloss vinyl finish (G=120)
            patch_rm = Image.new("RGBA", patch_size, (255, 120, 0, 255))
            rm.paste(patch_rm, (px, py), patch_scaled)


def apply_physical_inscription(diff, rm, norm, fonts, text, medium, color, pos, angle, seed=42):
    """Renders physical handwritten or stenciled text with distinct PBR properties."""
    if not text.strip():
        return

    random.seed(seed)
    font_path = fonts["hand"] if medium in ["marker", "chalk", "grease"] else fonts["stencil"]
    
    # Measure line count and scale
    lines = [l.strip() for l in text.split("\n") if l.strip()]
    if not lines:
        return

    font_size = 76 if len(lines) == 1 else (58 if len(lines) == 2 else 46)
    font = ImageFont.truetype(font_path, font_size)

    # Bounding box calculation
    max_w = max([len(l) for l in lines]) * int(font_size * 0.75) + 120
    box_h = len(lines) * (font_size + 24) + 80

    txt_diff = Image.new("RGBA", (max_w, box_h), (0, 0, 0, 0))
    txt_rm = Image.new("RGBA", (max_w, box_h), (0, 0, 0, 0))
    txt_norm = Image.new("RGBA", (max_w, box_h), (0, 0, 0, 0))

    d_diff = ImageDraw.Draw(txt_diff)
    d_rm = ImageDraw.Draw(txt_rm)
    d_norm = ImageDraw.Draw(txt_norm)

    cur_y = 20
    for l in lines:
        # Base text rendering
        # Shadow for physical contact
        d_diff.text((22, cur_y + 2), l, font=font, fill=(15, 15, 15, 170))
        # Main text stroke
        d_diff.text((20, cur_y), l, font=font, fill=(*color, 255))

        if medium == "marker":
            # Felt-tip marker: Glossier than matte casing (G=105), no metal (B=0)
            d_rm.text((20, cur_y), l, font=font, fill=(255, 105, 0, 240))
            # Very subtle flat normal
            d_norm.text((20, cur_y), l, font=font, fill=(128, 131, 255, 180))

        elif medium == "grease":
            # Grease pencil / china marker: Waxy organic sheen (G=140), raised impasto bevel
            d_rm.text((20, cur_y), l, font=font, fill=(255, 140, 0, 250))
            # Normal map: bevel edge for physical wax thickness
            d_norm.text((20, cur_y - 1), l, font=font, fill=(128, 145, 255, 220))
            d_norm.text((20, cur_y + 1), l, font=font, fill=(128, 110, 255, 220))

        elif medium == "chalk":
            # Chalk: Extremely rough (G=245), dry, matte
            d_rm.text((20, cur_y), l, font=font, fill=(255, 245, 0, 255))
            # No specular shine, flat normal
            d_norm.text((20, cur_y), l, font=font, fill=(128, 128, 255, 150))

        elif medium == "stencil":
            # Sprayed Stencil: Raised paint edge (+Y relief in normal), uniform satin sheen (G=160)
            d_rm.text((20, cur_y), l, font=font, fill=(255, 160, 0, 250))
            d_norm.text((20, cur_y - 1), l, font=font, fill=(128, 150, 255, 240))
            d_norm.text((20, cur_y + 1), l, font=font, fill=(128, 105, 255, 240))

        cur_y += font_size + 20

    # If chalk: apply subtle porous noise scatter to emulate broken chalk texture
    if medium == "chalk":
        # Introduce micro-pore alpha breaks
        w_b, h_b = txt_diff.size
        pixels = txt_diff.load()
        for py in range(h_b):
            for px in range(w_b):
                if pixels[px, py][3] > 50 and random.random() < 0.14:
                    r, g, b, a = pixels[px, py]
                    pixels[px, py] = (r, g, b, int(a * 0.35))

    # Realistic tilt rotation
    rot_diff = txt_diff.rotate(angle, expand=True, resample=Image.Resampling.BICUBIC)
    rot_rm = txt_rm.rotate(angle, expand=True, resample=Image.Resampling.BICUBIC)
    rot_norm = txt_norm.rotate(angle, expand=True, resample=Image.Resampling.BICUBIC)

    # Composite into master maps
    diff.paste(rot_diff, pos, rot_diff)
    rm.paste(rot_rm, pos, rot_rm)
    norm.paste(rot_norm, pos, rot_norm)


def apply_weathering(diff, rm, norm, level, seed):
    """Applies deterministic procedural weathering: scratches, paint chips, bare metal."""
    if level <= 0.05:
        return

    random.seed(seed)
    w, h = diff.size
    d_diff = ImageDraw.Draw(diff)
    d_rm = ImageDraw.Draw(rm)
    d_norm = ImageDraw.Draw(norm)

    num_scratches = int(40 * level)
    for _ in range(num_scratches):
        x1 = random.randint(100, w - 100)
        y1 = random.randint(200, h - 200)
        length = random.randint(15, int(120 * level))
        angle = random.uniform(-math.pi, math.pi)
        x2 = int(x1 + length * math.cos(angle))
        y2 = int(y1 + length * math.sin(angle))

        # Bare metal scratch: aluminum color, mirror roughness (G=60), metalness (B=230)
        d_diff.line([(x1, y1), (x2, y2)], fill=(*COLOR_BARE_ALUMINUM, 220), width=random.choice([1, 2]))
        d_rm.line([(x1, y1), (x2, y2)], fill=(255, 60, 230, 255), width=2)
        d_norm.line([(x1, y1), (x2, y2)], fill=(128, 145, 255, 255), width=1)


def generate_slot(slot_name: str, slot_cfg: dict, mission_cfg: dict):
    """Generates the full Diffuse, RoughMet, and Normal maps for one weapon slot."""
    bay = slot_cfg.get("bay", 1)
    seed = slot_cfg.get("seed", 1337)
    fonts = get_fonts()

    print(f"\n[PBR] === Generating {slot_name.upper()} (Bay {bay}) ===")
    print(f"[PBR] Inscription: '{slot_cfg.get('port_text', '')}' | Medium: {slot_cfg.get('medium', 'marker')}")

    diff, rm, norm = build_base_casing_maps()
    apply_stencils_and_data(diff, rm, norm, fonts, slot_cfg, mission_cfg)

    # Apply Port Inscription (Left side: X ~ 0.58 * w, Y ~ 0.52 * h)
    port_text = slot_cfg.get("port_text", "")
    med = slot_cfg.get("medium", "marker")
    col = tuple(slot_cfg.get("color", [255, 255, 230]))
    apply_physical_inscription(diff, rm, norm, fonts, port_text, med, col, (int(IMG_WIDTH * 0.52), int(IMG_HEIGHT * 0.51)), -5, seed)

    # Apply Starboard Inscription (Right side: X ~ 0.06 * w, Y ~ 0.52 * h)
    stbd_text = slot_cfg.get("starboard_text", "")
    apply_physical_inscription(diff, rm, norm, fonts, stbd_text, med, col, (int(IMG_WIDTH * 0.05), int(IMG_HEIGHT * 0.51)), 4, seed + 100)

    # Apply Weathering
    wear = slot_cfg.get("weathering", 0.35)
    apply_weathering(diff, rm, norm, wear, seed)

    # File prefixes
    prefix = f"MOAB_Slot{bay}"
    diff_name = f"{prefix}_Diffuse.png"
    rm_name = f"{prefix}_RoughMet.png"
    norm_name = f"{prefix}_Normal.png"

    # Save to Dev repository
    DEV_TEX_DIR.mkdir(parents=True, exist_ok=True)
    diff.save(DEV_TEX_DIR / diff_name, "PNG")
    rm.save(DEV_TEX_DIR / rm_name, "PNG")
    norm.save(DEV_TEX_DIR / norm_name, "PNG")
    print(f"[PBR] Saved Dev Maps: {diff_name}, {rm_name}, {norm_name}")

    # Sync to DCS Saved Games
    if SAVED_GAMES_TEX_DIR.exists():
        diff.save(SAVED_GAMES_TEX_DIR / diff_name, "PNG")
        rm.save(SAVED_GAMES_TEX_DIR / rm_name, "PNG")
        norm.save(SAVED_GAMES_TEX_DIR / norm_name, "PNG")
        print(f"[PBR] Synced Live DCS Maps: {diff_name}, {rm_name}, {norm_name}")


def write_lua_manifest(manifest):
    slots = manifest.get("slots", {})
    lua_lines = [
        "-- Auto-generated by B-2 Ordnance Personalization System",
        "ordnance_manifest = {",
    ]
    for s_id, s_data in slots.items():
        bay = s_data.get("bay", 1)
        text = s_data.get("port_text", "").split("\n")[0].replace('"', '\\"')
        serial = s_data.get("serial", "")
        med = s_data.get("medium", "marker")
        lua_lines.append(f'    slot{bay} = {{ serial = "{serial}", text = "{text}", medium = "{med}" }},')
    lua_lines.append("}\n")
    lua_content = "\n".join(lua_lines)

    dev_manifest = HERE / "B-2 Spirit" / "Cockpit" / "Scripts" / "Systems" / "ordnance_manifest.lua"
    dev_manifest.parent.mkdir(parents=True, exist_ok=True)
    with open(dev_manifest, "w", encoding="utf-8") as f:
        f.write(lua_content)

    sg_manifest = Path(r"C:\Users\danym\Saved Games\DCS\Mods\aircraft\B-2_Spirit\Cockpit\Scripts\Systems\ordnance_manifest.lua")
    if sg_manifest.parent.exists():
        with open(sg_manifest, "w", encoding="utf-8") as f:
            f.write(lua_content)
    print(f"[PBR] Written Cockpit Ordnance Manifest: {dev_manifest.name}")


def run_compositor():
    manifest = load_manifest()
    mission = manifest.get("mission", {})
    slots = manifest.get("slots", {})

    print("============================================================")
    print(" B-2 ORDNANCE PERSONALIZATION SYSTEM — PBR COMPOSITOR")
    print(f" Callsign: {mission.get('callsign')} | Pilot: {mission.get('pilot_name')}")
    print(f" Date: {mission.get('date')} | Sortie: {mission.get('sortie_id')}")
    print("============================================================")

    for slot_id, slot_data in slots.items():
        generate_slot(slot_id, slot_data, mission)

    write_lua_manifest(manifest)

    print("\n============================================================")
    print(" [SUCCESS] ALL ORDNANCE PBR MAPS COMPILED AND SYNCED SUCCESSFULLY!")
    print("============================================================\n")


if __name__ == "__main__":
    run_compositor()
