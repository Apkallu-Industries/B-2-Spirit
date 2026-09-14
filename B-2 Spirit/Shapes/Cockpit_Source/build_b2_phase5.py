from __future__ import annotations

import math
from pathlib import Path

import bpy
from mathutils import Vector


SOURCE_DIR = Path(__file__).resolve().parent
OUTPUT_BLEND = SOURCE_DIR / "B2_DCS_Cockpit_Phase5_Audit.blend"
OUTPUT_RENDER = SOURCE_DIR / "B2_DCS_Cockpit_Phase5_Audit.png"


def reset_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name: str, color: tuple[float, float, float, float], *, metallic: float = 0.0,
             roughness: float = 0.5, emission: tuple[float, float, float, float] | None = None,
             emission_strength: float = 0.0) -> bpy.types.Material:
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    assert bsdf is not None
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = emission
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def box(name: str, location: tuple[float, float, float], size: tuple[float, float, float],
        mat: bpy.types.Material, *, bevel: float = 0.0,
        parent: bpy.types.Object | None = None) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.object
    assert obj is not None
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("Edge radii", "BEVEL")
        modifier.width = bevel
        modifier.segments = 3
        modifier.limit_method = "ANGLE"
    if parent:
        obj.parent = parent
    return obj


def cylinder(name: str, location: tuple[float, float, float], radius: float, depth: float,
             mat: bpy.types.Material, *, rotation: tuple[float, float, float] = (math.pi / 2, 0, 0),
             parent: bpy.types.Object | None = None) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=radius, depth=depth, location=location,
                                        rotation=rotation)
    obj = bpy.context.object
    assert obj is not None
    obj.name = name
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Soft edge", "BEVEL")
    bevel.width = min(radius * 0.22, 0.006)
    bevel.segments = 2
    if parent:
        obj.parent = parent
    return obj


def text(name: str, body: str, location: tuple[float, float, float], size: float,
         mat: bpy.types.Material, *, parent: bpy.types.Object | None = None,
         align: str = "CENTER") -> bpy.types.Object:
    curve = bpy.data.curves.new(name, "FONT")
    curve.body = body
    curve.align_x = align
    curve.align_y = "CENTER"
    curve.size = size
    curve.extrude = 0.001
    curve.resolution_u = 4
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    obj.location = location
    # Text normally faces +Z; this turns it toward the seated crew at -Y.
    obj.rotation_euler = (math.pi / 2, 0, 0)
    curve.materials.append(mat)
    if parent:
        obj.parent = parent
    return obj


def face_camera(obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()



# Audit revision: standalone visual generator. Local X right, Y forward, Z up.
# Dimensions are modelling estimates; no DCS export or runtime changes.
import json

SYSTEM_TABS = ['FUEL', 'FCH', 'ELEC', 'ECS', 'ENG']
PAGE_TREE = {'SYSTEM': SYSTEM_TABS, 'FCH': ['HYD', 'FCS'],
             'BOTTOM': ['RECD', 'STAT', 'AVIN', 'DISK'],
             'CDU': ['COMM', 'NAV', 'IFF', 'RNAV', 'FPLN', 'WPN', 'INDX', 'PWR'],
             'COMM': ['COMM1', 'COMM2', 'HF', 'CIPHER', 'LINK 16', 'RADIO SET']}


def group(name, location=(0, 0, 0), parent=None, evidence='ESTIMATED_FROM_REFERENCE'):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    obj.location = location
    obj['provenance'] = evidence
    obj['dimensions_status'] = 'ESTIMATED_FROM_REFERENCE'
    return obj


def b(name, loc, size, mat, parent, bevel=.004):
    obj = box(name, loc, size, M[mat], parent=parent, bevel=bevel)
    obj['provenance'] = 'ESTIMATED_FROM_REFERENCE'
    return obj


def label(name, value, x, z, parent, size=.012, mat='white', y=-.068):
    obj = text(name, value, (x, y, z), size, M[mat], parent=parent)
    obj['provenance'] = 'REFERENCE_BACKED'
    return obj


def knob(name, x, z, parent):
    pivot = group(name + '_PIVOT', (x, -.075, z), parent)
    cylinder(name, (0, 0, 0), .018, .025, M['metal'], parent=pivot)
    b(name+'_index', (0, -.015, .008), (.003, .002, .015), 'white', pivot)
    hit(name, (0, 0, 0), (.045, .035, .045), pivot)


def hit(name, loc, size, parent):
    obj = b('CLICK_'+name, loc, size, 'button', parent, 0)
    obj.hide_render = True
    obj.hide_set(True)
    obj['provenance'] = 'SIMULATION_ABSTRACTION'
    obj['control_id'] = name
    obj['runtime_binding'] = 'UNASSIGNED'


def key(name, x, z, parent, legend='', width=.026):
    b(name+'_socket', (x, -.058, z), (width+.007, .012, .029), 'bezel', parent)
    b(name, (x, -.069, z), (width, .015, .022), 'button', parent)
    if legend:
        label(name+'_legend', legend, x, z, parent, .009, y=-.078)
    hit(name, (x, -.076, z), (width, .02, .023), parent)


def screws(parent, w, h):
    for i, (x,z) in enumerate([(-w/2+.012,-h/2+.012),(w/2-.012,-h/2+.012),
                                (-w/2+.012,h/2-.012),(w/2-.012,h/2-.012)]):
        cylinder(parent.name+'_screw_'+str(i), (x,-.06,z), .005, .004, M['metal'], parent=parent)
        b(parent.name+'_slot_'+str(i), (x,-.063,z), (.006,.001,.0015), 'bezel', parent)


def line(name, x1,z1,x2,z2,parent,mat='green', y=-.052):
    length = math.hypot(x2-x1,z2-z1)
    obj = b(name, ((x1+x2)/2,y,(z1+z2)/2), (length,.001,.0012),mat,parent,0)
    obj.rotation_euler.y = -math.atan2(z2-z1,x2-x1)


def grid(name,x,z,cols,rows,parent,step=.014):
    for i in range(cols+1):
        line(name+'_v'+str(i),x+i*step,z,x+i*step,z-rows*step,parent)
    for i in range(rows+1):
        line(name+'_h'+str(i),x,z-i*step,x+cols*step,z-i*step,parent)


def attitude(parent, amber=False):
    b('ATTITUDE_SKY',(0,-.049,.035),(.16,.002,.09),'amber' if amber else 'blue',parent)
    b('ATTITUDE_GROUND',(0,-.049,-.035),(.16,.002,.05),'brown',parent)
    for i in range(-3,4):
        line('PITCH_'+str(i),-.028,i*.015,.028,i*.015,parent,'white')
    line('ATTITUDE_WING_L',-.05,0,-.015,-.01,parent,'amber')
    line('ATTITUDE_WING_R',.015,-.01,.05,0,parent,'amber')
    label('HEADING','030   060   090',0,.104,parent,.012,'green',-.053)
    label('STAT','STAT',0,-.122,parent,.013,'green',-.053)


def mdu(name, loc, page):
    unit = group(name,loc,ROOT,'REFERENCE_BACKED')
    unit['initial_page'] = page
    unit['page_switchable'] = True
    unit['key_order'] = 'TOP/BOTTOM left to right; LEFT/RIGHT top to bottom'
    b(name+'_housing',(0,.008,0),(.35,.076,.35),'panel',unit,.016)
    # Four rim pieces leave a real aperture, with glass behind the raised keys.
    for side in [-1,1]:
        b(name+'_rim_v'+str(side),(side*.157,-.043,0),(.036,.032,.31),'bezel',unit,.012)
        b(name+'_rim_h'+str(side),(0,-.043,side*.157),(.31,.032,.036),'bezel',unit,.012)
    b(name+'_GLASS',(0,-.043,0),(.28,.008,.28),'glass',unit,.015)
    page_root = group(name+'_PAGE_PREVIEW',(0,0,0),unit,'SIMULATION_ABSTRACTION')
    page_root['note']='Static separable preview, not live DCS instrumentation'
    group(name+'_RENDER_ANCHOR',(0,-.05,0),unit,'SIMULATION_ABSTRACTION')
    for i in range(5):
        v=(i-2)*.048
        for side,x,z in [('TOP',v,.156),('BOTTOM',v,-.156),('LEFT',-.156,-v),('RIGHT',.156,-v)]:
            key(f'{name}_{side}_{i+1:02}',x,z,unit)
    knob(name+'_DAY_NITE',-.148,.119,unit)
    screws(unit,.35,.35)
    if page in ['ENG','FCS']:
        for i,tab in enumerate(SYSTEM_TABS):
            label(name+'_TAB_'+tab,tab,(i-2)*.052,.121,page_root,.010,'green',-.053)
        label(name+'_BOTTOM','RECD  STAT  AVIN  DISK',0,-.122,page_root,.011,'green',-.053)
    if page=='ENG':
        for col in range(4):
            x=-.075+col*.05
            label(name+'_engine'+str(col),str(col+1),x,.085,page_root,.012,'green',-.053)
            for row in range(5):
                label(name+f'_value{col}_{row}','--',x,.06-row*.02,page_root,.011,'green',-.053)
        label(name+'_EMSP','EMSP1 OK   EMSP2 OK\nEMSP3 OK   EMSP4 OK',0,-.085,page_root,.010,'green',-.053)
    elif page=='FCS':
        label(name+'_FCH','HYD\n\nFCS',-.119,.05,page_root,.010,'green',-.053)
        label(name+'_blocks','FLT CTRL    AIR DATA',.012,.085,page_root,.010,'green',-.053)
        grid(name+'_FLT',-.08,.07,4,7,page_root)
        grid(name+'_AIR',.018,.07,4,5,page_root)
        label(name+'_rows','AOA\nSTATIC\nPT\nGLA\nAOS',.102,.04,page_root,.008,'green',-.053)
        for i in range(8):
            grid(name+'_surface'+str(i),-.102+i*.026,-.073,1,1,page_root,.018)
        label(name+'_rud','L RUD              R RUD',0,-.052,page_root,.010,'green',-.053)
    elif page=='FLIGHT':
        attitude(page_root)
    else:
        for i in range(36):
            a=i*math.tau/36
            line(name+'_compass'+str(i),.09*math.sin(a),.09*math.cos(a),.10*math.sin(a),.10*math.cos(a),page_root)
        label(name+'_north','N',0,.113,page_root,.014,'green',-.053)
        for x1,z1,x2,z2 in [(-.025,-.012,0,.012),(0,.012,.025,-.012),(.025,-.012,-.025,-.012)]:
            line(name+'_aircraft',x1,z1,x2,z2,page_root,'amber')
    return unit


def flight_setting(loc, station):
    p=group('FLIGHT_SETTING_PANEL_'+station,loc,ROOT,'REFERENCE_BACKED')
    b('FLIGHT_SETTING_BODY',(0,0,0),(.35,.09,.21),'panel',p,.013)
    for i,s in enumerate(['BARO','CMD ALT','RALT SET','A/S SET']):
        key('FSP_'+station+'_'+s.replace(' ','_'),-.125,.067-i*.044,p,s,.057)
    for r,values in enumerate([['1','2','3'],['4','5','6'],['7','8','9'],['.','0','CLR']]):
        for c,s in enumerate(values): key('FSP_'+station+'_KEY_'+s,-.063+c*.044,.067-r*.044,p,s)
    for z,s in [(.043,'CRS SEL'),(-.055,'HDG SEL')]:
        knob('FSP_'+station+'_'+s.replace(' ','_'),.123,z,p)
        label('FSP_LABEL_'+s,s,.123,z+.029,p,.010)
    screws(p,.35,.21)


def cdu(loc):
    p=group('CDU',loc,ROOT,'REFERENCE_BACKED')
    b('CDU_BODY',(0,0,0),(.32,.10,.45),'panel',p,.015)
    b('CDU_GLASS',(0,-.054,.09),(.24,.008,.20),'glass',p,.008)
    for i,s in enumerate(PAGE_TREE['COMM']):
        label('CDU_PAGE_'+s,s,0,.164-i*.03,p,.012,'green',-.062)
        for side in [-1,1]: key(f'CDU_LSK_{side}_{i+1}',side*.14,.164-i*.03,p,width=.02)
    for r,values in enumerate([['1','2','3'],['4','5','6'],['7','8','9'],['-','0','.']]):
        for c,s in enumerate(values): key('CDU_NUM_'+s,-.115+c*.037,-.044-r*.04,p,s,.026)
    for i,s in enumerate(['CLR']+PAGE_TREE['CDU']):
        key('CDU_'+s,.018+(i%3)*.047,-.044-(i//3)*.042,p,s,.039)
    knob('CDU_BRT',.11,-.185,p)
    screws(p,.32,.45)


def build():
    global M, ROOT
    # Use a fresh scene; preserve any open aircraft scene and its data.
    scene=bpy.data.scenes.new('B2_PHASE5_AUDIT')
    bpy.context.window.scene=scene
    colors={'panel':(.075,.085,.09,1),'bezel':(.018,.021,.024,1),
            'button':(.22,.24,.25,1),'metal':(.4,.42,.43,1),'white':(.8,.82,.74,1),
            'green':(.08,.7,.19,1),'amber':(.7,.39,.07,1),'blue':(.025,.09,.28,1),
            'brown':(.22,.09,.035,1),'glass':(.004,.012,.009,1),'red':(.55,.018,.012,1)}
    M={k:material('MAT_'+k,v,roughness=.19 if k=='glass' else .5,
                  emission=v if k in ['green','amber','blue','brown'] else None,
                  emission_strength=.7) for k,v in colors.items()}
    ROOT=group('B2_COCKPIT_MASTER')
    ROOT['coordinate_system']='X right, Y forward, Z up; metres; not exterior aligned'
    ROOT['audit']='User supplied thirteen-frame reference audit; static art reconstruction'
    ROOT['menu_tree']=json.dumps(PAGE_TREE)
    # Right station captured in detail; left duplication explicitly remains estimated.
    for side in [-1,1]:
        station= 'R' if side==1 else 'L'
        for dx,page,tag in [(-.37,'ENG','SYSTEM'),(0,'FLIGHT','CENTER'),(.37,'FCS','OUTER')]:
            unit=mdu('MDU_'+station+'_'+tag,(side*.82+side*dx,.90,1.46),page)
            if side==-1: unit['provenance']='ESTIMATED_FROM_REFERENCE'
        mdu('MDU_'+station+'_LOWER',(side*.82,.88,1.09),'NAV')['provenance']='ESTIMATED_FROM_REFERENCE' if side==-1 else 'REFERENCE_BACKED'
        flight_setting((side*.45,.88,1.16), station)
    cid=group('CID',(0,.87,1.40),ROOT,'REFERENCE_BACKED_INFERRED')
    cid['identification']='Probable CID; 8x10-class ratio, installed scale estimated'
    b('CID_HOUSING',(0,.025,0),(.45,.16,.46),'panel',cid,.018)
    b('CID_GLASS',(0,-.06,.01),(.36,.01,.288),'glass',cid,.01)
    preview=group('CID_PAGE_PREVIEW',(0,-.02,.04),cid,'SIMULATION_ABSTRACTION')
    attitude(preview,True)
    label('CID_SYSTEM_PREVIEW','--  --  --  --\n--  --  --  --',0,-.11,cid,.019,'amber',-.071)
    screws(cid,.45,.46)
    cdu((1.40,.86,.99))
    # Emergency gear appearance and lower panel outline, not system simulation.
    guard=group('GEAR_EMERGENCY',(.266,.82,1.48),ROOT,'REFERENCE_BACKED')
    b('GEAR_BACK',(0,0,0),(.065,.07,.17),'bezel',guard)
    for z in [-.06,-.03,0,.03,.06]:
        b('GEAR_WARNING',(0,-.041,z),(.06,.003,.013),'amber',guard)
    b('GEAR_RED_HANDLE',(0,-.066,0),(.036,.04,.06),'red',guard,.009)
    hit('GEAR_EMERGENCY',(0,-.066,0),(.04,.05,.07),guard)
    lower=group('CENTER_MECHANICAL_CONTROLS',(0,.84,1.00),ROOT)
    b('CENTER_LOWER_BODY',(0,0,0),(.43,.1,.27),'panel',lower)
    for i in range(5):
        knob('CENTER_SELECTOR_'+str(i),-.17+i*.085,-.055,lower)
        cylinder('CENTER_TOGGLE_'+str(i),(-.17+i*.085,-.08,.08),.006,.05,M['metal'],parent=lower)
        grid('CENTER_SCHEMATIC_'+str(i),-.2+i*.085,.025,1,1,lower,.055)
    b('MAIN_PANEL',(0,1.02,1.24),(3.20,.13,.86),'panel',ROOT,.035)
    b('GLARESHIELD',(0,.91,1.73),(3.3,.43,.09),'bezel',ROOT,.025)
    b('FLOOR',(0,-.2,.20),(3.35,2.8,.08),'panel',ROOT)
    for side in [-1,1]:
        seat=group('PILOT_SEAT' if side==-1 else 'MISSION_COMMANDER_SEAT',(side*.82,-.65,.56),ROOT)
        b('SEAT_PAN',(0,0,0),(.49,.49,.13),'bezel',seat,.04)
        b('SEAT_BACK',(0,-.23,.37),(.49,.13,.68),'bezel',seat,.04)
        b('SEAT_HEADREST',(0,-.23,.77),(.30,.15,.20),'panel',seat,.04)
        group('PILOT_EYE' if side==-1 else 'MISSION_COMMANDER_EYE',(side*.82,-.68,1.65),ROOT)
        b('SIDE_CONSOLE_'+str(side),(side*1.53,-.12,.58),(.22,1.5,.23),'panel',ROOT)
        cylinder('CONTROL_COLUMN_'+str(side),(side*.82,-.10,.64),.023,.43,M['metal'],rotation=(0,0,0),parent=ROOT)
        b('CONTROL_GRIP_'+str(side),(side*.82,-.1,.90),(.08,.13,.13),'bezel',ROOT,.02)
    b('THROTTLE_BASE',(0,-.1,.55),(.31,.65,.2),'panel',ROOT)
    for i in range(4):
        b('THROTTLE_STEM_'+str(i),(-.105+i*.07,-.08,.75),(.016,.03,.20),'metal',ROOT)
        b('THROTTLE_GRIP_'+str(i),(-.105+i*.07,-.08,.86),(.05,.09,.04),'bezel',ROOT)
    world=bpy.data.worlds.new('Audit World'); scene.world=world; world.use_nodes=True
    world.node_tree.nodes['Background'].inputs['Color'].default_value=(.15,.18,.22,1)
    world.node_tree.nodes['Background'].inputs['Strength'].default_value=.5
    light=bpy.data.lights.new('Panel softbox','AREA'); light.energy=450; light.shape='RECTANGLE'; light.size=4
    obj=bpy.data.objects.new('Panel softbox',light); scene.collection.objects.link(obj)
    obj.location=(0,-1,2.7); face_camera(obj,(0,.9,1.2))
    cam=bpy.data.cameras.new('Audit front'); cam.lens=38
    obj=bpy.data.objects.new('Audit front',cam); scene.collection.objects.link(obj)
    obj.location=(0,-3.4,2.05); face_camera(obj,(0,.8,1.22)); scene.camera=obj
    scene.render.engine='BLENDER_EEVEE_NEXT'; scene.render.resolution_x=1800; scene.render.resolution_y=1000
    scene.render.resolution_percentage=100; scene.render.image_settings.file_format='PNG'
    scene.render.filepath=str(OUTPUT_RENDER)
    scene['limitations']='Estimated dimensions and opposite station; static display previews; unbound click volumes'
    objects=list(scene.objects)
    assert len([o for o in objects if o.get('page_switchable')])==8
    assert len([o for o in objects if o.name.startswith('CLICK_MDU_') and '_DAY_NITE' not in o.name])==160
    assert len({o.get('control_id') for o in objects if o.get('control_id')})==len([o for o in objects if o.get('control_id')])
    for o in objects:
        if 'provenance' not in o: o['provenance']='ESTIMATED_FROM_REFERENCE'
    manifest={'menus':PAGE_TREE,'limitations':scene['limitations'],'objects':len(objects),
              'components':[{'name':o.name,'provenance':o.get('provenance')} for o in objects if o.type=='EMPTY']}
    OUTPUT_BLEND.with_suffix('.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    bpy.ops.wm.save_as_mainfile(filepath=str(OUTPUT_BLEND))
    bpy.ops.render.render(write_still=True)
    print('AUDIT VALIDATION PASSED:',len(objects),'objects; 8 MDUs; 160 bezel click targets')


if __name__=='__main__':
    build()


