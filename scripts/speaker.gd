extends Node3D

@export var spk_number: int
@export var spk_is_selected: bool
@export var spk_is_direct_out_only: bool
#@export var spk_alpha: float

var speaker_number_mesh

var event_last_position: Vector2

var speakerview_node
var network_node
var speakers_node
var area_node

func are_colinear(v1:Vector3, v2:Vector3):
	return v1.cross(v2).is_equal_approx(Vector3.ZERO)

func _process(_delta):
	speaker_number_mesh.visible = speakerview_node.show_speaker_numbers
	if not global_position.is_equal_approx(Vector3.ZERO) and not are_colinear(global_position, Vector3.UP):
		look_at(Vector3.ZERO, Vector3.UP)
	if speaker_number_mesh.visible:
		speaker_number_mesh.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 1, 0), true)


func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	network_node = get_node("/root/SpeakerView/Network")
	speakers_node = get_parent()
	area_node = get_node("cube/Area3D")
	
	# speaker number
	var spk_num_new_mesh_3d = MeshInstance3D.new()
	var text_mesh = TextMesh.new()
	text_mesh.set_depth(0.0)
	spk_num_new_mesh_3d.mesh = text_mesh
	spk_num_new_mesh_3d.material_override = speakers_node.spk_num_mat
	speaker_number_mesh = spk_num_new_mesh_3d
	
	add_child(speaker_number_mesh)

	var spk_pos_normalized = transform.origin.normalized()
	var up_vector = Vector3(0, 1, 0)
	var almost_zero = 0.000001
	if abs(spk_pos_normalized.x) < almost_zero and abs(spk_pos_normalized.z) < almost_zero:
		up_vector = Vector3(0, 0, 1)
	look_at(Vector3(0, 0, 0), up_vector, true)

	speaker_number_mesh.global_position = global_position + Vector3(0, 1, 0)
	speaker_number_mesh.scale = Vector3(3, 3, 1)
	speaker_number_mesh.set_cast_shadows_setting(0)
	speaker_number_mesh.mesh.set_text(str(spk_number))

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			event_last_position = event.position
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if event_last_position == event.position:
				set_speaker_selected_state()

func reset_spk_number():
	speaker_number_mesh.mesh.set_text(str(spk_number))

func set_speaker_selected_state():
	if spk_is_selected:
		spk_is_selected = !spk_is_selected
		speakerview_node.selected_speaker_number = 0
	else:
		speakerview_node.selected_speaker_number = spk_number
	
	speakerview_node.spk_is_selected_with_mouse = true
	network_node.send_UDP()
	speakerview_node.spk_is_selected_with_mouse = false
