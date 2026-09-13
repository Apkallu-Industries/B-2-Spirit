"""
Generate High-Resolution (2048x2048) Authentic Cockpit Textures for B-2 Spirit
Eliminates flat 64x64 Roblox-style solid color blocks with realistic military panel faceplates:
1. B2_Bezel_Diffuse.png (2048x2048): MFD bezel with OSBs 1-20, Dzus screws, BRT/CONT labels, matte powder-coat
2. B2_Pedestal_Diffuse.png (2048x2048): Throttle quadrant indices, CDU keypad, APU/ENG start, gear panel
3. B2_Glareshield_Diffuse.png (2048x2048): Autopilot panel, master caution/warning, leather glare texture
4. B2_Standby_Instruments.png (2048x2048): Backup ADI, Altimeter, Airspeed dial faces
5. B2_Cockpit_Dark_Diffuse.png (2048x2048): FS 36231 Dark Gull Gray with fine speckle and panel seams
6. B2_Metal_Brushed_Diffuse.png (1024x1024): Anodized brushed steel with fine metallic grain
7. B2_Caution_Amber_Diffuse.png & Red: Smoked dark acrylic with louvers and unlit stencils
"""

import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont

tex_dir = r"c:\Dev\AutonomousDronePack\B-2 Spirit\Textures"
os.makedirs(tex_dir, exist_ok=True)

def get_font(size):
    try:
        return ImageFont.truetype("arialbd.ttf", size)
    except:
        return ImageFont.load_default()

def get_regular_font(size):
    try:
        return ImageFont.truetype("arial.ttf", size)
    except:
        return ImageFont.load_default()

def make_cockpit_dark():
    size = 2048
    arr = np.full((size, size, 3), [48, 52, 56], dtype=np.float32)
    noise = np.random.normal(0, 3.5, (size, size, 3))
    arr = np.clip(arr + noise, 0, 255).astype(np.uint8)
    img = Image.fromarray(arr)
    draw = ImageDraw.Draw(img)
    for y in [256, 512, 1024, 1536]:
        draw.line([(0, y), (size, y)], fill=(32, 35, 38), width=3)
        draw.line([(0, y+3), (size, y+3)], fill=(65, 70, 75), width=1)
    for x in [512, 1024, 1536]:
        draw.line([(x, 0), (x, size)], fill=(32, 35, 38), width=3)
        draw.line([(x+3, 0), (x+3, size)], fill=(65, 70, 75), width=1)
    img.save(os.path.join(tex_dir, "B2_Cockpit_Dark_Diffuse.png"))
    print("Generated B2_Cockpit_Dark_Diffuse.png")

def make_bezel():
    size = 2048
    arr = np.full((size, size, 3), [30, 32, 35], dtype=np.float32)
    noise = np.random.normal(0, 2.5, (size, size, 3))
    arr = np.clip(arr + noise, 0, 255).astype(np.uint8)
    img = Image.fromarray(arr)
    draw = ImageDraw.Draw(img)
    font_med = get_font(30)
    font_small = get_font(22)
    s_min, s_max = 280, 1768
    draw.rectangle([s_min, s_min, s_max, s_max], outline=(15, 16, 18), width=12)
    draw.rectangle([s_min-6, s_min-6, s_max+6, s_max+6], outline=(55, 60, 65), width=2)
    for i in range(5):
        cx = s_min + int((i + 0.5) * (s_max - s_min) / 5)
        cy = s_min - 120
        draw.rectangle([cx-50, cy-50, cx+50, cy+50], fill=(22, 24, 26), outline=(60, 65, 70), width=3)
        txt = f"OSB {i+1}"
        draw.text((cx, cy + 65), txt, fill=(230, 235, 240), font=font_small, anchor="mm")
    for i in range(5):
        cx = s_max + 120
        cy = s_min + int((i + 0.5) * (s_max - s_min) / 5)
        draw.rectangle([cx-50, cy-50, cx+50, cy+50], fill=(22, 24, 26), outline=(60, 65, 70), width=3)
        txt = f"OSB {i+6}"
        draw.text((cx - 65, cy), txt, fill=(230, 235, 240), font=font_small, anchor="mm")
    for i in range(5):
        cx = s_max - int((i + 0.5) * (s_max - s_min) / 5)
        cy = s_max + 120
        draw.rectangle([cx-50, cy-50, cx+50, cy+50], fill=(22, 24, 26), outline=(60, 65, 70), width=3)
        txt = f"OSB {i+11}"
        draw.text((cx, cy - 65), txt, fill=(230, 235, 240), font=font_small, anchor="mm")
    for i in range(5):
        cx = s_min - 120
        cy = s_max - int((i + 0.5) * (s_max - s_min) / 5)
        draw.rectangle([cx-50, cy-50, cx+50, cy+50], fill=(22, 24, 26), outline=(60, 65, 70), width=3)
        txt = f"OSB {i+16}"
        draw.text((cx + 65, cy), txt, fill=(230, 235, 240), font=font_small, anchor="mm")
    for dx, dy in [(120, 120), (size-120, 120), (120, size-120), (size-120, size-120)]:
        draw.ellipse([dx-35, dy-35, dx+35, dy+35], fill=(50, 54, 58), outline=(18, 20, 22), width=3)
        draw.ellipse([dx-30, dy-30, dx+30, dy+30], fill=(70, 75, 80), outline=(90, 95, 100), width=1)
        draw.line([(dx-24, dy), (dx+24, dy)], fill=(20, 22, 24), width=6)
    draw.text((size//2, s_min - 200), "SYM / VID", fill=(210, 215, 220), font=font_med, anchor="mm")
    draw.text((s_min + 60, s_max + 200), "BRT", fill=(210, 215, 220), font=font_med, anchor="mm")
    draw.text((s_max - 60, s_max + 200), "CONT", fill=(210, 215, 220), font=font_med, anchor="mm")
    draw.ellipse([s_min + 140 - 20, s_min - 200 - 20, s_min + 140 + 20, s_min - 200 + 20], fill=(10, 15, 20), outline=(80, 85, 90), width=3)
    img.save(os.path.join(tex_dir, "B2_Bezel_Diffuse.png"))
    print("Generated B2_Bezel_Diffuse.png")

def make_pedestal():
    size = 2048
    arr = np.full((size, size, 3), [42, 45, 48], dtype=np.float32)
    noise = np.random.normal(0, 3.0, (size, size, 3))
    arr = np.clip(arr + noise, 0, 255).astype(np.uint8)
    img = Image.fromarray(arr)
    draw = ImageDraw.Draw(img)
    font_hdr = get_font(44)
    font_lbl = get_font(32)
    font_key = get_font(36)
    font_small = get_font(24)
    draw.rectangle([50, 50, 980, 1998], fill=(32, 35, 38), outline=(65, 70, 75), width=4)
    draw.text((515, 100), "ENGINES F118-GE-100", fill=(220, 225, 230), font=font_hdr, anchor="mm")
    slot_xs = [200, 400, 600, 800]
    for idx, sx in enumerate(slot_xs):
        draw.rectangle([sx-35, 180, sx+35, 1850], fill=(12, 14, 15), outline=(50, 55, 60), width=3)
        draw.text((sx, 150), f"ENG {idx+1}", fill=(240, 240, 245), font=font_lbl, anchor="mm")
        ticks = [
            (250, "MIL (100%)", (240, 60, 60)),
            (550, "80%", (230, 235, 240)),
            (850, "60%", (230, 235, 240)),
            (1150, "40%", (230, 235, 240)),
            (1450, "20%", (230, 235, 240)),
            (1650, "IDLE (0%)", (100, 220, 100)),
            (1780, "CUTOFF", (220, 160, 40)),
        ]
        for ty, ttxt, tcol in ticks:
            draw.line([(sx-48, ty), (sx-36, ty)], fill=tcol, width=3)
            draw.line([(sx+36, ty), (sx+48, ty)], fill=tcol, width=3)
            if idx == 0:
                draw.text((sx - 55, ty), ttxt, fill=tcol, font=font_small, anchor="rm")
    draw.text((515, 1920), "SPEEDBRAKE EXT / RET", fill=(200, 205, 210), font=font_lbl, anchor="mm")
    draw.rectangle([1050, 50, 1998, 1100], fill=(30, 33, 36), outline=(65, 70, 75), width=4)
    draw.text((1524, 90), "CONTROL DISPLAY UNIT (CDU)", fill=(220, 225, 230), font=font_hdr, anchor="mm")
    keys = [
        ["DIR", "FPLN", "PERF", "INIT", "DATA", "MSG"],
        ["NAV", "COMM", "SURV", "SYS", "EXEC", "CLR"],
        ["A", "B", "C", "D", "E", "1"],
        ["F", "G", "H", "I", "J", "2"],
        ["K", "L", "M", "N", "O", "3"],
        ["P", "Q", "R", "S", "T", "4"],
        ["U", "V", "W", "X", "Y", "5"],
        ["Z", "SP", "DEL", "/", "+/-", "ENT"],
    ]
    kw, kh = 125, 80
    start_kx, start_ky = 1100, 150
    for r_idx, row in enumerate(keys):
        for c_idx, key in enumerate(row):
            kx = start_kx + c_idx * (kw + 20)
            ky = start_ky + r_idx * (kh + 25)
            btn_col = (20, 22, 24) if not key in ["EXEC", "ENT"] else (28, 45, 35)
            draw.rectangle([kx, ky, kx+kw, ky+kh], fill=btn_col, outline=(70, 75, 80), width=2)
            draw.line([(kx+2, ky+2), (kx+kw-2, ky+2)], fill=(90, 95, 100), width=2)
            draw.line([(kx+2, ky+2), (kx+2, ky+kh-2)], fill=(90, 95, 100), width=2)
            txt_col = (120, 255, 160) if key in ["EXEC", "ENT"] else (240, 240, 245)
            draw.text((kx + kw//2, ky + kh//2), key, fill=txt_col, font=font_key, anchor="mm")
    draw.rectangle([1050, 1150, 1998, 1998], fill=(32, 35, 38), outline=(65, 70, 75), width=4)
    draw.text((1524, 1190), "LANDING GEAR & APU CONTROL", fill=(220, 225, 230), font=font_hdr, anchor="mm")
    wheel_lights = [
        (1350, 1300, "NOSE"),
        (1250, 1420, "L MAIN"),
        (1450, 1420, "R MAIN"),
    ]
    for wx, wy, wlbl in wheel_lights:
        draw.rectangle([wx-55, wy-35, wx+55, wy+35], fill=(15, 18, 20), outline=(70, 75, 80), width=3)
        draw.rectangle([wx-45, wy-25, wx+45, wy+25], fill=(15, 45, 20), outline=(30, 80, 40), width=2)
        draw.text((wx, wy), wlbl, fill=(80, 210, 100), font=font_small, anchor="mm")
    draw.text((1700, 1300), "GEAR", fill=(240, 240, 245), font=font_lbl, anchor="mm")
    draw.rectangle([1650, 1330, 1750, 1550], fill=(20, 22, 25), outline=(60, 65, 70), width=3)
    draw.text((1700, 1360), "UP", fill=(240, 240, 245), font=font_small, anchor="mm")
    draw.text((1700, 1520), "DN", fill=(80, 210, 100), font=font_small, anchor="mm")
    draw.rectangle([1120, 1650, 1500, 1950], fill=(25, 28, 30), outline=(55, 60, 65), width=2)
    draw.text((1310, 1690), "APU MASTER", fill=(240, 240, 245), font=font_lbl, anchor="mm")
    draw.text((1310, 1750), "START", fill=(240, 180, 40), font=font_small, anchor="mm")
    draw.text((1310, 1810), "RUN", fill=(80, 210, 100), font=font_small, anchor="mm")
    draw.text((1310, 1870), "OFF", fill=(220, 225, 230), font=font_small, anchor="mm")
    draw.rectangle([1580, 1650, 1930, 1950], fill=(25, 28, 30), outline=(55, 60, 65), width=2)
    draw.text((1755, 1690), "FLAP POSITION", fill=(240, 240, 245), font=font_lbl, anchor="mm")
    draw.text((1755, 1750), "UP (0°)", fill=(220, 225, 230), font=font_small, anchor="mm")
    draw.text((1755, 1810), "HALF (15°)", fill=(220, 225, 230), font=font_small, anchor="mm")
    draw.text((1755, 1870), "FULL (30°)", fill=(220, 225, 230), font=font_small, anchor="mm")
    img.save(os.path.join(tex_dir, "B2_Pedestal_Diffuse.png"))
    print("Generated B2_Pedestal_Diffuse.png")

def make_glareshield():
    size = 2048
    arr = np.full((size, size, 3), [24, 26, 28], dtype=np.float32)
    noise = np.random.normal(0, 4.0, (size, size, 3))
    arr = np.clip(arr + noise, 0, 255).astype(np.uint8)
    img = Image.fromarray(arr)
    draw = ImageDraw.Draw(img)
    font_title = get_font(52)
    font_lbl = get_font(38)
    font_btn = get_font(32)
    draw.rectangle([100, 400, 480, 650], fill=(45, 12, 12), outline=(100, 25, 25), width=6)
    draw.rectangle([115, 415, 465, 635], fill=(30, 8, 8), outline=(150, 35, 35), width=3)
    draw.text((290, 525), "MASTER\nWARN", fill=(255, 60, 50), font=font_lbl, anchor="mm", align="center")
    draw.rectangle([100, 750, 480, 1000], fill=(45, 30, 8), outline=(110, 75, 15), width=6)
    draw.rectangle([115, 765, 465, 985], fill=(30, 20, 5), outline=(160, 100, 20), width=3)
    draw.text((290, 875), "MASTER\nCAUTION", fill=(255, 180, 30), font=font_lbl, anchor="mm", align="center")
    draw.rectangle([600, 350, 1948, 1250], fill=(32, 35, 38), outline=(65, 70, 75), width=5)
    draw.text((1274, 420), "AUTOMATIC FLIGHT CONTROL SYSTEM (AFCS)", fill=(225, 230, 235), font=font_title, anchor="mm")
    ap_modes = [
        ("AP ENG", 750, 600, (80, 220, 100)),
        ("HDG SEL", 980, 600, (230, 235, 240)),
        ("NAV", 1210, 600, (230, 235, 240)),
        ("ALT HOLD", 1440, 600, (230, 235, 240)),
        ("VNAV", 1670, 600, (230, 235, 240)),
        ("AT ENG", 750, 850, (80, 220, 100)),
        ("SPD SEL", 980, 850, (230, 235, 240)),
        ("APP", 1210, 850, (230, 235, 240)),
        ("TERR FLW", 1440, 850, (230, 235, 240)),
        ("DISENG", 1670, 850, (255, 80, 70)),
    ]
    for m_lbl, mx, my, mcol in ap_modes:
        draw.rectangle([mx-90, my-60, mx+90, my+60], fill=(18, 20, 22), outline=(60, 65, 70), width=3)
        draw.line([(mx-88, my-58), (mx+88, my-58)], fill=(80, 85, 90), width=2)
        draw.text((mx, my), m_lbl, fill=mcol, font=font_btn, anchor="mm")
    for y in [1400, 1600, 1800]:
        draw.line([(0, y), (size, y)], fill=(15, 16, 17), width=8)
        draw.line([(0, y+4), (size, y+4)], fill=(40, 43, 46), width=2)
    img.save(os.path.join(tex_dir, "B2_Glareshield_Diffuse.png"))
    print("Generated B2_Glareshield_Diffuse.png")

def make_standby():
    size = 2048
    img = Image.new("RGB", (size, size), (25, 27, 30))
    draw = ImageDraw.Draw(img)
    font_dial = get_font(42)
    font_hdr = get_font(48)
    font_small = get_font(26)
    cx, cy, r = 512, 512, 420
    draw.ellipse([cx-r-20, cy-r-20, cx+r+20, cy+r+20], fill=(15, 16, 18), outline=(50, 55, 60), width=8)
    draw.pieslice([cx-r, cy-r, cx+r, cy+r], 180, 360, fill=(35, 85, 160))
    draw.pieslice([cx-r, cy-r, cx+r, cy+r], 0, 180, fill=(130, 80, 35))
    draw.line([(cx-r, cy), (cx+r, cy)], fill=(255, 255, 255), width=6)
    for p_deg, py in [(-20, cy+140), (-10, cy+70), (10, cy-70), (20, cy-140)]:
        draw.line([(cx-80, py), (cx+80, py)], fill=(255, 255, 255), width=4)
        draw.text((cx-105, py), f"{abs(p_deg)}", fill=(255, 255, 255), font=font_small, anchor="rm")
        draw.text((cx+105, py), f"{abs(p_deg)}", fill=(255, 255, 255), font=font_small, anchor="lm")
    draw.line([(cx-120, cy), (cx-40, cy)], fill=(255, 160, 20), width=10)
    draw.line([(cx+40, cy), (cx+120, cy)], fill=(255, 160, 20), width=10)
    draw.ellipse([cx-15, cy-15, cx+15, cy+15], fill=(255, 160, 20))
    draw.text((cx, cy-r+60), "STANDBY ADI", fill=(240, 240, 245), font=font_dial, anchor="mm")
    cx, cy = 1536, 512
    draw.ellipse([cx-r-20, cy-r-20, cx+r+20, cy+r+20], fill=(15, 16, 18), outline=(50, 55, 60), width=8)
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(12, 14, 16))
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        nx = cx + int((r - 70) * math.cos(angle))
        ny = cy + int((r - 70) * math.sin(angle))
        draw.text((nx, ny), str(i), fill=(245, 245, 250), font=font_hdr, anchor="mm")
        tx1 = cx + int((r - 20) * math.cos(angle))
        ty1 = cy + int((r - 20) * math.sin(angle))
        tx2 = cx + int((r - 45) * math.cos(angle))
        ty2 = cy + int((r - 45) * math.sin(angle))
        draw.line([(tx1, ty1), (tx2, ty2)], fill=(245, 245, 250), width=4)
    draw.rectangle([cx+50, cy-40, cx+220, cy+40], fill=(5, 6, 8), outline=(80, 85, 90), width=2)
    draw.text((cx+135, cy), "29.92", fill=(240, 240, 245), font=font_dial, anchor="mm")
    draw.text((cx, cy+120), "ALTITUDE\nFEET", fill=(210, 215, 220), font=font_small, anchor="mm", align="center")
    cx, cy = 1024, 1536
    draw.ellipse([cx-r-20, cy-r-20, cx+r+20, cy+r+20], fill=(15, 16, 18), outline=(50, 55, 60), width=8)
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(12, 14, 16))
    speeds = [(60, 40), (80, 70), (100, 105), (150, 160), (200, 210), (250, 260), (300, 305), (350, 350), (400, 395), (450, 435)]
    for spd, ang_deg in speeds:
        angle = math.radians(ang_deg - 90)
        nx = cx + int((r - 70) * math.cos(angle))
        ny = cy + int((r - 70) * math.sin(angle))
        draw.text((nx, ny), str(spd), fill=(245, 245, 250), font=font_dial, anchor="mm")
        tx1 = cx + int((r - 20) * math.cos(angle))
        ty1 = cy + int((r - 20) * math.sin(angle))
        tx2 = cx + int((r - 45) * math.cos(angle))
        ty2 = cy + int((r - 45) * math.sin(angle))
        draw.line([(tx1, ty1), (tx2, ty2)], fill=(245, 245, 250), width=4)
    draw.text((cx, cy-120), "AIRSPEED\nKNOTS", fill=(210, 215, 220), font=font_small, anchor="mm", align="center")
    img.save(os.path.join(tex_dir, "B2_Standby_Instruments.png"))
    print("Generated B2_Standby_Instruments.png")

def make_metal():
    size = 1024
    arr = np.full((size, size, 3), [130, 135, 142], dtype=np.float32)
    streak = np.random.normal(0, 12.0, (size, 1, 3))
    streak = np.tile(streak, (1, size, 1))
    noise = np.random.normal(0, 4.0, (size, size, 3))
    arr = np.clip(arr + streak + noise, 0, 255).astype(np.uint8)
    img = Image.fromarray(arr)
    img.save(os.path.join(tex_dir, "B2_Metal_Brushed_Diffuse.png"))
    print("Generated B2_Metal_Brushed_Diffuse.png")

def make_caution_lenses():
    size = 512
    arr_a = np.full((size, size, 3), [40, 28, 12], dtype=np.float32)
    noise_a = np.random.normal(0, 2.0, (size, size, 3))
    img_a = Image.fromarray(np.clip(arr_a + noise_a, 0, 255).astype(np.uint8))
    draw_a = ImageDraw.Draw(img_a)
    font = get_font(36)
    draw_a.rectangle([10, 10, size-10, size-10], outline=(70, 50, 20), width=6)
    draw_a.text((size//2, size//2), "CAUTION", fill=(75, 52, 22), font=font, anchor="mm")
    img_a.save(os.path.join(tex_dir, "B2_Caution_Amber_Diffuse.png"))
    arr_r = np.full((size, size, 3), [42, 14, 14], dtype=np.float32)
    noise_r = np.random.normal(0, 2.0, (size, size, 3))
    img_r = Image.fromarray(np.clip(arr_r + noise_r, 0, 255).astype(np.uint8))
    draw_r = ImageDraw.Draw(img_r)
    draw_r.rectangle([10, 10, size-10, size-10], outline=(80, 25, 25), width=6)
    draw_r.text((size//2, size//2), "WARNING", fill=(80, 25, 25), font=font, anchor="mm")
    img_r.save(os.path.join(tex_dir, "B2_Caution_Red_Diffuse.png"))
    print("Generated B2_Caution_Amber_Diffuse.png and B2_Caution_Red_Diffuse.png")

if __name__ == "__main__":
    make_cockpit_dark()
    make_bezel()
    make_pedestal()
    make_glareshield()
    make_standby()
    make_metal()
    make_caution_lenses()
    print("ALL AUTHENTIC 2048x2048 TEXTURES GENERATED SUCCESSFULLY!")
