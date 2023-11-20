extends Node3D

@export var spk_number: int
@export var spk_is_selected: bool
@export var spk_is_direct_out_only: bool
#@export var spk_alpha: float

var speaker_number_mesh

# MacOS click through
var mouse_first_click_pos: Vector2
var mouse_first_click_down: bool = false
var macos_mouse_event_last_position: Vector2i

var event_last_position: Vector2

var speakerview_node
var network_node
var camera_node
var speakers_node
var area_node

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	network_node = get_node("/root/SpeakerView/Network")
	camera_node = get_node("/root/SpeakerView/Center/Camera")
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
	look_at(Vector3(0, 0, 0), Vector3(0, 1, 0), true)

	speaker_number_mesh.global_position = global_position + Vector3(0, 1, 0)
	speaker_number_mesh.scale = Vector3(3, 3, 1)
	speaker_number_mesh.set_cast_shadows_setting(0)
	speaker_number_mesh.mesh.set_text(str(spk_number))

func _process(_delta):
	speaker_number_mesh.visible = speakerview_node.show_speaker_numbers
	if speaker_number_mesh.visible:
		speaker_number_mesh.look_at(camera_node.global_position, Vector3(0, 1, 0), true)
	
	if speakerview_node.platform_is_macos:
		if speakerview_node.macos_mouse_event == speakerview_node.MacOSMouseEvent.WAITING_FOR_RELEASE:
			if !mouse_first_click_down:
				mouse_first_click_pos = speakerview_node.macos_mouse_last_pos
				macos_mouse_event_last_position = Vector2i(get_viewport().get_mouse_position())
				mouse_first_click_down = true
		
		elif speakerview_node.macos_mouse_event == speakerview_node.MacOSMouseEvent.RELEASED and mouse_first_click_down:
			if macos_mouse_event_last_position == Vector2i(get_viewport().get_mouse_position()):
				var space_state = get_world_3d().direct_space_state
				var cam = camera_node
				var mousepos = mouse_first_click_pos
				
				var origin = cam.project_ray_origin(mousepos)
				var end = origin + cam.project_ray_normal(mousepos) * 1000
				var query = PhysicsRayQueryParameters3D.create(origin, end)
				query.collide_with_areas = true
				
				var result = space_state.intersect_ray(query)
				
				if !result.is_empty():
					if area_node == result.collider:
						set_speaker_selected_state()
				
			mouse_first_click_down = false

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			event_last_position = event.position
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if event_last_position == event.position:
				set_speaker_selected_state()


func set_speaker_selected_state():
	if spk_is_selected:
		spk_is_selected = !spk_is_selected
		speakerview_node.selected_speaker_number = -1
	else:
		speakerview_node.selected_speaker_number = spk_number
	
	network_node.send_UDP()
