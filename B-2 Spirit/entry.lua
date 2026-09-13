declare_plugin("B-2 Spirit by Apkallu Industries",
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
    load_immediately = true,

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
            name = _("B-2 Spirit (Flyable)"),
            type = "B-2_Spirit",
        },
    },      
})

mount_vfs_texture_path(current_mod_path ..  "/Theme/ME")
mount_vfs_texture_path(current_mod_path ..  "/Textures")
mount_vfs_texture_path("Bazar/Textures/AvionicsCommon")
mount_vfs_model_path(current_mod_path ..  "/Shapes")
mount_vfs_liveries_path(current_mod_path ..  "/Liveries")

local support_cockpit = current_mod_path .. '/Cockpit/Scripts/'

dofile(current_mod_path .. "/Views.lua")
dofile(current_mod_path .. "/B-2.lua")
make_view_settings('B-2_Spirit', ViewSettings, SnapViews)

make_flyable('B-2_Spirit', support_cockpit, nil, current_mod_path .. '/comm.lua')

plugin_done()
