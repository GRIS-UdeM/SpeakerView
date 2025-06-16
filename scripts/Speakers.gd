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

var speakerview_node
var spk_scn = load("res://scenes/speaker.tscn")

var MIN_SPEAKER_SCALE: float = 0.4
var AUTO_SCALE_INCREMENT = 0.02

func set_speakers_info(data: Variant):
	if project_num_speakers != data.size() - 1 or speakers_scenes.size() != data.size() - 1:
		project_num_speakers = data.size() - 1
		free_spk_scenes()
		populate_speakers(data)
		render_spk_scenes()
	elif speakerview_node.show_speakers:
		update_spk_scenes(data)

func set_speaker_properties_from_data(speaker:Node3D, data: Variant):
	var spk_position = data[1]
	var spk_is_selected = data[2]
	var spk_is_direct_out_only = data[3]
	var spk_center_pos

	if data.size() > 5:
		spk_center_pos = data[5]
	else:
		spk_center_pos = [0,0,0]
	# SG is XZ-Y, Godot is XYZ. Let's fix this here.
	speaker.center_position = Vector3(spk_center_pos[0], spk_center_pos[2], -spk_center_pos[1]) * speakerview_node.SG_SCALE

	speaker.transform.origin = Vector3(spk_position[0], spk_position[2], -spk_position[1]) * speakerview_node.SG_SCALE
	speaker.spk_is_selected = spk_is_selected
	speaker.spk_is_direct_out_only = spk_is_direct_out_only

func populate_speakers(data: Variant):
	for i in range(1, project_num_speakers + 1):
		var instance = spk_scn.instantiate()
		set_speaker_properties_from_data(instance, data[i])
		var spk_number = data[i][0]
		var spk_alpha = data[i][4]
		instance.spk_number = spk_number
		update_speaker_display(instance, spk_alpha)
		speakers_scenes.append(instance)


func update_spk_scenes(data: Variant):
	for i in range(speakers_scenes.size()):
		var index = i + 1
		var spk = speakers_scenes[i]
		set_speaker_properties_from_data(spk, data[index])
		var spk_number = data[index][0]
		var spk_alpha = data[index][4]
		# SG is XZ-Y, Godot is XYZ
		if spk.spk_number != spk_number:
			spk.spk_number = spk_number
			spk.reset_spk_number()
		update_speaker_display(spk, spk_alpha)

func update_speaker_display(speaker, spk_alpha=null):
	var cube = speaker.get_node("cube")

	# handle the case in which we don't know the spk_alpha by simply reinstating the old transparency
	var transparency: float
	if spk_alpha == null:
		transparency = cube.transparency
	else:
		transparency = 1.0 - spk_alpha

	var cube_edges = speaker.get_node("cube/cube_edges")
	var cube_edges_mesh = cube_edges.get_node("Cube")

	if speaker.spk_is_selected:
		cube.material_override = spk_cube_mat_selected
		cube_edges_mesh.material_override = spk_cube_edges_mat_selected
		# Transparent is 0 in SG and 1 in Godot.
		cube.transparency = 0.0
	elif speaker.spk_is_direct_out_only:
		cube.material_override = spk_cube_dark_mat
		cube_edges_mesh.material_override = spk_cube_edges_mat
		# Transparent is 0 in SG and 1 in Godot.
		cube.transparency = transparency
	else:
		cube.material_override = spk_cube_light_mat
		cube_edges_mesh.material_override = spk_cube_edges_mat
		# Transparent is 0 in SG and 1 in Godot.
		cube.transparency = transparency
	should_autoscale = true

var should_autoscale = false

func decrement_scale(cube:MeshInstance3D):
	if cube == null:
		return
	var old_scale = cube.transform.basis.get_scale()[0]
	var new_scale = max(MIN_SPEAKER_SCALE, old_scale - AUTO_SCALE_INCREMENT)
	if not is_equal_approx(new_scale, old_scale):
		should_autoscale = true
		cube.scale = Vector3(new_scale, new_scale, new_scale)
		var speaker_number_mesh = cube.get_parent().speaker_number_mesh
		speaker_number_mesh.global_position = cube.get_parent().global_position + Vector3(0, 1*new_scale, 0)
		speaker_number_mesh.scale = Vector3(3*new_scale, 3*new_scale, 1*new_scale)


func autoscale_speakers():
	## This iterates over all of the speakers and tries to determine whether or not
	## they should be rescaled. This algorithm finds a speaker that is not yet scaled
	## as small as possible and that is overlapping with at least another speaker's mesh.
	## It then finds all the neighbouring speakers that are also overlapping with another speaker's mesh.
	## It finaly decreases the scale of each one of these speakers and of their displayed text by a small increment.
	## Calling this function will set the "should_autoscale" boolean to true if it did any scaling work,
	## meaning another call to this function may potentially decrease the scale further.
	should_autoscale = false
	for speaker in speakers_scenes:
		var cube:MeshInstance3D = speaker.get_node("cube")
		if is_equal_approx(cube.transform.basis.get_scale()[0], MIN_SPEAKER_SCALE):
			continue
		if speaker.get_node_or_null("cube/Area3D"):
			var overlapping_speakers = speaker.get_node("cube/Area3D").get_overlapping_areas()
			if overlapping_speakers.size() == 0:
				continue
			should_autoscale = true
			var neighbouring_areas = speaker.get_node("Neighbourhood").get_overlapping_areas()
			# we should only scale neighbours that actually overlap with something.
			var neighbours_area_we_should_scale = neighbouring_areas.filter(func(n_a): n_a.get_overlapping_areas())
			decrement_scale(cube)
			for n_area in neighbours_area_we_should_scale:
				var n_cube:MeshInstance3D = n_area.get_parent()
				decrement_scale(n_cube)

func _physics_process(delta: float) -> void:
	## we need to autoscale_speakers() here because since we rely on collisions,
	## we need to wait a physic tick for them to be updated.
	if should_autoscale:
		autoscale_speakers()

func update_single_speaker(speaker_number, prop_name, prop_value):
	## This should be called when a single attribute of a speaker is changed.
	## Right now this only happens when we receive an osc message.
	var matching_speaker = speakers_scenes.filter(func(speaker): return speaker.spk_number == int(speaker_number))
	if matching_speaker.is_empty():
		var instance = spk_scn.instantiate()
		instance.spk_number = speaker_number
		speakers_scenes.append(instance)
		add_child(instance)
		matching_speaker = instance
	else:
		matching_speaker = matching_speaker[0]

	var spk_alpha = null
	match prop_name:
		"number":
			if matching_speaker.spk_number != prop_value:
				matching_speaker.spk_number = prop_value
				matching_speaker.reset_spk_number()
		"position":
			matching_speaker.position = Vector3(prop_value[0], prop_value[2], prop_value[1]) * speakerview_node.SG_SCALE
		"is_selected":
			matching_speaker.spk_is_selected = prop_value
		"is_direct_out_only":
			matching_speaker.spk_is_direct_out_only = prop_value
		"alpha":
			spk_alpha = prop_value
		"center_position":
			matching_speaker.center_position = Vector3(prop_value[0], prop_value[2], prop_value[1]) * speakerview_node.SG_SCALE

	update_speaker_display(matching_speaker, spk_alpha)


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


func _on_osc_server_speaker_message_received(address: String, value: Variant) -> void:
	var components : PackedStringArray = address.split("/")
	if components[2] == "reset":
		set_speakers_info(["reset please"])
		return
	update_single_speaker(components[2], components[3], value)
