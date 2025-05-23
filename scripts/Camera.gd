extends Camera3D

const CAMERA_MIN_RADIUS: float = 6.0
const CAMERA_MAX_RADIUS: float = 70.0
const MAX_ELEVATION = 89.0
const MIN_ELEVATION = -89.0
const MIN_ZOOM: float = 4.0
const MAX_ZOOM: float = 70.0
const ZOOM_RANGE: float = MAX_ZOOM - MIN_ZOOM
const ZOOM_CURVE: float = 0.7
const INVERSE_ZOOM_CURVE: float = 1.0 / ZOOM_CURVE
const MOUSE_DRAG_SPEED: float = 0.1


var cam_light
var cam_radius: float
var rotation_speed: float
var camera_azimuth: float
var camera_elevation: float
var camera_zoom_velocity: float

func init_orbit_camera():
	cam_radius = 20.0
	rotation_speed = 0.1
	camera_azimuth = 70.0
	camera_elevation = 35.0
	camera_zoom_velocity = 0.0

func init_free_camera():
	pass

func _input(event):
	input_orbit_camera(event)
	
func input_orbit_camera(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_zoom_velocity -= (camera_zoom_velocity + 2.0) * 0.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_zoom_velocity += (camera_zoom_velocity + 1.0) * 0.1
	
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		camera_azimuth += event.relative.x * MOUSE_DRAG_SPEED
		camera_elevation += event.relative.y * MOUSE_DRAG_SPEED
		camera_elevation = clamp(camera_elevation, MIN_ELEVATION, MAX_ELEVATION)
	
	# trackpad on MacOS
	elif event is InputEventPanGesture:
		cam_radius += event.delta.y
		cam_radius = clampf(cam_radius, CAMERA_MIN_RADIUS, CAMERA_MAX_RADIUS)


func update_orbit_camera(delta):
	var x = cam_radius * cos(deg_to_rad(camera_azimuth)) * cos(deg_to_rad(camera_elevation))
	var y = cam_radius * sin(deg_to_rad(camera_elevation))
	var z = cam_radius * sin(deg_to_rad(camera_azimuth)) * cos(deg_to_rad(camera_elevation))
	global_position = Vector3(x, y, z)
	# camera zoom
	var zoom_to_add = delta * camera_zoom_velocity
	var current_zoom = (global_position.length() - MIN_ZOOM) / ZOOM_RANGE
	var scaled_zoom = pow(current_zoom, ZOOM_CURVE)
	var scaled_target_zoom = max(scaled_zoom + zoom_to_add, 0.0)
	var unclipped_target_zoom = pow(scaled_target_zoom, INVERSE_ZOOM_CURVE) * ZOOM_RANGE + MIN_ZOOM
	var target_zoom = clamp(unclipped_target_zoom, MIN_ZOOM, MAX_ZOOM)
	
	camera_zoom_velocity *= pow(0.5, delta*8)
	cam_radius = target_zoom
	cam_radius = clampf(cam_radius, CAMERA_MIN_RADIUS, CAMERA_MAX_RADIUS)
	look_at(Vector3(0.0, 1.0, 0.0), Vector3(0, 1, 0))
	cam_light.look_at(Vector3(0, 0, 0), Vector3(0, 1, 0))


func _ready():
	init_orbit_camera()
	look_at(Vector3(0.0, 1.0, 0.0))
	cam_light = $cam_light

func _process(_delta):
	update_orbit_camera(_delta)
