local log_file = io.open("C:/Users/danym/Saved Games/DCS/Logs/b2_spirit.log", "w")
local function b2_log(msg)
    if log_file then
        log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. tostring(msg) .. "\n")
        log_file:flush()
    end
end

b2_log("entry.lua: Starting module loading...")

local self_ID = "B-2 Spirit by Apkallu Industries"
declare_plugin(self_ID,
{
    displayName     = _("B-2 Spirit (Flyable)"),
    developerName   = "Apkallu Industries",

    image           = "FC3.bmp",
    installed       = true,
    dirName         = current_mod_path,
    fileMenuName    = _("B-2 Spirit"),

    version         = "0.0.1v",
    state           = "installed",
    info            = _("Northrop Grumman B-2 Spirit Stealth Strategic Heavy Bomber (Flyable Mod)."),

    encyclopedia_path = current_mod_path .. '/Encyclopedia',

    InputProfiles =
    {
        ["B-2_Spirit"] = current_mod_path .. '/Input/B-2 Spirit',
        ["B-2 Spirit"] = current_mod_path .. '/Input/B-2 Spirit',
    },

    Skins =
    {
        {
            name = _("B-2 Spirit"),
            dir  = "Theme"
        },
    },
    
    Missions =
    {
        {
            name = _("B-2 Spirit"),
            dir  = "Missions",
        },
    },      

    LogBook =
    {
        {
            name = _("B-2_Spirit"),
            type = "B-2_Spirit",
        },
        {
            name = _("B-2 Spirit"),
            type = "B-2 Spirit",
        },
    },      
})
b2_log("entry.lua: declare_plugin done.")

mount_vfs_texture_path(current_mod_path ..  "/Theme/ME")
mount_vfs_texture_path(current_mod_path ..  "/Textures")
mount_vfs_texture_path("Bazar/Textures/AvionicsCommon")
mount_vfs_model_path(current_mod_path ..  "/Shapes")
mount_vfs_model_path(current_mod_path ..  "/Cockpit/Shape")
mount_vfs_liveries_path(current_mod_path ..  "/Liveries")

local support_cockpit = current_mod_path .. '/Cockpit/Scripts/'

b2_log("entry.lua: Loading Views.lua...")
dofile(current_mod_path .. "/Views.lua")

b2_log("entry.lua: Loading B-2.lua...")
local ok, err = pcall(dofile, current_mod_path .. "/B-2.lua")
if not ok then
    b2_log("ERROR loading B-2.lua: " .. tostring(err))
else
    b2_log("entry.lua: B-2.lua loaded successfully.")
end

make_view_settings('B-2_Spirit', ViewSettings, SnapViews)

----------------------------------------------------------------------------------------
if MAC_flyable then
    b2_log("entry.lua: Calling MAC_flyable...")
    MAC_flyable('B-2_Spirit', support_cockpit, nil, current_mod_path .. '/comm.lua')
else
    b2_log("entry.lua: Calling make_flyable...")
    make_flyable('B-2_Spirit', support_cockpit, nil, current_mod_path .. '/comm.lua')
end
----------------------------------------------------------------------------------------
plugin_done()
b2_log("entry.lua: plugin_done called successfully.")
if log_file then log_file:close() end
