extends Node

const COLOR_SPEAKER: Color = Color(0.87, 0.87, 0.87)
const COLOR_DIRECT_OUT_SPEAKER: Color = Color(0.25, 0.25, 0.25)
const COLOR_SPEAKER_SELECT: Color = Color(1.0, 0.64, 0.09)
const MAX_NUM_SPEAKERS: int = 256

var project_num_speakers: int = 0
var speakers_scenes: Array

# Materials
var spk_cube_mat: StandardMaterial3D
var spk_cube_mat_selected: StandardMaterial3D
var spk_cube_mat_direct_out_only: StandardMaterial3D
var spk_num_mat: StandardMaterial3D

var speakerview_node

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
		
		if spk_is_selected:
			cube.material_override = spk_cube_mat_selected
		elif spk_is_direct_out_only:
			cube.material_override = spk_cube_mat_direct_out_only
		else:
			cube.material_override = spk_cube_mat
		
		instance.spk_number = spk_number
		# SG is XZ-Y, Godot is XYZ. Let's fix this here.
		instance.transform.origin = Vector3(spk_position[0], spk_position[2], -spk_position[1]) * speakerview_node.SG_SCALE
		# Transparent is 0 in SG and 1 in Godot.
		cube.transparency = 1.0 - spk_alpha
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
		
		if spk_is_selected:
			cube.material_override = spk_cube_mat_selected
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 0.0
		elif spk_is_direct_out_only:
			cube.material_override = spk_cube_mat_direct_out_only
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 1.0 - spk_alpha
		else:
			cube.material_override = spk_cube_mat
			# Transparent is 0 in SG and 1 in Godot.
			cube.transparency = 1.0 - spk_alpha
		
		# SG is XZ-Y, Godot is XYZ
		spk.transform.origin = Vector3(spk_position[0], spk_position[2], -spk_position[1]) * speakerview_node.SG_SCALE
		spk.spk_number = spk_number
		spk.spk_is_selected = spk_is_selected
		spk.spk_is_direct_out_only = spk_is_direct_out_only

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

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	
	spk_cube_mat = StandardMaterial3D.new()
	spk_cube_mat_selected = StandardMaterial3D.new()
	spk_cube_mat_direct_out_only = StandardMaterial3D.new()
	spk_num_mat = StandardMaterial3D.new()
	
	spk_cube_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_cube_mat_selected.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_cube_mat_direct_out_only.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spk_num_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	spk_cube_mat.albedo_color = COLOR_SPEAKER
	spk_cube_mat_selected.albedo_color = COLOR_SPEAKER_SELECT
	spk_cube_mat_direct_out_only.albedo_color = COLOR_DIRECT_OUT_SPEAKER
	spk_num_mat.albedo_color = Color.BLACK

func _process(_delta):
	pass
