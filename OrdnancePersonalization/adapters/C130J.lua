-- C-130J-30 Super Hercules Ordnance Personalization Adapter
-- Delivery Mode: CARGO_DROP (Loadmaster Palletized Extraction / CARP Release)
--
-- NOTE: In the official DCS C-130J, the MOAB is handled through the internal cargo
-- bay loadmaster system with drogue chute extraction rather than a conventional pylon.
-- This adapter connects the personalized visual/material layer to the cargo asset pipeline.

local C130J_Adapter = {
    aircraft_name = "C-130J-30",
    delivery_mode = "CARGO_DROP",
}

-- Cargo Asset Descriptor for C-130J Loadmaster System
C130J_Adapter.cargo_asset = {
    id           = "GBU_43_MOAB_CARGO",
    name         = "GBU-43/B MOAB (Personalized Palletized Cargo)",
    shape_name   = "GBU-43_MOAB",
    weight_kg    = 9797.6,
    cargo_type   = "AIRDROP_CONTAINER",
    extraction   = "DROGUE_CHUTE",
    slot_binding = "SLOT_01",
    textures = {
        diffuse  = "MOAB_Slot1_Diffuse",
        roughmet = "MOAB_Slot1_RoughMet",
        normal   = "MOAB_Slot1_Normal",
    },
}

function C130J_Adapter.get_cargo_definition()
    return C130J_Adapter.cargo_asset
end

return C130J_Adapter
