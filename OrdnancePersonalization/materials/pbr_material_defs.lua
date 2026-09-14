-- DCS World PBR Material Channel Definitions for Ordnance Personalization
-- Channel 0:  Diffuse Map (RGB Color + Alpha)
-- Channel 1:  Normal Map (Tangent Space Normals)
-- Channel 13: RoughMet Map (Red=AO, Green=Roughness, Blue=Metalness)

pbr_material_defs = {
    channels = {
        DIFFUSE  = 0,
        NORMAL   = 1,
        ROUGHMET = 13,
    },
    mediums = {
        marker = {
            name = "Felt-Tip Marker",
            roughness = 0.41,
            metalness = 0.0,
            normal_bevel = 0.0,
            description = "High sheen, solvent ink bleed",
        },
        chalk = {
            name = "Chalk / China Marker",
            roughness = 0.96,
            metalness = 0.0,
            normal_bevel = 0.0,
            description = "Porous, dry matte scatter",
        },
        grease = {
            name = "Grease Pencil",
            roughness = 0.55,
            metalness = 0.0,
            normal_bevel = 0.03,
            description = "Waxy impasto tactile relief",
        },
        stencil = {
            name = "Spray Stencil",
            roughness = 0.63,
            metalness = 0.0,
            normal_bevel = 0.04,
            description = "Proud +0.03mm paint elevation",
        },
    },
}

return pbr_material_defs
