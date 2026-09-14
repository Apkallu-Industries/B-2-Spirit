-- B-2 Spirit Public-Reference Cockpit: Pilot Station (Left Seat)
-- DCS Space: {X = Forward, Y = Height/Up, Z = Right(+)/Left(-)}
local cockpit_local_point = {6.560000, 2.100000, -0.650000}

local b2_cockpit_view = {
    CockpitLocalPoint      = cockpit_local_point,
    CameraViewAngleLimits  = {20.000000, 140.000000},
    CameraAngleRestriction = {false, 90.000000, 0.500000},
    CameraAngleLimits      = {200.000000, -80.000000, 110.000000},
    EyePoint               = {0.000000, 0.000000, 0.000000},
    limits_6DOF            = {x = {-0.300000, 0.400000}, y = {-0.250000, 0.300000}, z = {-0.350000, 0.550000}, roll = 45.000000},
    ShoulderSize           = 0.20,
    AllowBinocular         = true,
}

local b2_view_entry = {
    Cockpit = {
        [1] = b2_cockpit_view,
    },
    Chase = {
        LocalPoint    = {-28.000000, 6.000000, 0.000000},
        AnglesDefault = {180.000000, -8.000000},
    },
    Arcade = {
        LocalPoint    = {-32.000000, 7.500000, 0.000000},
        AnglesDefault = {0.000000, -8.000000},
    },
}

ViewSettings = {
    ["B-2_Spirit"] = b2_view_entry,
    ["B-2 Spirit"] = b2_view_entry,
    ["B-2A"]       = b2_view_entry,
    Cockpit        = b2_view_entry.Cockpit,
    Chase          = b2_view_entry.Chase,
    Arcade         = b2_view_entry.Arcade,
}

local function make_snap_slot()
    local snap = {}
    for i = 1, 13 do
        snap[i] = {
            viewAngle = 72.0,
            hAngle    = 0.0,
            vAngle    = -2.5,
            x_trans   = 0.0,
            y_trans   = 0.0,
            z_trans   = 0.0,
            rollAngle = 0.0,
        }
    end
    -- SnapView 9: Copilot / Mission Commander (Right Seat: +1.30m lateral)
    snap[9] = {
        viewAngle = 72.0,
        hAngle    = 0.0,
        vAngle    = -2.5,
        x_trans   = 0.0,
        y_trans   = 0.0,
        z_trans   = 1.300000,
        rollAngle = 0.0,
    }
    -- SnapView 11: Instrument Panel Inspection (Zoomed in on MDUs)
    snap[11] = {
        viewAngle = 55.0,
        hAngle    = 0.0,
        vAngle    = -10.0,
        x_trans   = 0.150000,
        y_trans   = -0.050000,
        z_trans   = 0.0,
        rollAngle = 0.0,
    }
    -- SnapView 12: HUD Forward Zoom
    snap[12] = {
        viewAngle = 40.0,
        hAngle    = 0.0,
        vAngle    = 0.0,
        x_trans   = 0.250000,
        y_trans   = 0.020000,
        z_trans   = 0.0,
        rollAngle = 0.0,
    }
    -- SnapView 13: Default Cockpit View (Pilot Left Seat Looking Forward through HUD)
    snap[13] = {
        viewAngle = 72.0,
        hAngle    = 0.0,
        vAngle    = -2.5,
        x_trans   = 0.0,
        y_trans   = 0.0,
        z_trans   = 0.0,
        rollAngle = 0.0,
    }
    return snap
end

local b2_snaps = {
    [1] = make_snap_slot(),
}

SnapViews = {
    ["B-2_Spirit"] = b2_snaps,
    ["B-2 Spirit"] = b2_snaps,
    ["B-2A"]       = b2_snaps,
    [1]            = b2_snaps[1],
}
