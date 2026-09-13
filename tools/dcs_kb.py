#!/usr/bin/env python3
"""
DCS Modding Knowledge Base (DCS-Modding-DB)
Persistent MongoDB repository for DCS aircraft modding knowledge, EDM specifications,
Blender rigging, Lua cockpit display rendering, avionics telemetry, and troubleshooting.
"""

import sys
import os
import argparse
import datetime
from typing import List, Dict, Any, Optional
from pymongo import MongoClient, TEXT, ASCENDING

MONGO_URI = os.getenv("DCS_MONGO_URI", "mongodb://localhost:27017/")
DB_NAME   = "dcs_modding_kb"

def get_db():
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=3000)
    # Test connection
    client.server_info()
    return client[DB_NAME]

def init_indexes(db):
    """Ensure indexes exist for fast search and unique IDs."""
    db.knowledge_items.create_index([("topic_id", ASCENDING)], unique=True)
    db.knowledge_items.create_index([
        ("title", TEXT),
        ("overview", TEXT),
        ("rules", TEXT),
        ("tags", TEXT)
    ])
    db.code_snippets.create_index([("snippet_id", ASCENDING)], unique=True)
    db.code_snippets.create_index([("tags", ASCENDING)])
    db.gotchas.create_index([("gotcha_id", ASCENDING)], unique=True)

# ═══════════════════════════════════════════════════════════════════════════════
# SEED KNOWLEDGE ITEMS
# ═══════════════════════════════════════════════════════════════════════════════

SEED_ARTICLES: List[Dict[str, Any]] = [
    {
        "topic_id": "edm_connector_rigging",
        "category": "3D_MODELING_AND_EDM",
        "title": "Blender 4.2 EDM Connector Rigging & Export Rules",
        "tags": ["blender", "edm", "connector", "rigging", "cockpit", "mfd", "empty", "export"],
        "overview": (
            "DCS ccIndicator screen rendering requires connectors inside the cockpit EDM. "
            "In Blender, each screen requires a 3-Empty coordinate frame with specific EDMProps properties."
        ),
        "rules": [
            "Every DCS screen requires 3 Empty objects: <NAME>_CENTER, <NAME>_DOWN, <NAME>_RIGHT.",
            "CRITICAL: In Blender 4.2 LTS using the io_EDM exporter, each Empty MUST have "
            "`empty.EDMProps.SPECIAL_TYPE = 'CONNECTOR'` set. If left as 'NORMAL', the exporter omits them.",
            "Center points: _CENTER defines the origin (0,0) of the screen.",
            "Axes: _DOWN defines the -Y screen vector (bottom edge). _RIGHT defines the +X screen vector (right edge).",
            "Screen aspect ratio is dictated by the relative distance between _CENTER->_DOWN and _CENTER->_RIGHT.",
            "In device_init.lua, indicators reference the connector triple: {'B2_MFD1_CENTER', 'B2_MFD1_DOWN', 'B2_MFD1_RIGHT'}.",
            "Fine-tuning screen position/rotation/scale can also be done in Lua via the secondary table in device_init.lua: "
            "{sx_l, sy_l, sz_l, sh, sw, rz_l, rx_l, ry_l} without re-exporting the 3D model."
        ],
        "gotchas": [
            "If connectors are not registered with SPECIAL_TYPE='CONNECTOR', the screen will not attach to the 3D surface.",
            "DCS process must be restarted or mission reloaded (Shift+R) after exporting new EDM files; DCS caches models in VRAM."
        ],
        "verified_examples": [
            "Shapes/Cockpit_Source/B2_Spirit_Cockpit_Centered.blend",
            "c:/Dev/AutonomousDronePack/B-2 Spirit/Cockpit/Scripts/device_init.lua"
        ]
    },
    {
        "topic_id": "ccindicator_vector_rendering",
        "category": "COCKPIT_INDICATORS",
        "title": "DCS ccIndicator Vector Rendering (FOV vs MILLYRADIANS)",
        "tags": ["lua", "indicator", "ccindicator", "fov", "millyradians", "cemeshpoly", "cetechpoly", "cestringpoly"],
        "overview": (
            "DCS ccIndicator system renders 2D HUD and glass cockpit MFD symbology directly onto 3D EDM surfaces. "
            "There are two coordinate modes: FOV (normalized -1 to +1) and MILLYRADIANS (angular deflection)."
        ),
        "rules": [
            "SetScale(FOV) is optimal for modern MFD glass displays: screen center is (0,0) and edges are roughly -1.0 to +1.0.",
            "Use `aspect = GetAspect()` to dynamically scale elements for non-square aspect ratio screens.",
            "ceMeshPoly: Used for vector polygons, circles, rings, and clipping masks.",
            "ceSimpleLineObject: Used for vector line drawings, compass ticks, needles, ladders, and reticles.",
            "ceStringPoly: Used for text rendering. Requires .stringdefs, .material, .alignment, and optional .formats.",
            "ceTexPoly: Used for textured quads (e.g. ADI sphere ball, compass wheel atlas, custom gauge needles).",
            "set_circle(obj, radius): Creates a solid circle. set_circle(obj, outer_r, inner_r, arc_deg, segments): creates an arc/ring.",
            "Clipping Masks: Use `h_clip_relation = h_clip_relations.INCREASE_IF_LEVEL` on mask geometry, then render clipped elements with DECREASE_IF_LEVEL or COMPARE."
        ],
        "gotchas": [
            "If fonts do not appear, ensure font materials are defined using MakeFont or point to standard DCS fonts like FUI/Fonts/font_arial_17.",
            "If MFD_OPACITY parameter is 0, elements using opacity controllers will be invisible (pitch black). Default it to 1.0."
        ],
        "verified_examples": [
            "c:/Dev/AutonomousDronePack/B-2 Spirit/Cockpit/Scripts/B2_MFD_def.lua",
            "c:/Dev/AutonomousDronePack/B-2 Spirit/Cockpit/Scripts/PFD/adi_page.lua",
            "c:/Dev/AutonomousDronePack/B-2 Spirit/Cockpit/Scripts/EICAS/eng_page.lua"
        ]
    },
    {
        "topic_id": "dynamic_mfd_dials_make_dial",
        "category": "COCKPIT_INDICATORS",
        "title": "Dynamic Arc Dials & Rotating Needles Architecture (MakeDial)",
        "tags": ["mfd", "dial", "needle", "gauge", "rpm", "egt", "makedial", "vector", "indicators"],
        "overview": (
            "Architecture for creating round aircraft engine/fuel gauges with curved arc rims, tick marks, "
            "rotating needles, and live digital readouts, pioneered in JAS-39 and expanded for B-2 Spirit 4-engine matrix."
        ),
        "rules": [
            "A dynamic dial consists of: Root (ceSimple) -> Background disc (ceMeshPoly) -> Outer Arc (ceMeshPoly set_circle) -> Ticks (ceSimpleLineObject) -> Hub -> Needle Root (ceSimple with rotate_using_parameter) -> Needle line/tex -> Digital text.",
            "Needle Rotation Gain: `rot_gain = -math.rad(total_arc_degrees) / max_value`.",
            "Tick Mark Calculation: `angle = start_deg + (i * step)`; `x = radius * math.cos(math.rad(-angle + 90))`, `y = radius * math.sin(math.rad(-angle + 90))`, `init_rot = {-angle}`.",
            "Use distinct military color schemes: Green (nominal), Amber (caution/EGT), Cyan (labels/system headers), White (needles/units)."
        ],
        "gotchas": [
            "Ensure needle parent_element is the needle_root ceSimple so that the needle rotates around (0,0) of the dial, not the screen center."
        ],
        "verified_examples": [
            "B2_MFD_def.lua: MakeDial()",
            "EICAS/eng_page.lua: 4-engine RPM and EGT matrix"
        ]
    },
    {
        "topic_id": "lua_device_telemetry_piping",
        "category": "AVIONICS_AND_SYSTEMS",
        "title": "Avionics Lua Device & DCS Base Data Telemetry Piping",
        "tags": ["avionics", "lua", "telemetry", "get_base_data", "sensor_data", "parameters", "get_param_handle"],
        "overview": (
            "How to bridge DCS native C++ physics and sensor telemetry into the Lua indicator system. "
            "An avLuaDevice runs an update() loop and pumps parameters to get_param_handle()."
        ),
        "rules": [
            "Devices are declared in devices.lua and created in device_init.lua under creators[devices.AVIONICS] = {'avLuaDevice', ...}.",
            "Call `make_default_activity(update_rate)` in device script to run periodic updates (e.g. dt = 0.02 ~ 50Hz).",
            "Call `local sensor_data = get_base_data()` to access DCS aircraft state.",
            "Key sensor_data methods: getPitch(), getRoll(), getHeading(), getMagneticHeading(), getIndicatedAirSpeed(), getTrueAirSpeed(), getMachNumber(), getBarometricAltitude(), getRadarAltitude(), getVerticalVelocity(), getVerticalAcceleration(), getAngleOfAttack(), getEngineLeftRPM(), getEngineRightRPM(), getEngineLeftTemperatureBeforeTurbine(), getTotalFuelWeight(), getWOW_NoseLandingGear().",
            "Create parameter handles once at init: `local PARAM = get_param_handle('PARAM_NAME')`.",
            "Update parameter handles in update(): `PARAM:set(value)`."
        ],
        "gotchas": [
            "Heading from sensor_data.getHeading() is in radians. For degrees: `(360 - heading * 180 / math.pi) % 360`.",
            "Pitch from sensor_data.getPitch(): Nose up is negative pitch in some DCS coordinate systems; negate or scale according to indicator orientation."
        ],
        "verified_examples": [
            "Cockpit/Scripts/Systems/Avionics.lua",
            "JAS39 MFD/Device/MFD_Device.lua"
        ]
    },
    {
        "topic_id": "cockpit_materials_and_textures",
        "category": "MATERIALS_AND_SHADING",
        "title": "Cockpit EDM Material Channels & Texture Mounting Rules",
        "tags": ["materials", "textures", "pbr", "diffuse", "normal", "roughness", "entry_lua", "edm"],
        "overview": (
            "Cockpit models in DCS require explicit texture paths mounted in entry.lua and standardized "
            "material channels in Blender to render PBR details correctly."
        ),
        "rules": [
            "Mount cockpit texture directories in entry.lua using `mount_vfs_texture_archives('...')` or `mount_vfs_liveries_path('...')`.",
            "Ensure material names in Blender match texture filenames or use standard Principled BSDF nodes.",
            "Standard PBR cockpit suite: Diffuse (RGB), Roughness/Metallic (Greyscale), Normal map (DirectX tangent normal).",
            "All textures should be sized in powers of two (512, 1024, 2048, 4096) and preferably DDS (BC1/DXT1 for diffuse without alpha, BC3/DXT5 for diffuse with alpha, BC5 for normal maps, BC7 for high fidelity)."
        ],
        "gotchas": [
            "If cockpit surfaces render pure yellow/black checkerboard, DCS cannot find the texture name in mounted VFS paths."
        ],
        "verified_examples": [
            "c:/Dev/AutonomousDronePack/B-2 Spirit/entry.lua",
            "c:/Dev/AutonomousDronePack/B-2 Spirit/Textures/"
        ]
    }
]

SEED_SNIPPETS: List[Dict[str, Any]] = [
    {
        "snippet_id": "blender_connector_rigging_snippet",
        "title": "Blender 4.2 Python Script for Cockpit Screen Connectors",
        "language": "python",
        "tags": ["blender", "python", "connectors", "edm", "rigging"],
        "description": "Script to create the required 3-empty coordinate frame for DCS screens with SPECIAL_TYPE='CONNECTOR'.",
        "code": """import bpy

def add_screen_connector(name, center_pos, width, height):
    # Center Empty
    c = bpy.data.objects.new(f"{name}_CENTER", None)
    c.empty_display_type = 'PLAIN_AXES'
    c.empty_display_size = 0.05
    c.location = center_pos
    c.EDMProps.SPECIAL_TYPE = 'CONNECTOR'
    bpy.context.collection.objects.link(c)
    
    # Down Empty (-Y vector)
    d = bpy.data.objects.new(f"{name}_DOWN", None)
    d.empty_display_type = 'SINGLE_ARROW'
    d.empty_display_size = 0.03
    d.location = (center_pos[0], center_pos[1], center_pos[2] - height)
    d.EDMProps.SPECIAL_TYPE = 'CONNECTOR'
    bpy.context.collection.objects.link(d)
    
    # Right Empty (+X vector)
    r = bpy.data.objects.new(f"{name}_RIGHT", None)
    r.empty_display_type = 'SINGLE_ARROW'
    r.empty_display_size = 0.03
    r.location = (center_pos[0], center_pos[1] + width, center_pos[2])
    r.EDMProps.SPECIAL_TYPE = 'CONNECTOR'
    bpy.context.collection.objects.link(r)
    
    return c, d, r
"""
    },
    {
        "snippet_id": "device_init_screen_wiring",
        "title": "DCS device_init.lua Indicator Wiring with Fine-tuning Table",
        "language": "lua",
        "tags": ["lua", "device_init", "ccindicator", "wiring"],
        "description": "Wires an indicator to cockpit connectors with millimeter Lua coordinate correction.",
        "code": """indicators[#indicators + 1] = {"ccIndicator", LockOn_Options.script_path.."PFD/init.lua",
    nil, 
    {
        {"B2_MFD2_CENTER", "B2_MFD2_DOWN", "B2_MFD2_RIGHT"},
        {
            sx_l =  0.0000,   -- center position correction (+forward , -backward)
            sy_l =  0.0000,   -- center position correction (+up , -down)
            sz_l =  0.0000,   -- center position correction (-left , +right)
            sh   =  0.0000,   -- half height correction 
            sw   =  0.0000,   -- half width correction 
            rz_l =  0,        -- rotation correction z
            rx_l =  0,        -- rotation correction x
            ry_l =  0         -- rotation correction y
        }
    }
}
"""
    }
]

SEED_GOTCHAS: List[Dict[str, Any]] = [
    {
        "gotcha_id": "dcs_model_vram_caching",
        "title": "DCS Model Caching in RAM / VRAM",
        "symptom": "Cockpit or exterior 3D model changes in EDM file do not appear in DCS after exporting; old model persists.",
        "root_cause": "DCS caches all loaded EDM shapes in system memory and GPU VRAM during active missions.",
        "fix": "Restart the mission using Shift+R, reload the track/mission from the menu, or terminate DCS.exe and relaunch.",
        "tags": ["edm", "caching", "vram", "reload", "restart"]
    },
    {
        "gotcha_id": "blender_edm_export_empty_special_type",
        "title": "Blender EDM Exporter Missing Connectors",
        "symptom": "Connectors added in Blender do not appear in the exported .EDM binary and screens fail to attach.",
        "root_cause": "Blender io_EDM exporter checks `EDMProps.SPECIAL_TYPE == 'CONNECTOR'`. By default Blender empties have SPECIAL_TYPE='NORMAL'.",
        "fix": "Set `obj.EDMProps.SPECIAL_TYPE = 'CONNECTOR'` on every connector empty before exporting.",
        "tags": ["blender", "connector", "special_type", "edm"]
    },
    {
        "gotcha_id": "mfd_black_screen_opacity_zero",
        "title": "Black / Invisible Glass Cockpit Screens",
        "symptom": "Indicators are wired in device_init.lua but the screen in cockpit remains totally black.",
        "root_cause": "Element controllers check MFD_OPACITY or power parameters which default to 0.0 on cold start.",
        "fix": "Ensure Avionics.lua sets MFD_OPACITY to 1.0 on birth, or test with element_params without opacity clamp.",
        "tags": ["mfd", "opacity", "black_screen", "avionics", "lua"]
    }
]

# ═══════════════════════════════════════════════════════════════════════════════
# CLI & API FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def seed_db():
    db = get_db()
    init_indexes(db)
    
    art_count = 0
    for art in SEED_ARTICLES:
        art["updated_at"] = datetime.datetime.now(datetime.timezone.utc)
        art["version"] = 1
        db.knowledge_items.update_one({"topic_id": art["topic_id"]}, {"$set": art}, upsert=True)
        art_count += 1

    snip_count = 0
    for snip in SEED_SNIPPETS:
        snip["updated_at"] = datetime.datetime.now(datetime.timezone.utc)
        db.code_snippets.update_one({"snippet_id": snip["snippet_id"]}, {"$set": snip}, upsert=True)
        snip_count += 1

    gotcha_count = 0
    for g in SEED_GOTCHAS:
        g["updated_at"] = datetime.datetime.now(datetime.timezone.utc)
        db.gotchas.update_one({"gotcha_id": g["gotcha_id"]}, {"$set": g}, upsert=True)
        gotcha_count += 1

    print(f"[OK] Seeded DCS Modding DB in MongoDB: {art_count} articles, {snip_count} code snippets, {gotcha_count} gotchas.")

def search_db(query: str):
    db = get_db()
    regex = {"$regex": query, "$options": "i"}

    print(f"\n=======================================================")
    print(f"   DCS MODDING DB SEARCH: '{query}'")
    print(f"=======================================================\n")

    # Search articles
    articles = list(db.knowledge_items.find({
        "$or": [
            {"title": regex},
            {"overview": regex},
            {"rules": regex},
            {"tags": regex},
            {"topic_id": regex}
        ]
    }))

    print(f"--- Knowledge Articles ({len(articles)} matches) ---")
    for a in articles:
        print(f"  * [{a['topic_id']}] {a['title']} ({a.get('category', 'GENERAL')})")
        print(f"    Tags: {', '.join(a.get('tags', []))}")
        print(f"    {a['overview'][:120]}...\n")

    # Search snippets
    snippets = list(db.code_snippets.find({
        "$or": [
            {"title": regex},
            {"description": regex},
            {"code": regex},
            {"tags": regex}
        ]
    }))

    print(f"--- Code Snippets ({len(snippets)} matches) ---")
    for s in snippets:
        print(f"  * [{s['snippet_id']}] {s['title']} ({s.get('language', 'text')})")
        print(f"    {s.get('description', '')}\n")

    # Search gotchas
    gotchas = list(db.gotchas.find({
        "$or": [
            {"title": regex},
            {"symptom": regex},
            {"root_cause": regex},
            {"fix": regex},
            {"tags": regex}
        ]
    }))

    print(f"--- Gotchas & Troubleshooting ({len(gotchas)} matches) ---")
    for g in gotchas:
        print(f"  * [GOTCHA] {g['title']}")
        print(f"    Symptom: {g.get('symptom', '')}")
        print(f"    Fix: {g.get('fix', '')}\n")

def get_item(item_id: str):
    db = get_db()
    
    art = db.knowledge_items.find_one({"topic_id": item_id})
    if art:
        print(f"\n=======================================================")
        print(f"  {art['title']} [{art['topic_id']}]")
        print(f"  Category: {art.get('category', '')} | Tags: {', '.join(art.get('tags', []))}")
        print(f"=======================================================\n")
        print(f"OVERVIEW:\n{art['overview']}\n")
        print("RULES & SPECIFICATIONS:")
        for r in art.get("rules", []):
            print(f"  - {r}")
        if art.get("gotchas"):
            print("\nKNOWN GOTCHAS:")
            for g in art["gotchas"]:
                print(f"  ! {g}")
        if art.get("verified_examples"):
            print("\nVERIFIED REPOSITORY EXAMPLES:")
            for ex in art["verified_examples"]:
                print(f"  > {ex}")
        return

    snip = db.code_snippets.find_one({"snippet_id": item_id})
    if snip:
        print(f"\n=======================================================")
        print(f"  SNIPPET: {snip['title']} [{snip['snippet_id']}]")
        print(f"  Language: {snip.get('language', '')} | Tags: {', '.join(snip.get('tags', []))}")
        print(f"=======================================================\n")
        print(f"DESCRIPTION: {snip.get('description', '')}\n")
        print(snip['code'])
        return

    g = db.gotchas.find_one({"gotcha_id": item_id})
    if g:
        print(f"\n=======================================================")
        print(f"  TROUBLESHOOTING: {g['title']} [{g['gotcha_id']}]")
        print(f"=======================================================\n")
        print(f"SYMPTOM:\n  {g.get('symptom', '')}\n")
        print(f"ROOT CAUSE:\n  {g.get('root_cause', '')}\n")
        print(f"VERIFIED FIX:\n  {g.get('fix', '')}\n")
        return

    print(f"[!] Item '{item_id}' not found in knowledge_items, code_snippets, or gotchas.")

def list_items():
    db = get_db()
    print(f"\n=======================================================")
    print(f"   DCS MODDING DB — TOPICS & SNIPPETS INDEX")
    print(f"=======================================================\n")

    for cat in db.knowledge_items.distinct("category"):
        print(f"\n[{cat}]")
        for a in db.knowledge_items.find({"category": cat}):
            print(f"  • {a['topic_id']:<30} : {a['title']}")

    print(f"\n[REUSABLE CODE SNIPPETS]")
    for s in db.code_snippets.find():
        print(f"  • {s['snippet_id']:<30} : {s['title']} ({s.get('language', 'text')})")

    print(f"\n[TROUBLESHOOTING & GOTCHAS]")
    for g in db.gotchas.find():
        print(f"  • {g['gotcha_id']:<30} : {g['title']}")

def add_knowledge(topic_id, title, category, overview, rules_str, tags_str):
    db = get_db()
    rules = [r.strip() for r in rules_str.split(";") if r.strip()]
    tags = [t.strip().lower() for t in tags_str.split(",") if t.strip()]
    doc = {
        "topic_id": topic_id,
        "title": title,
        "category": category,
        "overview": overview,
        "rules": rules,
        "tags": tags,
        "updated_at": datetime.datetime.now(datetime.timezone.utc),
        "version": 1
    }
    db.knowledge_items.update_one({"topic_id": topic_id}, {"$set": doc}, upsert=True)
    print(f"[OK] Stored topic '{topic_id}' in DCS Modding DB.")

def stats():
    db = get_db()
    print(f"\nDatabase: {DB_NAME}")
    print(f"Knowledge Articles : {db.knowledge_items.count_documents({})}")
    print(f"Code Snippets      : {db.code_snippets.count_documents({})}")
    print(f"Troubleshooting    : {db.gotchas.count_documents({})}")

def main():
    parser = argparse.ArgumentParser(description="DCS Modding Knowledge Base CLI (MongoDB)")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("seed", help="Seed or update database with verified modding knowledge")
    
    search_p = subparsers.add_parser("search", help="Search knowledge base by keyword")
    search_p.add_argument("query", type=str, help="Search string")

    get_p = subparsers.add_parser("get", help="Retrieve an article, snippet, or gotcha by ID")
    get_p.add_argument("item_id", type=str, help="Topic/Snippet/Gotcha ID")

    subparsers.add_parser("list", help="List all topics and snippets")
    subparsers.add_parser("stats", help="Show database statistics")

    add_p = subparsers.add_parser("add", help="Add a new knowledge article")
    add_p.add_argument("--id", required=True, help="Unique topic ID")
    add_p.add_argument("--title", required=True, help="Title")
    add_p.add_argument("--cat", default="GENERAL", help="Category")
    add_p.add_argument("--overview", required=True, help="Overview summary")
    add_p.add_argument("--rules", default="", help="Semicolon-separated rules")
    add_p.add_argument("--tags", default="", help="Comma-separated tags")

    args = parser.parse_args()

    if args.command == "seed":
        seed_db()
    elif args.command == "search":
        search_db(args.query)
    elif args.command == "get":
        get_item(args.item_id)
    elif args.command == "list":
        list_items()
    elif args.command == "stats":
        stats()
    elif args.command == "add":
        add_knowledge(args.id, args.title, args.cat, args.overview, args.rules, args.tags)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
