extends Node

const MAX_NUM_SOURCES: int = 256

var project_num_sources: int = 0
var sources_scenes: Array
var src_num_mat: StandardMaterial3D

var speakerview_node

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	
	src_num_mat = StandardMaterial3D.new()
	src_num_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	src_num_mat.albedo_color = Color.WHITE_SMOKE

func set_sources_info(data: Variant):
	if project_num_sources != data.size() - 1 and sources_scenes.size() != data.size() - 1:
		project_num_sources = data.size() - 1
		free_src_scenes()
		populate_sources(data)
		render_src_scenes()
	else:
		update_src_scenes(data)

func populate_sources(data: Variant):
	for i in range(1, project_num_sources + 1):
		var src_number = data[i][0]
		var src_position = data[i][1]
		var src_color = data[i][2]
		var src_hybrid_spat_mode = data[1][3]
		var src_azimuth_span = data[i][4]
		var src_elevation_span = data[i][5]
		var src_scn = load("res://scenes/source.tscn")
		var instance = src_scn.instantiate()
		
		instance.src_number = data[i][0]
		# SG is XZ-Y, Godot is XYZ
		instance.transform.origin = Vector3(src_position[0], src_position[2], -src_position[1]) * speakerview_node.SG_SCALE
		instance.src_color = Color(src_color[0], src_color[1], src_color[2])
		# Transparent is 0 in SG and 1 in Godot.
		instance.src_transparency = 1.0 - src_color[3]
		instance.src_hybrid_spat_mode = src_hybrid_spat_mode
		instance.src_azimuth_span = src_azimuth_span
		instance.src_elevation_span = src_elevation_span
		
		sources_scenes.append(instance)

func update_src_scenes(data: Variant):
	for i in range(sources_scenes.size()):
		var json_data_index = i + 1
		var src_number = data[json_data_index][0]
		var src_position = data[json_data_index][1]
		var src_color = data[json_data_index][2]
		var src_hybrid_spat_mode = data[json_data_index][3]
		var src_azimuth_span = data[json_data_index][4]
		var src_elevation_span = data[json_data_index][5]
		var src = sources_scenes[i]
		
		src.src_number = src_number
		# SG is XZ-Y, Godot is XYZ. Let's fix this here.
		src.transform.origin = Vector3(src_position[0], src_position[2], -src_position[1]) * speakerview_node.SG_SCALE
		src.src_color = Color(src_color[0], src_color[1], src_color[2])
		# Transparent is 0 in SG and 1 in Godot.
		src.src_transparency = 1.0 - src_color[3]
		src.src_hybrid_spat_mode = src_hybrid_spat_mode
		src.src_azimuth_span = src_azimuth_span
		src.src_elevation_span = src_elevation_span
		
		# It looks like executing content of every source _process() here gives better performances
		src.update_sphere()
		src.update_source_number()
		src.update_polar_coords()
		
		if speakerview_node.spat_mode == speakerview_node.SpatMode.DOME:
			src.mbap_spans.visible = false
			src.vbap_multimesh_instance3D.visible = true
			src.update_vbap_spans()
		elif speakerview_node.spat_mode == speakerview_node.SpatMode.CUBE:
			src.mbap_spans.visible = true
			src.vbap_multimesh_instance3D.visible = false
			src.update_mbap_spans()
		elif speakerview_node.spat_mode == speakerview_node.SpatMode.HYBRID:
			if src.src_hybrid_spat_mode == src.HybridSpatMode.DOME:
				src.mbap_spans.visible = false
				src.vbap_multimesh_instance3D.visible = true
				src.update_vbap_spans()
			elif src.src_hybrid_spat_mode == src.HybridSpatMode.CUBE:
				src.mbap_spans.visible = true
				src.vbap_multimesh_instance3D.visible = false
				src.update_mbap_spans()

func render_src_scenes():
	for inst in sources_scenes:
		add_child(inst)

func free_src_scenes():
	for inst in sources_scenes:
		inst.queue_free()
		remove_child(inst)
	sources_scenes.clear()

func _process(_delta):
	pass
