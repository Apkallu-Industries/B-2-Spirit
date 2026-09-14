-- Master Ordnance Personalization Registry
-- Central registry for delivery-system-aware weapon personalization

local registry = {
    profiles = {},
    adapters = {},
}

-- Load Profiles
local script_dir = (debug and debug.getinfo and debug.getinfo(1).source:match("@?(.*[\\/])")) or ""
local profiles_to_load = { "MOAB", "GBU31" }

for _, name in ipairs(profiles_to_load) do
    local ok, prof = pcall(dofile, script_dir .. "profiles/" .. name .. ".lua")
    if ok and prof and prof.id then
        registry.profiles[prof.id] = prof
    end
end

-- Query weapons authorized for a specific aircraft and delivery method
function registry.get_authorized_weapons(aircraft_name, delivery_mode)
    local authorized = {}
    for weapon_id, profile in pairs(registry.profiles) do
        if profile.supported_deliveries and profile.supported_deliveries[delivery_mode] then
            table.insert(authorized, profile)
        end
    end
    return authorized
end

return registry
