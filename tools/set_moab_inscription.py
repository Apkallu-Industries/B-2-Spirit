"""Custom MOAB Inscription Utility for B-2 Spirit Mod.
Bakes any custom text up to 32 characters directly onto the GBU-43/B MOAB
3D bomb casing texture (MOAB_Casing_Custom.png), making it visible in DCS
World 3D external / F6 weapon view for in-flight screenshots!
"""

import sys
import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(r"c:\Dev\AutonomousDronePack\B-2 Spirit")
DEV_TEX = HERE / "B-2 Spirit" / "Textures" / "Weapons"
BASE_IMG = DEV_TEX / "MOAB_Grim_Reapers_Casing.png"
OUT_IMG = DEV_TEX / "MOAB_Casing_Custom.png"

SAVED_GAMES_TEX = Path(r"C:\Users\danym\Saved Games\DCS\Mods\aircraft\B-2_Spirit\Textures\Weapons")


def apply_inscription(text: str, subtitle: str = "Whiteman AFB • 13th Bomb Sqn"):
    # Clean and clamp text to 32 characters
    text = text.strip()
    if not text:
        text = "Signed & Sealed — 32 Chars Max"
    if len(text) > 32:
        print(f"[!] Warning: Text exceeds 32 characters. Clamping to: '{text[:32]}'")
        text = text[:32]

    assert BASE_IMG.exists(), f"Base MOAB texture not found: {BASE_IMG}"

    font_path = r"C:\Windows\Fonts\Inkfree.ttf"
    if not os.path.exists(font_path):
        font_path = r"C:\Windows\Fonts\arialbd.ttf"

    im = Image.open(BASE_IMG).convert("RGBA")

    # Transparent text layer
    txt_overlay = Image.new("RGBA", (850, 420), (255, 255, 255, 0))
    d = ImageDraw.Draw(txt_overlay)

    # Dynamic font size based on text length to keep it large and punchy
    if len(text) <= 16:
        main_size = 72
    elif len(text) <= 24:
        main_size = 62
    else:
        main_size = 52

    sub_size = 34

    main_font = ImageFont.truetype(font_path, main_size)
    sub_font = ImageFont.truetype(font_path, sub_size)

    # Main inscription (bright chalk yellow/white with subtle drop shadow)
    d.text((22, 22), text, font=main_font, fill=(15, 15, 15, 190))
    d.text((20, 20), text, font=main_font, fill=(255, 255, 230, 255))

    # Subtitle / Unit tag
    sub_y = 20 + main_size + 14
    d.text((22, sub_y + 2), subtitle, font=sub_font, fill=(15, 15, 15, 180))
    d.text((20, sub_y), subtitle, font=sub_font, fill=(220, 235, 255, 240))

    # Slight realistic tilt
    rotated = txt_overlay.rotate(-6, expand=True, resample=Image.Resampling.BICUBIC)

    # Composite onto the casing side
    im.paste(rotated, (460, 515), rotated)

    # Save to dev repository
    DEV_TEX.mkdir(parents=True, exist_ok=True)
    im.save(OUT_IMG, "PNG")
    print(f"[+] Saved Dev Texture: {OUT_IMG}")

    # Save directly to DCS Saved Games if directory exists
    if SAVED_GAMES_TEX.exists():
        sg_out = SAVED_GAMES_TEX / "MOAB_Casing_Custom.png"
        im.save(sg_out, "PNG")
        print(f"[+] Synced to DCS Live: {sg_out}")

    print(f"\n============================================================")
    print(f" MOAB 3D CASING INSCRIBED SUCCESSFULLY!")
    print(f" Inscription: \"{text}\" ({len(text)}/32 characters)")
    print(f" Subtitle:    \"{subtitle}\"")
    print(f" Model to load in DCS: GBU-43/B MOAB (Custom Inscription)")
    print(f" In-Flight Key: Drop bomb and press 'F6' to view your message in 3D!")
    print(f"============================================================\n")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        custom_msg = " ".join(sys.argv[1:])
    else:
        try:
            custom_msg = input("Enter custom MOAB inscription (max 32 chars): ")
        except (EOFError, KeyboardInterrupt):
            custom_msg = "Signed by Pilot — 13th BS"
    apply_inscription(custom_msg)
