ViewSettings = ViewSettings or {}
SnapViews = SnapViews or {}

local function create_b2_views()
    return {
        Cockpit = {
            [1] = { -- Default Pilot Eye (Left Seat)
                CameraViewAngleLimits  = {20.000000, 140.000000},
                CameraAngleLimits      = {160.000000, -85.000000, 90.000000},
                EyePoint               = {0.050000, 0.100000, 0.000000},
                Limits6DOF             = {x = {-0.60, 0.60}, y = {-0.40, 0.40}, z = {-0.50, 0.50}, roll = 90.000000},
                AllowBinocular         = true,
                CameraAngleRestriction = {use_angles = false},
            },
        },
        Chase = {
            LocalPoint      = {-28.000000, 6.000000, 0.000000},
            Angles          = {0.000000, 0.000000},
        },
        Arcade = {
            LocalPoint      = {-32.000000, 7.500000, 0.000000},
            Angles          = {0.000000, 0.000000},
        },
    }
end

ViewSettings["B-2_Spirit"] = create_b2_views()
ViewSettings["B-2 Spirit"]  = create_b2_views()
ViewSettings["B-2A"]        = create_b2_views()

local function create_b2_snapviews()
    local snap = {}
    for i = 1, 13 do
        snap[i] = {
            viewAngle = 80.0,
            hAngle    = 0.0,
            vAngle    = -4.0,
            x_trans   = 6.80,  -- Pilot seat forward
            y_trans   = 1.85,  -- Pilot seat eye height
            z_trans   = -0.65, -- Pilot seat left of center
            rollAngle = 0.0,
        }
    end
    -- SnapView 13 is default cockpit view
    snap[13] = {
        viewAngle = 85.0,
        hAngle    = 0.0,
        vAngle    = -4.0,
        x_trans   = 6.80,
        y_trans   = 1.85,
        z_trans   = -0.65,
        rollAngle = 0.0,
    }
    -- SnapView 9 is Mission Commander (Right Seat)
    snap[9] = {
        viewAngle = 85.0,
        hAngle    = 0.0,
        vAngle    = -4.0,
        x_trans   = 6.80,
        y_trans   = 1.85,
        z_trans   = 0.65, -- Right seat
        rollAngle = 0.0,
    }
    return snap
end

SnapViews["B-2_Spirit"] = create_b2_snapviews()
SnapViews["B-2 Spirit"]  = create_b2_snapviews()
SnapViews["B-2A"]        = create_b2_snapviews()
