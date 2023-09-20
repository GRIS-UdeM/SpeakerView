extends Camera3D

const CAMERA_MIN_RADIUS: float = 6.0
const CAMERA_MAX_RADIUS: float = 70.0

var cam_light

func _ready():
	look_at(Vector3(0.0, 1.0, 0.0))
	cam_light = $cam_light

func _process(_delta):
	look_at(Vector3(0.0, 1.0, 0.0), Vector3(0, 1, 0))
	cam_light.look_at(Vector3(0, 0, 0), Vector3(0, 1, 0))
