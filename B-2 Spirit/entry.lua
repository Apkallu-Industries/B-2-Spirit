local self_ID = "B-2_Spirit"
print(">>> [B-2 Spirit] Loading entry.lua...")

declare_plugin(self_ID,
{
    displayName     = _("B-2 Spirit (Flyable)"),
    shortName       = "B-2_Spirit",
    developerName   = "Apkallu Industries",

    image           = "FC3.bmp",
    installed       = true,
    dirName         = current_mod_path,
    fileMenuName    = _("B-2 Spirit"),
    update_id       = "B-2_Spirit",

    version         = "0.0.1v",
    state           = "installed",
    info            = _("Northrop Grumman B-2 Spirit Stealth Strategic Heavy Bomber (Flyable Mod)."),

    encyclopedia_path = current_mod_path .. '/Encyclopedia',

    InputProfiles =
    {
        ["B-2_Spirit"] = current_mod_path .. '/Input/B-2_Spirit',
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
            name = _("B-2 Spirit (Flyable)"),
            type = "B-2_Spirit",
        },
    },      
})

mount_vfs_texture_path(current_mod_path ..  "/Theme/ME")
mount_vfs_texture_path(current_mod_path ..  "/Textures")
mount_vfs_texture_path(current_mod_path ..  "/Textures/Cockpit_Donor")
mount_vfs_texture_path(current_mod_path ..  "/Textures/Cockpit_Audit")
mount_vfs_texture_path(current_mod_path ..  "/Textures/Weapons")
mount_vfs_texture_path(current_mod_path ..  "/Cockpit/Scripts/IndicationTextures")
mount_vfs_texture_path("Bazar/Textures/AvionicsCommon")
mount_vfs_model_path(current_mod_path ..  "/Shapes")
mount_vfs_liveries_path(current_mod_path ..  "/Liveries")

local support_cockpit = current_mod_path .. '/Cockpit/Scripts/'

-- Register flyable human cockpit contract
make_flyable('B-2_Spirit', support_cockpit, nil, current_mod_path .. '/comm.lua')

-- Load custom heavy ordnance definitions (FROZEN / ISOLATED for boot stability)
-- dofile(current_mod_path .. "/Weapons/B2_Heavy_Ordnance.lua")

-- Load aircraft descriptor and register with DCS database
dofile(current_mod_path .. "/B-2.lua")

-- Load view settings and apply only to registered unit type
dofile(current_mod_path .. "/Views.lua")
make_view_settings('B-2_Spirit', ViewSettings, SnapViews)

plugin_done()

