--[[
    B-2 Spirit Stealth Bomber — Stores Management System (SMS) Display
    Copilot / Mission Commander MFD 7 (Upper Right Display)
    Renders dual Common Rotary Launcher (CRL) carousels, station status, and weapon telemetry
--]]

dofile(LockOn_Options.script_path.."B2_MFD_def.lua")

-- Base clipping mask and background
create_rect("SMS_BG", 0.0, 0.0, 0.98, 0.98, "SCREEN_BG")

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOP HEADER / OSB ROW
-- ═══════════════════════════════════════════════════════════════════════════════
create_text("SMS_TITLE", "SMS  ROTARY BAYS", 0.0, 0.90, "CYAN", "CenterCenter", strdefs_MED)
create_rect("SMS_HEADER_LINE", 0.0, 0.85, 0.92, 0.003, "DARK_GREEN")

create_text("SMS_OSB_JETT", "JETT", -0.80, 0.94, "RED",   "CenterCenter", strdefs_SML)
create_text("SMS_OSB_STEP", "STEP", -0.40, 0.94, "GREEN", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_ARM",  "ARM",   0.00, 0.94, "GREEN", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_MODE", "MODE",  0.40, 0.94, "GREEN", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_MENU", "MENU",  0.80, 0.94, "WHITE", "CenterCenter", strdefs_SML)

-- Master Arm & System Ready
create_rect("SMS_ARM_BOX", 0.0, 0.77, 0.38, 0.08, "DIAL_BG")
create_text("SMS_ARM_STAT", "MASTER ARM: SAFE", 0.0, 0.77, "AMBER", "CenterCenter", strdefs_SML)

-- ═══════════════════════════════════════════════════════════════════════════════
-- DUAL ROTARY BOMB BAY CAROUSELS (CRL-1 LEFT & CRL-2 RIGHT)
-- ═══════════════════════════════════════════════════════════════════════════════

local bays = {
    { name = "LEFT CRL (BAY 1)",  cx = -0.46, cy = 0.22, pfx = "BAY1", doors = "L BAY: CLOSED" },
    { name = "RIGHT CRL (BAY 2)", cx =  0.46, cy = 0.22, pfx = "BAY2", doors = "R BAY: CLOSED" }
}

for _, b in ipairs(bays) do
    -- Bay Frame
    create_rect(b.pfx .. "_BOX", b.cx, b.cy, 0.44, 0.54, "DIAL_BG")
    create_text(b.pfx .. "_LBL", b.name, b.cx, b.cy + 0.23, "WHITE", "CenterCenter", strdefs_SML)
    
    -- Bay Door status
    create_text(b.pfx .. "_DOOR", b.doors, b.cx, b.cy - 0.23, "GREEN", "CenterCenter", strdefs_SML)
    
    -- Center Carousel Hub
    create_line(b.pfx .. "_HUB_RING", {
        {-0.06, -0.06}, {0.06, -0.06}, {0.06, 0.06}, {-0.06, 0.06}, {-0.06, -0.06}
    }, b.cx, b.cy, "DARK_GREEN", 0.003)
    create_text(b.pfx .. "_HUB_TXT", "CRL", b.cx, b.cy, "GREEN", "CenterCenter", strdefs_TINY)

    -- 8 Rotary Stations arranged in circle (radius = 0.13)
    local r_sta = 0.13
    for s = 1, 8 do
        local angle = (s - 1) * (2 * math.pi / 8) - (math.pi / 2)
        local sx = b.cx + r_sta * math.cos(angle)
        local sy = b.cy + r_sta * math.sin(angle)
        
        -- Station Circle / Box
        local col = (s == 1) and "GREEN" or "DARK_GREEN"
        create_line(b.pfx .. "_STA_" .. s, {
            {-0.028, -0.028}, {0.028, -0.028}, {0.028, 0.028}, {-0.028, 0.028}, {-0.028, -0.028}
        }, sx, sy, col, 0.002)
        
        -- Station Number
        local txt_col = (s == 1) and "WHITE" or "GREEN"
        create_text(b.pfx .. "_NUM_" .. s, string.format("%d", s), sx, sy, txt_col, "CenterCenter", strdefs_TINY)
    end
end

-- Station 1 (Active Steerpoint / Drop Release) Crosshair Highlight
create_line("BAY1_SEL_CROSS_H", {{-0.05, 0}, {0.05, 0}}, -0.46, 0.09, "GREEN", 0.002)
create_line("BAY1_SEL_CROSS_V", {{0, -0.05}, {0, 0.05}}, -0.46, 0.09, "GREEN", 0.002)

-- ═══════════════════════════════════════════════════════════════════════════════
-- ACTIVE WEAPON SELECTION & TELEMETRY
-- ═══════════════════════════════════════════════════════════════════════════════

create_rect("SMS_INFO_BOX", 0.0, -0.25, 0.90, 0.28, "DIAL_BG")
create_text("SMS_WEAPON_NAME", "ACTIVE: GBU-31(V)1/B JDAM 2000 LB", 0.0, -0.15, "GREEN", "CenterCenter", strdefs_MED)
create_text("SMS_WEAPON_GUIDE", "GUIDANCE: GPS / INS AIDING  [VALID]", 0.0, -0.22, "WHITE", "CenterCenter", strdefs_SML)

create_text("SMS_WEAPON_FUSE", "FUZE: NOSE / TAIL  DELAY 1", -0.40, -0.29, "CYAN", "LeftCenter", strdefs_SML)
create_text("SMS_WEAPON_TTR",  "TIME TO RELEASE: --:--",   0.40, -0.29, "GREEN", "RightCenter", strdefs_SML)

create_text("SMS_WEAPON_INVN", "TOTAL STORES REMAINING: 16 / 16", -0.40, -0.35, "WHITE", "LeftCenter", strdefs_SML)
create_text("SMS_WEAPON_PROF", "PROFILE: LEVEL BOMBING FL350",   0.40, -0.35, "CYAN",  "RightCenter", strdefs_SML)

-- ═══════════════════════════════════════════════════════════════════════════════
-- BOTTOM NAVIGATION & STATUS ROW
-- ═══════════════════════════════════════════════════════════════════════════════

create_rect("SMS_FOOTER_LINE", 0.0, -0.78, 0.92, 0.003, "DARK_GREEN")

create_text("SMS_STATUS_BAY",  "BAYS: NORMAL",      -0.42, -0.84, "GREEN", "LeftCenter",  strdefs_SML)
create_text("SMS_STATUS_JETT", "EMERG JETT: READY",  0.00, -0.84, "GREEN", "CenterCenter",strdefs_SML)
create_text("SMS_STATUS_BIT",  "BIT: GO",            0.42, -0.84, "GREEN", "RightCenter", strdefs_SML)

create_text("SMS_OSB_BOT_1", "DATA", -0.80, -0.94, "WHITE", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_BOT_2", "PROF", -0.40, -0.94, "GREEN", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_BOT_3", "CTRL",  0.00, -0.94, "GREEN", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_BOT_4", "TGT",   0.40, -0.94, "GREEN", "CenterCenter", strdefs_SML)
create_text("SMS_OSB_BOT_5", "EXIT",  0.80, -0.94, "WHITE", "CenterCenter", strdefs_SML)
