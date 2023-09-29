extends Node3D

@export var spk_number: int
@export var spk_is_selected: bool
@export var spk_is_direct_out_only: bool
#@export var spk_alpha: float

var speaker_number_mesh

var speakerview_node
var network_node
var camera_node
var speakers_node

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	network_node = get_node("/root/SpeakerView/Network")
	camera_node = get_node("/root/SpeakerView/Center/Camera")
	speakers_node = get_parent()
	
	# speaker number
	var spk_num_new_mesh_3d = MeshInstance3D.new()
	var text_mesh = TextMesh.new()
	text_mesh.set_depth(0.0)
	spk_num_new_mesh_3d.mesh = text_mesh
	spk_num_new_mesh_3d.material_override = speakers_node.spk_num_mat
	speaker_number_mesh = spk_num_new_mesh_3d
	
	add_child(speaker_number_mesh)
	look_at(Vector3(0, 0, 0), Vector3(0, 1, 0), true)

	speaker_number_mesh.global_position = global_position + Vector3(0, 1, 0)
	speaker_number_mesh.scale = Vector3(3, 3, 1)
	speaker_number_mesh.set_cast_shadows_setting(0)
	speaker_number_mesh.mesh.set_text(str(spk_number))

func _process(_delta):
	speaker_number_mesh.visible = speakerview_node.show_speaker_number
	if speaker_number_mesh.visible:
		speaker_number_mesh.look_at(camera_node.global_position, Vector3(0, 1, 0), true)

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click == true:
			speakerview_node.selected_speaker_number = spk_number
			network_node.send_UDP()
