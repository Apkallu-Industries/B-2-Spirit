-- B-2 Spirit Public-Reference Cockpit: Pilot Station (Left Seat)
-- DCS Space: {X = Forward, Y = Height/Up, Z = Right(+)/Left(-)}
local cockpit_local_point = {6.050000, 1.180000, -0.574000}

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

ViewSettings = {
    Cockpit = {
        [1] = b2_cockpit_view,
    },
    Chase = {
        LocalPoint      = {-28.000000, 6.000000, 0.000000},
        AnglesDefault   = {180.000000, -8.000000},
    },
    Arcade = {
        LocalPoint      = {-32.000000, 7.500000, 0.000000},
        AnglesDefault   = {0.000000, -8.000000},
    },
}

-- Support keyed format for make_view_settings compatibility
ViewSettings["B-2_Spirit"] = ViewSettings
ViewSettings["B-2 Spirit"]  = ViewSettings
ViewSettings["B-2A"]        = ViewSettings

local function make_snap_slot()
    local snap = {}
    for i = 1, 13 do
        snap[i] = {
            viewAngle = 88.0,
            hAngle    = 0.0,
            vAngle    = -8.4,
            x_trans   = 0.247411,
            y_trans   = -0.067882,
            z_trans   = 0.0,
            rollAngle = 0.0,
        }
    end
    -- SnapView 13: Default Cockpit View (Pilot Center Seat Looking at Glass Cockpit)
    snap[13] = {
        viewAngle = 88.7,
        hAngle    = 0.0,
        vAngle    = -8.4,
        x_trans   = 0.247411,
        y_trans   = -0.067882,
        z_trans   = 0.0,
        rollAngle = 0.0,
    }
    return snap
end

SnapViews = {
    [1] = make_snap_slot(),
}

SnapViews["B-2_Spirit"] = SnapViews
SnapViews["B-2 Spirit"]  = SnapViews
SnapViews["B-2A"]        = SnapViews
