"""Texture, fit and export the audited cockpit. Blender 4.2 + EDM exporter.
Run from Blender background; uses the Phase5 Audit blend as immutable input.
Outputs a textured authoring blend, EDM candidate, maps and alignment report.
"""
import bpy, math, json, sys, re, addon_utils
import numpy as np
from pathlib import Path
from mathutils import Matrix, Vector

HERE=Path(__file__).resolve().parent
MOD=HERE.parents[1]
REPO=MOD.parent
OUT=HERE/'Production'
TEX=MOD/'Textures'/'Cockpit_Audit'
OUT.mkdir(exist_ok=True); TEX.mkdir(exist_ok=True)
EYE=Vector((6.05,.574,1.18))  # aircraft-space Blender; DCS = x,z,-y
FIT=Matrix(((0,.5,0,6.39),(-.7,0,0,0),(0,0,.7,-.10),(0,0,0,1)))


def log(*args): print(*args,flush=True)

def mesh_object(name,verts,faces,material,parent=None):
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces); mesh.update()
    obj=bpy.data.objects.new(name,mesh); bpy.context.scene.collection.objects.link(obj)
    obj.parent=parent
    if material: mesh.materials.append(material)
    obj['provenance']='SIMULATION_ABSTRACTION'
    return obj


def cube(name,loc,size,mat,parent=None,bevel=.004):
    verts=[(sx*size[0]/2,sy*size[1]/2,sz*size[2]/2) for sx,sy,sz in
           [(-1,-1,-1),(-1,-1,1),(-1,1,-1),(-1,1,1),(1,-1,-1),(1,-1,1),(1,1,-1),(1,1,1)]]
    obj=mesh_object(name,verts,[(0,4,6,2),(1,3,7,5),(0,1,5,4),(2,6,7,3),(0,2,3,1),(4,5,7,6)],mat,parent)
    obj.location=loc
    if bevel:
        mod=obj.modifiers.new('Surface edge radius','BEVEL');mod.width=bevel;mod.segments=3
    return obj


def tube(name,a,b,r,mat,parent=None,segments=12):
    direction=Vector(b)-Vector(a); length=direction.length
    verts=[]
    for z in [-length/2,length/2]:
        verts += [(r*math.cos(i*math.tau/segments),r*math.sin(i*math.tau/segments),z) for i in range(segments)]
    faces=[tuple(reversed(range(segments))),tuple(range(segments,2*segments))]
    faces += [(i,(i+1)%segments,(i+1)%segments+segments,i+segments) for i in range(segments)]
    obj=mesh_object(name,verts,faces,mat,parent)
    obj.location=(Vector(a)+Vector(b))/2; obj.rotation_euler=direction.to_track_quat('Z','Y').to_euler()
    for p in obj.data.polygons: p.use_smooth=len(p.vertices)==4
    return obj


def empty(name,loc,parent=None,connector=False):
    obj=bpy.data.objects.new(name,None);bpy.context.scene.collection.objects.link(obj)
    obj.parent=parent;obj.location=loc
    if connector: obj.EDMProps.SPECIAL_TYPE='CONNECTOR'
    return obj


def save_image(name,array,data=False):
    h,w=array.shape[:2]
    im=bpy.data.images.new(name,width=w,height=h,alpha=True)
    if data: im.colorspace_settings.name='Non-Color'
    rgba=np.ones((h,w,4),dtype=np.float32);rgba[:,:,:3]=np.clip(array,0,1)
    im.pixels.foreach_set(rgba.ravel());im.filepath_raw=str(TEX/(name+'.png'));im.file_format='PNG';im.save()
    return im


def surface(name,color,rough,metal,grain=.02,kind='noise'):
    rng=np.random.default_rng(sum(map(ord,name)))
    n=512; yy,xx=np.mgrid[:n,:n]
    noise=rng.normal(0,1,(n,n))
    if kind=='fabric': noise=.5*noise+.7*np.sin(xx*math.pi/3)*np.cos(yy*math.pi/3)
    if kind=='brushed': noise=.3*noise+np.repeat(rng.normal(0,.7,(n,1)),n,axis=1)
    height=noise*grain
    albedo=np.array(color)[None,None,:]*(1+height[:,:,None]*2)
    rm=np.zeros((n,n,3),dtype=np.float32);rm[:,:,0]=1;rm[:,:,1]=np.clip(rough+height*.4,0,1);rm[:,:,2]=metal
    dx=(np.roll(height,-1,axis=1)-np.roll(height,1,axis=1))*.5
    dy=(np.roll(height,-1,axis=0)-np.roll(height,1,axis=0))*.5
    norm=np.stack((-dx,dy,np.ones_like(dx)),axis=2);norm/=np.linalg.norm(norm,axis=2)[:,:,None]
    images=[save_image('B2A_'+name+'_BaseColor',albedo),save_image('B2A_'+name+'_RoughMet',rm,True),save_image('B2A_'+name+'_Normal',norm*.5+.5,True)]
    mat=bpy.data.materials.new('B2A_'+name);mat.use_nodes=True;mat.diffuse_color=(*color,1)
    nodes=mat.node_tree.nodes;nodes.clear();links=mat.node_tree.links
    out=nodes.new('ShaderNodeOutputMaterial')
    edm=nodes.new(type=edm_materials.DefaultMaterial.node_group_name)
    edm_materials.strap_shader_group(edm,DESCS[edm_materials.DefaultMaterial.name])
    links.new(edm.outputs[0],out.inputs['Surface'])
    uv=nodes.new('ShaderNodeUVMap');uv.uv_map='UVMap'
    for i,(im,socket) in enumerate(zip(images,['Base Color','RoughMet (Non-Color)','Normal (Non-Color)'])):
        tex=nodes.new('ShaderNodeTexImage');tex.image=im;tex.label=socket;tex.location=(-600,200-i*250)
        links.new(uv.outputs['UV'],tex.inputs['Vector']);links.new(tex.outputs['Color'],edm.inputs[socket])
    edm.inputs['Emissive Value'].default_value=0
    mat['surface_family']=name;mat['texture_repeat_metres']=.08
    return mat


def constant(name,color,emission=0,rough=.5):
    return_mat=bpy.data.materials.new('B2A_'+name);return_mat.use_nodes=True
    nodes=return_mat.node_tree.nodes;nodes.clear()
    out=nodes.new('ShaderNodeOutputMaterial');n=nodes.new(type=edm_materials.DefaultMaterial.node_group_name)
    edm_materials.strap_shader_group(n,DESCS[edm_materials.DefaultMaterial.name])
    return_mat.node_tree.links.new(n.outputs[0],out.inputs['Surface'])
    n.inputs['Base Color'].default_value=(*color,1)
    n.inputs['Emissive'].default_value=(*color,1);n.inputs['Emissive Value'].default_value=emission
    return_mat.diffuse_color=(*color,1)
    return return_mat


def uv_project(obj):
    uv=obj.data.uv_layers.get('UVMap') or obj.data.uv_layers.new(name='UVMap')
    for poly in obj.data.polygons:
        normal=poly.normal;axis=max(range(3),key=lambda i:abs(normal[i])); axes=[i for i in range(3) if i!=axis]
        for li in poly.loop_indices:
            co=obj.matrix_world@obj.data.vertices[obj.data.loops[li].vertex_index].co
            uv.data[li].uv=(co[axes[0]]/.08,co[axes[1]]/.08)


def camera(name,loc,target,lens=28):
    data=bpy.data.cameras.new(name);data.lens=lens
    obj=bpy.data.objects.new(name,data);bpy.context.scene.collection.objects.link(obj);obj.location=loc
    obj.rotation_euler=(Vector(target)-obj.location).to_track_quat('-Z','Y').to_euler();return obj


bpy.ops.wm.open_mainfile(filepath=str(HERE/'B2_DCS_Cockpit_Phase5_Audit.blend'))
# Work only on the audited scene, not any unrelated scene stored in the input.
scene=bpy.context.scene
for other in list(bpy.data.scenes):
    if other!=scene: bpy.data.scenes.remove(other)
addon_utils.enable('io_scene_edm')
from io_scene_edm import edm_materials
DESCS=edm_materials.build_material_descriptions()
log('Generating physical texture maps')
M={
 'panel':surface('PanelPaint',(.035,.041,.046),.72,.04,.035),
 'bezel':surface('MouldedBezel',(.013,.016,.018),.63,0,.03),
 'rubber':surface('RubberGrip',(.009,.011,.012),.88,0,.05),
 'button':surface('KeyPlastic',(.075,.086,.091),.48,0,.025),
 'metal':surface('BrushedMetal',(.23,.25,.27),.3,.9,.04,'brushed'),
 'fabric':surface('SeatFabric',(.055,.065,.052),.96,0,.07,'fabric'),
 'leather':surface('CoamingVinyl',(.015,.018,.021),.8,0,.055),
 'white':constant('Legends',(.68,.72,.64)),
 'glass':surface('DisplayGlass',(.002,.006,.004),.13,0,.001),
 'green':constant('PreviewGreen',(.03,.6,.09),1),
 'amber':constant('Amber',(.75,.34,.025)),
 'red':surface('RedPaint',(.38,.008,.006),.42,0,.008),
 'blue':constant('PreviewBlue',(.015,.06,.23),.6),
 'brown':constant('PreviewBrown',(.18,.055,.014),.6),
}
log('Assigning materials and fitting geometry')
root=bpy.data.objects['B2_COCKPIT_MASTER'];root.matrix_world=FIT
# Lower the glareshield slightly to keep the pilot horizon clear.
bpy.data.objects['GLARESHIELD'].location.z-=.08
for o in list(scene.objects):
    if o.type in ['LIGHT','CAMERA']: bpy.data.objects.remove(o,do_unlink=True);continue
    if o.type in ['MESH','FONT'] and o.data.materials:
        old=o.data.materials[0].name.replace('MAT_','').split('.')[0]
        new=M.get(old,M['panel'])
        if o.name=='GLARESHIELD': new=M['leather']
        if o.name.startswith('SEAT_'): new=M['fabric'] if ('PAN' in o.name or 'BACK' in o.name) else M['leather']
        if o.name.startswith(('CONTROL_GRIP','THROTTLE_GRIP')): new=M['rubber']
        o.data.materials.clear();o.data.materials.append(new)
    if o.name in ['PILOT_SEAT','MISSION_COMMANDER_SEAT']: o.location.z+=.30
    if o.name.startswith('CONTROL_COLUMN') or o.name.startswith('CONTROL_GRIP'): o.location.z+=.16
    if o.type=='FONT': o.data.extrude=.00015;o.data.resolution_u=3
# Correct both default eyes to the measured exterior envelope.
for name,sign in [('PILOT_EYE',1),('MISSION_COMMANDER_EYE',-1)]:
    o=bpy.data.objects[name];o.parent=None;o.location=(EYE.x,sign*EYE.y,EYE.z)
# Rubber knurled sleeves and separate metal collars on the rotary knobs.
for pivot in [o for o in list(scene.objects) if o.name.endswith('_PIVOT')]:
    verts=[];faces=[];n=64
    for y in [-.014,.004]:
        for i in range(n):
            r=.020 if i%2==0 else .0185;a=i*math.tau/n
            verts.append((r*math.cos(a),y,r*math.sin(a)))
    for i in range(n):faces.append((i,(i+1)%n,(i+1)%n+n,i+n))
    mesh_object(pivot.name+'_RubberSleeve',verts,faces,M['rubber'],pivot)
    tube(pivot.name+'_Collar',(0,.009,0),(0,.016,0),.023,M['metal'],pivot,32)
# Additional cushions, stitched harness webbing and footwell pedals.
for side,seat_name in [(-1,'PILOT_SEAT'),(1,'MISSION_COMMANDER_SEAT')]:
    seat=bpy.data.objects[seat_name]
    for dx in [-.14,.14]:
        belt=cube(seat_name+'_Harness',(dx,-.30,.36),(.047,.018,.55),M['rubber'],seat,.006)
    cube(seat_name+'_Buckle',(0,-.06,.10),(.085,.07,.023),M['metal'],seat)
    for dy in [-.10,.10]:
        pedal=cube('RudderPedal',(6.60,-side*.574+dy,.15),(.16,.14,.026),M['metal'])
        for i in range(6):cube('PedalGrip',(6.54+i*.022,-side*.574+dy,.169),(.007,.125,.007),M['rubber'])
# Actual canopy boundary: importer reference has been corrected to exporter axes.
with bpy.data.libraries.load(str(REPO/'scratch/exterior_reference_correct.blend'),link=False) as (src,dst):
    dst.objects=[n for n in src.objects if n.startswith('B-2_Spirit_render')]
refs=[o for o in dst.objects if o]
for obj in refs:
    if obj.data.materials and 'Glass' in obj.data.materials[0].name:
        counts={}
        for p in obj.data.polygons:
            for va,vb in p.edge_keys:
                a=tuple(round(v,5) for v in obj.data.vertices[va].co)
                b=tuple(round(v,5) for v in obj.data.vertices[vb].co)
                e=tuple(sorted((a,b))); counts[e]=counts.get(e,0)+1
        for (a,b),count in counts.items():
            if count==1:
                pa=obj.matrix_world@Vector(a);pb=obj.matrix_world@Vector(b)
                tube('CanopyFrame',pa,pb,.014,M['bezel'],segments=10)
# Aircraft-space interior tub, clear of the glass sight lines.
cube('Cabin_Aft',(5.12,0,.52),(.05,2.15,1.12),M['panel'],bevel=.015)
cube('Cabin_Roof_Aft',(5.42,0,1.29),(.64,2.00,.04),M['leather'],bevel=.02)
for side in [-1,1]:
    wall=cube('Cabin_Side',(5.92,side*1.12,.39),(1.60,.045,.78),M['panel'])
# Compatibility control bank: existing simulator controls, explicitly not claimed authentic.
text_src=next(o for o in scene.objects if o.type=='FONT')
legacy=(MOD/'Cockpit/Scripts/clickabledata.lua').read_text(errors='replace')
legacy_names=[]
for line in legacy.splitlines():
    if line.lstrip().startswith('--'):continue
    match=re.search(r'elements\["([^"]+)"\]',line)
    if match and not re.match(r'[LRB]_MFD_|ICP_|[LR]_SMFD_',match[1]):legacy_names.append(match[1])
legacy_names=list(dict.fromkeys(legacy_names))
for i,name in enumerate(legacy_names):
    # A labelled forward-facing auxiliary bank under the centre panel keeps legacy inputs reachable.
    x=6.72; y=.40-(i%8)*.115; z=.60-(i//8)*.085
    cube('AUX_'+name,(x,y,z),(.025,.065,.044),M['button'])
    empty(name,(x-.018,y,z),connector=True)
    label=text_src.copy();label.data=text_src.data.copy();label.name='AUX_LABEL_'+name;scene.collection.objects.link(label)
    label.parent=None;label.location=(x-.020,y,z);label.rotation_euler=(math.pi/2,0,-math.pi/2)
    label.data.body=name.replace('_PNT','').replace('LIGHT',' LT');label.data.size=.008;label.data.materials.clear();label.data.materials.append(M['white'])
# Indicator anchors retain existing Lua identifiers, placed on the actual display aperture.
mdus=['MDU_L_OUTER','MDU_L_CENTER','MDU_L_SYSTEM','MDU_L_LOWER','MDU_R_SYSTEM','MDU_R_CENTER','MDU_R_OUTER','MDU_R_LOWER']
for i,name in enumerate(mdus,1):
    p=bpy.data.objects[name]
    for suffix,loc in [('CENTER',(0,-.058,0)),('DOWN',(0,-.058,-.138)),('RIGHT',(.138,-.058,0))]:
        empty(f'B2_MFD{i}_{suffix}',loc,p,True)
for suffix,loc in [('CENTER',(0,-.074,.01)),('DOWN',(0,-.074,-.132)),('RIGHT',(.178,-.074,.01))]:
    empty('B2_CID_'+suffix,loc,bpy.data.objects['CID'],True)
# Retain the three existing twenty-button command banks on three pilot displays.
for legacy_prefix,unit in [('L','MDU_L_OUTER'),('R','MDU_L_SYSTEM'),('B','MDU_L_LOWER')]:
    for index,(side,num) in enumerate([(s,i) for s in ['TOP','RIGHT','BOTTOM','LEFT'] for i in range(1,6)],1):
        num=6-num if side in ['BOTTOM','LEFT'] else num
        key=bpy.data.objects[f'{unit}_{side}_{num:02}'];empty(f'{legacy_prefix}_MFD_{index}_PNT',key.location,key.parent,True)
for digit in list('0123456789')+['CLR']:
    key=bpy.data.objects.get('CDU_NUM_'+digit) or bpy.data.objects.get('CDU_'+digit)
    if key:empty('ICP_'+digit+'_PNT',key.location,key.parent,True)
for name,unit in [('L_SMFD_1_PNT','MDU_L_CENTER'),('R_SMFD_1_PNT','MDU_R_CENTER')]:
    empty(name,(0,-.07,-.15),bpy.data.objects[unit],True)
# Remaining ICP functions get a labelled simulator strip, avoiding dangling old pointers.
all_names=[]
for line in legacy.splitlines():
    if line.lstrip().startswith('--'):continue
    m=re.search(r'elements\["([^"]+)"\]',line)
    if m and m[1] not in all_names:all_names.append(m[1])
missing=[n for n in all_names if n not in bpy.data.objects]
for i,name in enumerate(missing):
    loc=(6.66,-.40-(i%4)*.13,.39-(i//4)*.075)
    cube('AUX_'+name,loc,(.025,.08,.045),M['button']);empty(name,(loc[0]-.02,loc[1],loc[2]),connector=True)
    label=text_src.copy();label.data=text_src.data.copy();scene.collection.objects.link(label);label.name='LABEL_'+name
    label.parent=None;label.location=(loc[0]-.022,loc[1],loc[2]);label.rotation_euler=(math.pi/2,0,-math.pi/2)
    label.data.body=name.replace('ICP_','').replace('_PNT','');label.data.size=.008;label.data.materials.clear();label.data.materials.append(M['white'])
log('Assign UVs and render fitted cockpit')
bpy.context.view_layer.update()
for o in scene.objects:
    if o.type=='MESH':uv_project(o)
scene.world=bpy.data.worlds.new('ProductionWorld');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value=(.18,.23,.3,1)
scene.world.node_tree.nodes['Background'].inputs['Strength'].default_value=.35
ld=bpy.data.lights.new('Canopy daylight','AREA');ld.energy=130;ld.size=2.5
lo=bpy.data.objects.new('Canopy daylight',ld);scene.collection.objects.link(lo);lo.location=(6.25,0,2.7)
ld2=bpy.data.lights.new('Panel bounce','AREA');ld2.energy=35;ld2.size=2
lo2=bpy.data.objects.new('Panel bounce',ld2);scene.collection.objects.link(lo2);lo2.location=(5.6,0,1.2);lo2.rotation_euler=(0,-math.pi/2,0)
scene.render.engine='BLENDER_EEVEE_NEXT';scene.render.resolution_x=1600;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast'
views=[('Pilot',EYE,(7.2,.50,.99),22),('PanelDetail',(6.24,-.2,1.12),(6.82,-.56,.90),36),('Overview',(5.30,0,1.20),(6.78,0,.84),19)]
for name,loc,target,lens in views:
    scene.camera=camera(name,loc,target,lens);scene.render.filepath=str(OUT/(name+'.png'));bpy.ops.render.render(write_still=True)
scene.camera=bpy.data.objects['Pilot']
scene['aircraft_eye_DCS']=list((EYE.x,EYE.z,-EYE.y))
scene['fit_notes']='Canopy measured from shipped exterior EDM; corrected importer X rotation. Exterior unchanged.'
# Exterior reference is available in a separate alignment scene and is never exported with cockpit.
alignment=bpy.data.scenes.new('Exterior Alignment')
for o in list(scene.objects):alignment.collection.objects.link(o)
for o in refs:alignment.collection.objects.link(o)
alignment.world=scene.world
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'B2_Cockpit_Textured_Aligned.blend'))
# Runtime export: remove static MDU/CID page art, preview clicks, and scene helpers.
preview=[]
for o in list(scene.objects):
    chain=[o]
    while chain[-1].parent: chain.append(chain[-1].parent)
    is_page=any('_PAGE_PREVIEW' in p.name for p in chain) or o.name=='CID_SYSTEM_PREVIEW'
    if is_page or o.name.startswith('CLICK_') or o.type in ['LIGHT','CAMERA']:
        preview.append(o)
for o in preview:scene.collection.objects.unlink(o) if o.name in scene.collection.objects else None
# Some source objects are linked to nested collections; unlink from every scene collection.
def unlink_tree(col,obj):
    if obj.name in col.objects:col.objects.unlink(obj)
    for c in col.children:unlink_tree(c,obj)
for o in preview:unlink_tree(scene.collection,o)
# Convert all renderable objects to evaluated mesh, freezing bevels and lettering.
bpy.context.view_layer.update();deps=bpy.context.evaluated_depsgraph_get()
renderables=[o for o in scene.objects if o.type in ['MESH','FONT']]
for o in renderables:
    evaluated=o.evaluated_get(deps)
    mesh=bpy.data.meshes.new_from_object(evaluated,preserve_all_data_layers=True,depsgraph=deps)
    new=bpy.data.objects.new(o.name+'_EDM',mesh);scene.collection.objects.link(new);new.matrix_world=o.matrix_world
    uv_project(new);unlink_tree(scene.collection,o)
# Batch static meshes by material to avoid a draw call per screw/key/letter.
bpy.ops.object.select_all(action='DESELECT')
mesh_groups={}
for o in scene.objects:
    if o.type=='MESH':mesh_groups.setdefault(o.data.materials[0].name,[]).append(o)
for mat_name,objects in mesh_groups.items():
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    if len(objects)>1:bpy.ops.object.join()
    obj=bpy.context.view_layer.objects.active;obj.name='Cockpit_'+mat_name
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    obj.select_set(False)
# Freeze connectors into aircraft space before shifting the export origin to the pilot eye.
bpy.context.view_layer.update()
for o in list(scene.objects):
    if o.type=='MESH' or (o.type=='EMPTY' and o.EDMProps.SPECIAL_TYPE=='CONNECTOR'):
        matrix=o.matrix_world.copy();o.parent=None;o.matrix_world=Matrix.Translation(-EYE)@matrix
    elif o.type=='EMPTY':unlink_tree(scene.collection,o)
scene.name='DCS_Cockpit_Export'
export_collection=bpy.data.collections.new('Cockpit_Export_Geometry')
scene.collection.children.link(export_collection)
for o in list(scene.objects):
    export_collection.objects.link(o)
    if o.name in scene.collection.objects: scene.collection.objects.unlink(o)
bpy.context.view_layer.update()
export_path=OUT/'B-2_Spirit_Cockpit_Audit.EDM'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'B2_Cockpit_Export.blend'))
log('Exporting',export_path)
result=bpy.ops.edm.export(filepath=str(export_path))
assert 'FINISHED' in result and export_path.exists() and export_path.stat().st_size > 100000, 'Empty or incomplete EDM export'
report={'eye_DCS':[EYE.x,EYE.z,-EYE.y],'fit_matrix':[list(row) for row in FIT],
        'texture_maps':len(list(TEX.glob('*.png'))),'draw_batches':len(mesh_groups),
        'connectors':[o.name for o in scene.objects if o.type=='EMPTY'],
        'legacy_pointer_count':len(all_names),'export_bytes':export_path.stat().st_size,
        'limitations':['Unseen details remain estimates','Legacy auxiliary bank is a simulator adaptation','Existing DCS display behaviour retained; no new aircraft systems implemented']}
assert all(name in report['connectors'] for name in all_names)
(OUT/'build_report.json').write_text(json.dumps(report,indent=2))
log('PRODUCTION_BUILD_OK',report['export_bytes'],report['draw_batches'],'batches')


