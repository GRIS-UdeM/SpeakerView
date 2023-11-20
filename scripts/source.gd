extends Node3D

enum HybridSpatMode {DOME=0, CUBE=1}

const NUM = 8
const SQRT_15 = sqrt(15)

@export var src_number: int
@export var src_hybrid_spat_mode: HybridSpatMode
@export var src_azimuth_span: float
@export var src_elevation_span: float
@export var src_color: Color
@export var src_transparency: float

var length: float = 0.0
var elevation: float = 0.0
var azimuth: float = 0.0

var sphere
var source_number_mesh

var counter: int = 0
var azi_dev: float
var new_azimuth: float
var diff_elev: float
var inverse_elevation: float
var elev_dev: float
var new_elevation: float
var diff_new_elev: float
var inverse_new_elevation: float

var vbap_span_elevation: float

var speakerview_node
var camera_node
var sources_node

var vbap_multimesh_instance3D: MultiMeshInstance3D
var vbap_multimesh: MultiMesh

var mbap_spans: MeshInstance3D

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	camera_node = get_node("/root/SpeakerView/Center/Camera")
	mbap_spans = get_node("mbap_spans")
	sources_node = get_parent()
	
	# sphere
	var sphere_new_mesh_3d = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	
	sphere_mesh.radial_segments = 10
	sphere_mesh.rings = 10

	var src_sphere_mat = StandardMaterial3D.new()
	
	src_sphere_mat.disable_receive_shadows = true
	src_sphere_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere_new_mesh_3d.set_cast_shadows_setting(GeometryInstance3D.ShadowCastingSetting.SHADOW_CASTING_SETTING_OFF)
	sphere_new_mesh_3d.mesh = sphere_mesh
	sphere_new_mesh_3d.material_override = src_sphere_mat
	sphere = sphere_new_mesh_3d

	sphere.material_override.albedo_color = src_color
	sphere.transparency = src_transparency
	sphere.scale = Vector3(1.5, 1.5, 1.5)
	
	add_child(sphere)
	
	# sphere number
	var src_num_new_mesh_3d = MeshInstance3D.new()
	var text_mesh = TextMesh.new()
	
	text_mesh.set_depth(0.0)
	src_num_new_mesh_3d.set_cast_shadows_setting(GeometryInstance3D.ShadowCastingSetting.SHADOW_CASTING_SETTING_OFF)
	src_num_new_mesh_3d.mesh = text_mesh
	src_num_new_mesh_3d.material_override = sources_node.src_num_mat
	source_number_mesh = src_num_new_mesh_3d
	
	source_number_mesh.position.y = 1.6
	source_number_mesh.scale = Vector3(5, 5, 1)
	source_number_mesh.mesh.set_text(str(src_number))
	
	add_child(source_number_mesh)
	
	# vbap spans
	vbap_multimesh_instance3D = MultiMeshInstance3D.new()
	# Create the multimesh.
	vbap_multimesh = MultiMesh.new()
	var mmesh = BoxMesh.new()
	vbap_multimesh_instance3D.transparency = src_transparency
	vbap_multimesh_instance3D.set_cast_shadows_setting(GeometryInstance3D.ShadowCastingSetting.SHADOW_CASTING_SETTING_OFF)
	vbap_multimesh.mesh = mmesh
	mmesh.size = Vector3(0.3, 0.3, 0.3)
	# Set the format first.
	vbap_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	# Then resize (otherwise, changing the format is not allowed).
	vbap_multimesh.instance_count = 144
	vbap_multimesh.visible_instance_count = 144
	vbap_multimesh_instance3D.multimesh = vbap_multimesh
	vbap_multimesh_instance3D.material_override = src_sphere_mat
	
	add_child(vbap_multimesh_instance3D)
	
	# mbap_spans
	mbap_spans.material_override = src_sphere_mat
	mbap_spans.transparency = 0.9
	mbap_spans.mesh = CylinderMesh.new()
	
	update_polar_coords()

func _process(_delta):
	update_sphere()
	update_source_number()
	update_polar_coords()
	
	if speakerview_node.spat_mode == speakerview_node.SpatMode.DOME:
		mbap_spans.visible = false
		vbap_multimesh_instance3D.visible = true
		update_vbap_spans()
	elif speakerview_node.spat_mode == speakerview_node.SpatMode.CUBE:
		mbap_spans.visible = true
		vbap_multimesh_instance3D.visible = false
		update_mbap_spans()
	elif speakerview_node.spat_mode == speakerview_node.SpatMode.HYBRID:
		if src_hybrid_spat_mode == HybridSpatMode.DOME:
			mbap_spans.visible = false
			vbap_multimesh_instance3D.visible = true
			update_vbap_spans()
		elif src_hybrid_spat_mode == HybridSpatMode.CUBE:
			mbap_spans.visible = true
			vbap_multimesh_instance3D.visible = false
			update_mbap_spans()

func update_sphere():
	sphere.material_override.albedo_color = src_color
	sphere.transparency = src_transparency

func update_source_number():
	source_number_mesh.visible = speakerview_node.show_source_numbers
	if source_number_mesh.visible:
		source_number_mesh.mesh.set_text(str(src_number))
		source_number_mesh.look_at(camera_node.global_position, Vector3(0, 1, 0), true)
		source_number_mesh.transparency = src_transparency

func update_vbap_spans():
	if src_azimuth_span == 0 and src_elevation_span == 0:
		vbap_multimesh_instance3D.visible = false
		return
	
	vbap_multimesh_instance3D.visible = true
	vbap_multimesh_instance3D.transparency = src_transparency
	vbap_span_elevation = PI / 2.0# PI for complete sphere
	
	counter = 0
	for i in NUM:
		azi_dev = src_azimuth_span * i * 0.42
		for j in 2:
			new_azimuth = azimuth - azi_dev if j == 0 else azimuth + azi_dev
			diff_elev = PI / 2 - elevation
			inverse_elevation = 0.0000001 if diff_elev == 0 else diff_elev
			
			var new_transform_azi = to_global(Vector3(
				length * sin(inverse_elevation) * sin(new_azimuth),
				global_position.y,
				length * sin(inverse_elevation) * cos(new_azimuth)))
			vbap_multimesh.set_instance_transform(counter, Transform3D(Basis(),
				new_transform_azi * 2*PI - transform.origin * 2*PI*7/5))
			counter += 1
			
			for k in 4:
				elev_dev = (float(k) + 1.0) * src_elevation_span * 0.38
				for l in 2:
					new_elevation = elevation - elev_dev if l == 0 else elevation + elev_dev
					diff_new_elev = PI / 2 - new_elevation
					inverse_new_elevation = 0.0000001 if diff_new_elev == 0 else diff_new_elev
					inverse_new_elevation = clamp(inverse_new_elevation, 0.0, vbap_span_elevation)
					
					var new_transform_elev = to_global(Vector3(
								length * sin(inverse_new_elevation) * sin(new_azimuth),
								length * cos(inverse_new_elevation),
								length * sin(inverse_new_elevation) * cos(new_azimuth)))
					vbap_multimesh.set_instance_transform(counter, Transform3D(Basis(),
						new_transform_elev * 2*PI - transform.origin * 2*PI*7/5))
					
					counter += 1

func update_mbap_spans():
	if src_azimuth_span == 0 and src_elevation_span == 0:
		mbap_spans.visible = false
		return
	
	mbap_spans.visible = true
	
	var span_radius = 0.05 if src_azimuth_span == 0 else src_azimuth_span * speakerview_node.SG_SCALE * SQRT_15
	var span_height = src_elevation_span * speakerview_node.SG_SCALE * 5
	
	if src_transparency == 1.0:
		mbap_spans.transparency = src_transparency
	else:
		mbap_spans.transparency = 0.7 if src_azimuth_span == 0 else 0.85
	
	
	mbap_spans.mesh.top_radius = span_radius
	mbap_spans.mesh.bottom_radius = span_radius
	mbap_spans.mesh.height = span_height

func update_length():
	length = global_position.length()

func update_elevation():
	if length == 0.0:
		elevation = 0.0
		return
	
	elevation = (PI / 2.0) - acos(clamp(global_position.y / length, -1.0, 1.0))

func update_azimuth():
	# From SpatGris :
	# Mathematically, the azimuth angle should start from the pole and be equal to 90 degrees at the equator.
	# We have to accomodate for a slightly different coordinate system where the azimuth angle starts at the equator
	# and is equal to 90 degrees at the north pole.
	
	if global_position.x == 0.0 && global_position.z == 0.0:
		azimuth = 0.0
		return
	
	var deg_sign = -1.0 if global_position.z > 0 else 1.0
	azimuth = acos(clamp(global_position.x / sqrt(global_position.x * global_position.x + global_position.z * global_position.z), -1.0, 1.0)) * deg_sign + (PI / 2)

func update_polar_coords():
	update_length()
	update_elevation()
	update_azimuth()
