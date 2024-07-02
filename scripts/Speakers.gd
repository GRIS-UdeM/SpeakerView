extends Node

const COLOR_OUTLINE_SPEAKER: Color = Color(0.95, 0.95, 0.95)
const COLOR_LIGHT_SPEAKER: Color = Color(0.75, 0.75, 0.75)
const COLOR_DARK_SPEAKER: Color = Color(0.3, 0.3, 0.3)
const COLOR_BLACK_SPEAKER: Color = Color(0.0, 0.0, 0.0)
const COLOR_SPEAKER_SELECT: Color = Color(1.0, 0.64, 0.09)
const MAX_NUM_SPEAKERS: int = 256

var project_num_speakers: int = 0
var speakers_scenes: Array

# Materials
var spk_cube_light_mat: StandardMaterial3D
var spk_cube_dark_mat: StandardMaterial3D
var spk_cube_edges_mat: StandardMaterial3D
var spk_cube_edges_mat_selected: StandardMaterial3D
var spk_cube_mat_selected: StandardMaterial3D
var spk_num_mat: StandardMaterial3D

# Settings
var spk_origin_orientation

var speakerview_node
var camera_node

var original_cube_rotation
var original_cube_edges_rotation

func set_speakers_info(data: Variant):
	if project_num_speakers != data.size() - 1 and speakers_scenes.size() != data.size() - 1:
		project_num_speakers = data.size() - 1
		free_spk_scenes()
		populate_speakers(data)
		render_spk_scenes()
	elif speakerview_node.show_speakers:
		update_spk_scenes(data)

func populate_speakers(data: Variant):
	for i in range(1, project_num_speakers + 1):
		var spk_number = data[i][0]
		var spk_position = data[i][1]
		var spk_is_selected = data[i][2]
		var spk_is_direct_out_only = data[i][3]
		var spk_alpha = data[i][4]
		var spk_scn = load("res://scenes/speaker.tscn")
		var instance = spk_scn.instantiate()
		var cube = instance.get_node("cube")
		var cube_edges = instance.get_node("cube_edges")
		var cube_edges_mesh = cube_edges.get_node("Cube")
		
		original_cube_rotation = cube.rotation
		original_cube_edges_rotation = cube_edges.rotation
		
		if spk_is_selected:
			cube.material_override = spk_cube_mat_selected
			cube_edges_mesh.material_override = spk_cube_edges_mat_selected
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 0.0
		elif spk_is_direct_out_only:
			cube.material_override = spk_cube_dark_mat
			cube_edges_mesh.material_override = spk_cube_edges_mat
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 1.0 - spk_alpha
		else:
			cube.material_override = spk_cube_light_mat
			cube_edges_mesh.material_override = spk_cube_edges_mat
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 1.0 - spk_alpha
		
		instance.spk_number = spk_number
		# SG is XZ-Y, Godot is XYZ. Let's fix this here.
		instance.transform.origin = Vector3(spk_position[0], spk_position[2], -spk_position[1]) * speakerview_node.SG_SCALE
		instance.spk_is_selected = spk_is_selected
		instance.spk_is_direct_out_only = spk_is_direct_out_only
		speakers_scenes.append(instance)

func update_spk_scenes(data: Variant):
	for i in range(speakers_scenes.size()):
		var index = i + 1
		var spk = speakers_scenes[i]
		var spk_number = data[index][0]
		var spk_position = data[index][1]
		var spk_is_selected = data[index][2]
		var spk_is_direct_out_only = data[index][3]
		var spk_alpha = data[index][4]
		var cube = spk.get_node("cube")
		var cube_edges = spk.get_node("cube_edges")
		var cube_edges_mesh = cube_edges.get_node("Cube")
		
		if spk_is_selected:
			cube.material_override = spk_cube_mat_selected
			cube_edges_mesh.material_override = spk_cube_edges_mat_selected
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 0.0
		elif spk_is_direct_out_only:
			cube.material_override = spk_cube_dark_mat
			cube_edges_mesh.material_override = spk_cube_edges_mat
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 1.0 - spk_alpha
		else:
			cube.material_override = spk_cube_light_mat
			cube_edges_mesh.material_override = spk_cube_edges_mat
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 1.0 - spk_alpha
		
		# SG is XZ-Y, Godot is XYZ
		spk.transform.origin = Vector3(spk_position[0], spk_position[2], -spk_position[1]) * speakerview_node.SG_SCALE
		if spk.spk_number != spk_number:
			spk.spk_number = spk_number
			spk.reset_spk_number()
		
		spk.spk_is_selected = spk_is_selected
		spk.spk_is_direct_out_only = spk_is_direct_out_only
		
		update_speaker_orientation(spk)
		
		# It looks like executing content of every speaker _process() here gives better performances
		spk.speaker_number_mesh.visible = speakerview_node.show_speaker_numbers
		if spk.speaker_number_mesh.visible:
			spk.speaker_number_mesh.look_at(camera_node.global_position, Vector3(0, 1, 0), true)

func get_speaker(index: int):
	for speaker in speakers_scenes:
		if speaker.spk_number == index:
			return speaker

func render_spk_scenes():
	for inst in speakers_scenes:
		add_child(inst)

func free_spk_scenes():
	for inst in speakers_scenes:
		inst.queue_free()
		remove_child(inst)
	speakers_scenes.clear()
	
func update_speaker_orientation(spk):
	var cube = spk.get_node("cube")
	var cube_edges = spk.get_node("cube_edges")
	
	if spk_origin_orientation :
		var spk_pos_normalized = spk.transform.origin.normalized()
		var up_vector = Vector3(0, 1, 0)
		var almost_zero = 0.000001
		if abs(spk_pos_normalized.x) < almost_zero and abs(spk_pos_normalized.z) < almost_zero:
			up_vector = Vector3(0, 0, 1)
		cube.look_at(Vector3(0, 0, 0), up_vector, true)
		cube_edges.look_at(Vector3(0, 0, 0), up_vector, true)
	else :
		cube.rotation = original_cube_rotation
		cube_edges.rotation = original_cube_edges_rotation

func toggle_spk_orientation(button_pressed):
	spk_origin_orientation = button_pressed
	for i in range(speakers_scenes.size()):
		var spk = speakers_scenes[i]
		update_speaker_orientation(spk)
		spk.toggle_spk_orientation(button_pressed)
	
func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	camera_node = get_node("/root/SpeakerView/Center/Camera")
	
	spk_cube_light_mat = StandardMaterial3D.new()
	spk_cube_dark_mat = StandardMaterial3D.new()
	spk_cube_edges_mat = StandardMaterial3D.new()
	spk_cube_edges_mat_selected = StandardMaterial3D.new()
	spk_cube_mat_selected = StandardMaterial3D.new()
	spk_num_mat = StandardMaterial3D.new()
	
	spk_cube_light_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_cube_dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_cube_edges_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_cube_edges_mat_selected.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_cube_mat_selected.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_num_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	spk_cube_light_mat.albedo_color = COLOR_LIGHT_SPEAKER
	spk_cube_dark_mat.albedo_color = COLOR_DARK_SPEAKER
	spk_cube_edges_mat.albedo_color = COLOR_OUTLINE_SPEAKER
	spk_cube_edges_mat_selected.albedo_color = COLOR_BLACK_SPEAKER
	spk_cube_mat_selected.albedo_color = COLOR_SPEAKER_SELECT
	spk_num_mat.albedo_color = Color.BLACK
	
	spk_origin_orientation = speakerview_node.spk_origin_orientation
