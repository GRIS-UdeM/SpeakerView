extends Node3D

var text_x_axis
var text_y_axis
var text_z_axis


func _ready():
	text_x_axis = $text_x
	text_y_axis = $text_y
	text_z_axis = $text_z


func _process(_delta):
	var camera = get_viewport().get_camera_3d()
	text_x_axis.look_at(Vector3(camera.global_position.x, 0.0, camera.global_position.z), Vector3(0, 1, 0), true)
	text_y_axis.look_at(Vector3(camera.global_position.x, 0.0, camera.global_position.z), Vector3(0, 1, 0), true)
	text_z_axis.look_at(Vector3(camera.global_position.x, camera.global_position.y, camera.global_position.z), Vector3(0, 1, 0), true)
