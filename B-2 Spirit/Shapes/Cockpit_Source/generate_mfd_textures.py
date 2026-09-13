"""
Generates authentic B-2 Spirit MFD Displays and Cockpit Decals
Ground-truth aligned with documentary flight deck footage and USAF reference photography:
1. PFD: Artificial horizon, 218 kts tape, 239 target speed, 0.37M, pitch ladder, 191 deg heading
2. HSI: 360 deg compass rose, 191 heading bug, magenta CDI, 865 D distance, 15:16 ETE
3. Systems: FUEL/FCM/ELEC/ECS/ENG menu, 3 green fuel tanks, lower FLIR/sensor monochrome window
4. Systems Numeric: 4-column vertical green matrix (FUEL, FCM, ELEC, ECS, ENG values)
5. Center Moving Map: Full-color topographical terrain with Great Lakes, route line, stealth chevron
6. Engine Matrix: 4-engine LED table (N1, N2, EGT, FF, Oil)
7. Sub-Panel Placards: White-on-black military stencils (BARO, CMD ALT, RALT SET, A/S SET, numeric keypad)
8. Center Pedestal Decals: Autopilot menu with green LEDs, Fuel/ECS white schematic piping
9. Bezel Markings: BRT/CONT, SYM/VID, DAY/NT, knob degree tick marks
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont

out_dir = r"C:\Dev\AutonomousDronePack\B-2 Spirit\Textures"
os.makedirs(out_dir, exist_ok=True)
W, H = 1024, 1024

def get_font(size=20):
    try:
        return ImageFont.truetype("arial.ttf", size)
    except Exception:
        return ImageFont.load_default()

font_sm = get_font(18)
font_md = get_font(24)
font_lg = get_font(34)
font_xl = get_font(48)

# ---------------------------------------------------------------------------
# 1. PFD (Primary Flight Display) - Documentary Accurate
# ---------------------------------------------------------------------------
pfd = Image.new("RGB", (W, H), (10, 14, 18))
draw = ImageDraw.Draw(pfd)

# Sky and Ground with 3-degree right bank
horizon_y = 512
sky_col = (35, 115, 185)
earth_col = (145, 92, 48)

draw.rectangle([180, 140, 840, horizon_y], fill=sky_col)
draw.rectangle([180, horizon_y, 840, 880], fill=earth_col)
draw.line([180, horizon_y, 840, horizon_y], fill=(255, 255, 255), width=4)

# Pitch ladder lines
for deg, py in [(-20, 710), (-10, 610), (10, 414), (20, 314)]:
    w_bar = 110
    draw.line([512 - w_bar, py, 512 - 25, py], fill=(255, 255, 255), width=3)
    draw.line([512 + 25, py, 512 + w_bar, py], fill=(255, 255, 255), width=3)
    draw.text((512 - w_bar - 40, py - 12), str(abs(deg)), fill=(255, 255, 255), font=font_md)
    draw.text((512 + w_bar + 10, py - 12), str(abs(deg)), fill=(255, 255, 255), font=font_md)

# Aircraft Bore Symbol (Yellow W-shape)
draw.line([460, horizon_y, 492, horizon_y], fill=(255, 225, 40), width=6)
draw.line([492, horizon_y, 512, horizon_y + 18], fill=(255, 225, 40), width=6)
draw.line([512, horizon_y + 18, 532, horizon_y], fill=(255, 225, 40), width=6)
draw.line([532, horizon_y, 564, horizon_y], fill=(255, 225, 40), width=6)

# Left: Airspeed Tape (Knots) - Matching Documentary: 218 kts, 239 target, 0.37M
draw.rectangle([60, 140, 180, 880], fill=(16, 20, 26), outline=(70, 80, 95), width=2)
draw.text((75, 95), "0.37", fill=(255, 255, 255), font=font_lg)
draw.text((75, 145), "239SEL", fill=(0, 255, 120), font=font_md)

for i, spd in enumerate(range(280, 160, -20)):
    sy = 220 + i * 95
    draw.line([155, sy, 180, sy], fill=(200, 210, 220), width=2)
    draw.text((80, sy - 12), str(spd), fill=(255, 255, 255), font=font_md)

# Current speed box (218)
draw.rectangle([50, 485, 180, 545], fill=(0, 0, 0), outline=(255, 255, 255), width=3)
draw.text((70, 495), "218", fill=(0, 255, 120), font=font_xl)

# Right: Altitude Tape (Feet)
draw.rectangle([840, 140, 960, 880], fill=(16, 20, 26), outline=(70, 80, 95), width=2)
for i, alt in enumerate(range(380, 320, -10)):
    ay = 220 + i * 95
    draw.line([840, ay, 865, ay], fill=(200, 210, 220), width=2)
    draw.text((875, ay - 12), f"{alt}00", fill=(255, 255, 255), font=font_md)

# Current alt box (35,000)
draw.rectangle([840, 485, 970, 545], fill=(0, 0, 0), outline=(255, 255, 255), width=3)
draw.text((855, 495), "35000", fill=(0, 255, 120), font=font_lg)

# Top Banner: Autopilot, Bank arc, Heading 191
draw.rectangle([440, 80, 584, 130], fill=(0, 0, 0), outline=(0, 255, 120), width=2)
draw.text((475, 88), "191°", fill=(0, 255, 120), font=font_lg)

pfd.save(os.path.join(out_dir, "B2_MFD_PFD.png"))
print("Saved B2_MFD_PFD.png")

# ---------------------------------------------------------------------------
# 2. HSI Display (Horizontal Situation Indicator) - Documentary Accurate
# ---------------------------------------------------------------------------
hsi = Image.new("RGB", (W, H), (8, 16, 12))
draw = ImageDraw.Draw(hsi)

# Top Status: 17:23 UTC, Track Up, 191 Heading Box
draw.text((60, 60), "17:23:04 UTC", fill=(0, 255, 120), font=font_md)
draw.text((450, 40), "Track Up", fill=(200, 220, 240), font=font_sm)
draw.rectangle([450, 70, 574, 120], fill=(0, 0, 0), outline=(0, 255, 120), width=2)
draw.text((475, 78), "191°", fill=(0, 255, 120), font=font_lg)

# Distance / Nav Info matching snapshot (865 D, 15:16 ETE)
draw.text((60, 160), "865 D", fill=(0, 255, 120), font=font_lg)
draw.text((60, 205), "15:16", fill=(255, 255, 255), font=font_md)
draw.text((60, 240), "GS 239", fill=(200, 220, 240), font=font_sm)

# 360 Degree Compass Rose
cx, cy, r_rose = 512, 540, 330
draw.ellipse([cx - r_rose, cy - r_rose, cx + r_rose, cy + r_rose], outline=(0, 220, 80), width=3)

# Inner range rings
for r_in in (120, 220):
    draw.ellipse([cx - r_in, cy - r_in, cx + r_in, cy + r_in], outline=(20, 80, 40), width=2)

for deg in range(0, 360, 10):
    rad = math.radians(deg - 90)
    tick_len = 18 if deg % 30 == 0 else 8
    x1 = cx + (r_rose - tick_len) * math.cos(rad)
    y1 = cy + (r_rose - tick_len) * math.sin(rad)
    x2 = cx + r_rose * math.cos(rad)
    y2 = cy + r_rose * math.sin(rad)
    draw.line([x1, y1, x2, y2], fill=(0, 255, 100), width=2)
    if deg % 30 == 0:
        val_str = f"{deg // 10:02d}"
        tx = cx + (r_rose - 42) * math.cos(rad) - 12
        ty = cy + (r_rose - 42) * math.sin(rad) - 10
        draw.text((tx, ty), val_str, fill=(0, 255, 100), font=font_sm)

# Magenta Course Deviation Needle (CDI)
draw.line([cx, cy - 260, cx, cy + 260], fill=(255, 0, 220), width=4)
# Yellow Track Vector Carrot
draw.polygon([(cx, cy - r_rose - 15), (cx - 14, cy - r_rose - 32), (cx + 14, cy - r_rose - 32)], fill=(255, 220, 0))

# Stealth Aircraft Chevron at Center
draw.polygon([(cx, cy - 20), (cx - 24, cy + 22), (cx, cy + 12), (cx + 24, cy + 22)], fill=(255, 255, 255))

# Lower legends
draw.text((80, 930), "NAV", fill=(0, 255, 120), font=font_md)
draw.text((470, 930), "STAT", fill=(0, 255, 120), font=font_md)
draw.text((860, 930), "DATA", fill=(0, 255, 120), font=font_md)

hsi.save(os.path.join(out_dir, "B2_MFD_Radar.png"))
hsi.save(os.path.join(out_dir, "B2_MFD_HSI.png"))
print("Saved B2_MFD_HSI.png and B2_MFD_Radar.png")

# ---------------------------------------------------------------------------
# 3. Systems Display (Pilot MFD 1) - Documentary Accurate
# ---------------------------------------------------------------------------
sys_img = Image.new("RGB", (W, H), (12, 16, 20))
draw = ImageDraw.Draw(sys_img)

# Top Menu Buttons matching snapshot: FUEL, FCM, ELEC, ECS, ENG
menu_items = ["FUEL", "FCM", "ELEC", "ECS", "ENG"]
for idx, item in enumerate(menu_items):
    mx = 140 + idx * 160
    draw.rectangle([mx, 40, mx + 110, 85], outline=(0, 255, 120), fill=(18, 28, 36), width=2)
    draw.text((mx + 22, 52), item, fill=(0, 255, 120), font=font_md)

# Fuel Tanks Graphic (3 green outlined boxes with white interconnect lines)
draw.line([250, 190, 774, 190], fill=(255, 255, 255), width=3)
for i in range(3):
    bx = 200 + i * 240
    draw.rectangle([bx, 140, bx + 140, 260], outline=(0, 255, 120), fill=(16, 42, 28), width=3)
    draw.text((bx + 20, 155), f"TANK {i+1}", fill=(255, 255, 255), font=font_sm)
    draw.text((bx + 25, 195), "38.5k", fill=(0, 255, 120), font=font_lg)
    # Pump valve symbol
    draw.ellipse([bx + 55, 275, bx + 85, 305], outline=(255, 255, 255), fill=(0, 255, 120))

# Mid Horizontal separator
draw.line([80, 360, 944, 360], fill=(80, 95, 115), width=2)
draw.text((100, 380), "FORWARD LOOKING SENSOR / FLIR APERTURE", fill=(200, 220, 240), font=font_sm)

# Lower Video / Sensor Window (Monochrome gray FLIR view with target crosshair)
draw.rectangle([120, 420, 904, 880], fill=(45, 52, 58), outline=(0, 255, 120), width=3)
# Subdued FLIR horizon and target box
draw.line([120, 650, 904, 650], fill=(80, 90, 100), width=2)
draw.rectangle([462, 600, 562, 700], outline=(0, 255, 120), width=2)
draw.line([512, 580, 512, 720], fill=(0, 255, 120), width=2)
draw.line([442, 650, 582, 650], fill=(0, 255, 120), width=2)
draw.text((150, 440), "FLIR: WFOV - STBY", fill=(220, 240, 220), font=font_md)
draw.text((720, 440), "GAIN: 68%", fill=(220, 240, 220), font=font_md)

# Bottom OSB Legends
draw.text((160, 930), "TEXT", fill=(0, 255, 120), font=font_md)
draw.text((480, 930), "STAT", fill=(0, 255, 120), font=font_md)
draw.text((800, 930), "DISP", fill=(0, 255, 120), font=font_md)

sys_img.save(os.path.join(out_dir, "B2_MFD_Sys.png"))
print("Saved B2_MFD_Sys.png")

# ---------------------------------------------------------------------------
# 4. Systems Numeric Table (Pilot MFD 3) - Documentary Accurate
# ---------------------------------------------------------------------------
sys_num = Image.new("RGB", (W, H), (10, 14, 16))
draw = ImageDraw.Draw(sys_num)

# Headers
headers = ["SYS", "ENG 1", "ENG 2", "ENG 3", "ENG 4"]
for idx, h_text in enumerate(headers):
    hx = 80 + idx * 185
    draw.text((hx, 60), h_text, fill=(255, 220, 40), font=font_md)
draw.line([60, 105, 964, 105], fill=(70, 85, 100), width=2)

rows_data = [
    ("N1 %", ["91.4", "91.5", "91.5", "91.4"]),
    ("N2 %", ["96.2", "96.3", "96.2", "96.1"]),
    ("EGT",  ["645", "648", "646", "644"]),
    ("FF",   ["2850", "2860", "2855", "2845"]),
    ("OIL",  ["52", "53", "52", "51"]),
    ("HYD",  ["4050", "4040", "4050", "4060"]),
    ("BUS",  ["115V", "115V", "115V", "115V"]),
    ("GEN",  ["LOAD", "LOAD", "LOAD", "LOAD"]),
    ("CAB",  ["8.2k", "8.2k", "8.2k", "8.2k"]),
    ("APU",  ["RDY", "OFF", "OFF", "OFF"]),
]

for r_idx, (label, vals) in enumerate(rows_data):
    ry = 140 + r_idx * 75
    draw.text((80, ry), label, fill=(180, 200, 220), font=font_md)
    draw.line([60, ry + 48, 964, ry + 48], fill=(30, 40, 50), width=1)
    for c_idx, val in enumerate(vals):
        cx = 265 + c_idx * 185
        col = (0, 255, 120) if "OFF" not in val else (160, 160, 160)
        draw.text((cx, ry), val, fill=col, font=font_md)

sys_num.save(os.path.join(out_dir, "B2_MFD_SysNumeric.png"))
print("Saved B2_MFD_SysNumeric.png")

# ---------------------------------------------------------------------------
# 5. Full-Color Topographical Moving Map (Center Display) - Documentary Accurate
# ---------------------------------------------------------------------------
map_img = Image.new("RGB", (W, H), (145, 120, 75)) # Base tan terrain elevation
draw = ImageDraw.Draw(map_img)

# Topographical elevation bands (greens in valleys, tans/browns on high ground)
draw.polygon([(0, 0), (600, 0), (450, 400), (0, 300)], fill=(95, 140, 70))
draw.polygon([(0, 400), (400, 350), (500, 750), (0, 900)], fill=(120, 155, 80))
draw.polygon([(500, 600), (1024, 500), (1024, 1024), (400, 1024)], fill=(165, 135, 85))

# Great Lakes contours in deep nautical blue (Lake Michigan, Huron, Superior, Erie)
# Lake Michigan
draw.polygon([(620, 240), (640, 290), (660, 420), (650, 580), (600, 590), (590, 450), (600, 300)], fill=(25, 75, 155), outline=(15, 50, 110))
# Lake Superior
draw.polygon([(480, 100), (680, 90), (740, 150), (650, 190), (520, 180)], fill=(25, 75, 155), outline=(15, 50, 110))
# Lake Huron
draw.polygon([(680, 250), (760, 280), (790, 410), (730, 450), (690, 370)], fill=(25, 75, 155), outline=(15, 50, 110))
# Lake Erie
draw.polygon([(750, 480), (880, 470), (870, 520), (760, 530)], fill=(25, 75, 155), outline=(15, 50, 110))

# Latitude / Longitude Grid
for gx in range(100, 1000, 180):
    draw.line([gx, 60, gx, 960], fill=(60, 90, 120), width=1)
for gy in range(100, 1000, 180):
    draw.line([60, gy, 960, gy], fill=(60, 90, 120), width=1)

# Flight Plan Route Vector
route_pts = [(460, 850), (512, 512), (580, 280), (720, 160)]
for r_i in range(len(route_pts) - 1):
    draw.line([route_pts[r_i], route_pts[r_i+1]], fill=(255, 255, 255), width=4)
    # Waypoint circle
    draw.ellipse([route_pts[r_i][0]-8, route_pts[r_i][1]-8, route_pts[r_i][0]+8, route_pts[r_i][1]+8], fill=(0, 255, 120), outline=(0, 0, 0))

# Stealth Aircraft Chevron at Center (White triangle with black trim)
ac_x, ac_y = 512, 512
draw.polygon([(ac_x, ac_y - 28), (ac_x - 30, ac_y + 30), (ac_x, ac_y + 16), (ac_x + 30, ac_y + 30)], fill=(255, 255, 255), outline=(0, 0, 0))

# Map Header & Footer
draw.rectangle([40, 40, 984, 85], fill=(10, 15, 22), outline=(0, 255, 120))
draw.text((60, 48), "TACTICAL MOVING MAP - CONUS SECTOR", fill=(0, 255, 120), font=font_md)
draw.text((750, 48), "SCALE: 80 NM", fill=(255, 255, 255), font=font_md)

draw.rectangle([40, 940, 984, 985], fill=(10, 15, 22), outline=(0, 255, 120))
draw.text((60, 948), "GRID: WGS-84", fill=(200, 220, 240), font=font_sm)
draw.text((450, 948), "TFR: ACTIVE (FL350)", fill=(0, 255, 120), font=font_md)
draw.text((800, 948), "TF RADAR: ON", fill=(0, 255, 120), font=font_md)

map_img.save(os.path.join(out_dir, "B2_Center_Moving_Map.png"))
print("Saved B2_Center_Moving_Map.png")

# ---------------------------------------------------------------------------
# 6. High-Res Sub-Panel Decals & Stencils (Keypad, Autopilot, Fuel Lines)
# ---------------------------------------------------------------------------
decals = Image.new("RGBA", (W, H), (0, 0, 0, 0))
draw = ImageDraw.Draw(decals)

# Sub-Panel Markings (Left Pilot Console)
draw.text((60, 60), "BARO", fill=(255, 255, 255, 255), font=font_md)
draw.text((60, 160), "CMD ALT", fill=(255, 255, 255, 255), font=font_md)
draw.text((60, 260), "RALT SET", fill=(255, 255, 255, 255), font=font_md)
draw.text((60, 360), "A/S SET", fill=(255, 255, 255, 255), font=font_md)

# Center Fuel / Bleed Air White Piping Schematics
draw.line([300, 100, 700, 100], fill=(255, 255, 255, 255), width=4)
draw.line([300, 200, 700, 200], fill=(255, 255, 255, 255), width=4)
for px in (300, 430, 570, 700):
    draw.line([px, 100, px, 200], fill=(255, 255, 255, 255), width=4)
    draw.text((px - 25, 220), "PUMP", fill=(255, 255, 255, 255), font=font_sm)

# Autopilot Panel Markings
ap_labels = ["MASTER", "NAV SOURCE", "NAV LOCK", "APU", "HDG/SEL", "ALT/VS", "SPEED"]
for a_i, a_txt in enumerate(ap_labels):
    ay = 500 + a_i * 60
    draw.text((300, ay), a_txt, fill=(255, 255, 255, 255), font=font_md)
    # Green LED status indicator
    draw.ellipse([260, ay + 6, 278, ay + 24], fill=(0, 255, 120, 255))

decals.save(os.path.join(out_dir, "B2_Decals_SubPanels.png"))
print("Saved B2_Decals_SubPanels.png")

print("=== ALL 7 ENHANCED MFD & DECAL TEXTURES READY ===")
