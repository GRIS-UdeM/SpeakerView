extends Node3D

enum SpatMode {DOME=0, CUBE=1, HYBRID=2}

var app_version: String = ProjectSettings.get_setting("application/config/version")
var rendering_method: String
var renderer: String

# Settings
var vsync: bool = true
var fps_max: int = 0
var msaa_3d = [[Viewport.MSAA_DISABLED, "Disabled"],
			   [Viewport.MSAA_2X, "2X"],
			   [Viewport.MSAA_4X, "4X"],
			   [Viewport.MSAA_8X, "8X"]]
var anti_aliasing: Viewport.MSAA = Viewport.MSAA_2X

const SG_SCALE: float = 10.0
const MAX_ELEVATION = 89.0
const MIN_ELEVATION = -89.0
const MIN_ZOOM: float = 4.0
const MAX_ZOOM: float = 70.0
const ZOOM_RANGE: float = MAX_ZOOM - MIN_ZOOM
const ZOOM_CURVE: float = 0.7
const INVERSE_ZOOM_CURVE: float = 1.0 / ZOOM_CURVE
const MOUSE_DRAG_SPEED: float = 0.1

var selected_speaker_number: int = 0
var reset_sources_position: bool = false
var quitting: bool = false

var SV_has_received_SG_data_at_least_once: bool = false
var should_move_SG_to_foreground: bool = false
var SG_has_focus_last_focus: bool = false
var SV_keep_on_top_last: bool = false
var show_hall_last: bool = false
var SV_should_grab_focus_last: bool = false
var spk_is_selected_with_mouse: bool = false

var window_position: Vector2i
var window_size: Vector2i

# command line args
var is_started_by_SG: bool = false
var SV_started_by_SG_for_the_first_time: bool = false
var speakerview_window_position: Vector2i
var speakerview_window_size: Vector2i

var SG_asked_to_kill_speakerview: bool = false
var speaker_setup_name: String = ""
var old_speaker_setup_name: String = ""
var SG_has_focus: bool = false
var SV_keep_on_top: bool = false
var SV_should_grab_focus: bool = false
var spat_mode: SpatMode
var show_hall: bool = false
var show_source_numbers: bool
var show_speaker_numbers: bool
var show_speakers: bool
var show_speaker_triplets: bool
var show_source_activity: bool
var show_speaker_level: bool
var show_sphere_or_cube: bool
var spk_triplets: Array
var SG_is_muted: bool = false

var cam_radius = 20.0
var rotation_speed = 0.1
var camera_azimuth: float = 90.0
var camera_elevation: float = 15.0
var camera_zoom_velocity: float = 0.0

var sphere_grid
var cube_grid

# MacOS focus
var platform_is_macos: bool = false

var settings_window = preload("res://scenes/settings_window.tscn")
var settings_window_inst

var network_node
var dome_grid_node
var cube_grid_node
var triplets_node
var speakers_node
var camera_node
var hall_node

func _ready():
	network_node = get_node("Network")
	dome_grid_node = get_node("origin_grid/dome")
	cube_grid_node = get_node("origin_grid/cube")
	triplets_node = get_node("triplets")
	speakers_node = get_node("Speakers")
	camera_node = get_node("Center/Camera")
	hall_node = get_node("hall")
	
	sphere_grid = $sphere_grid
	cube_grid = $cube_grid
	
	platform_is_macos = OS.get_name() == "macOS"
	
	rendering_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	window_position = get_viewport().position
	window_size = get_viewport().size
	
	var args = OS.get_cmdline_user_args()
	var dbgArgs: String = ""
	for arg in args:
		if arg == "launchedBySG=true":
			is_started_by_SG = true
		elif arg == "firstLaunchBySG=true":
			SV_started_by_SG_for_the_first_time = true
		elif arg.contains("winPosition="):
			var values = arg.get_slice('=', 1)
			var split_values = values.split(",", false, 2)
			speakerview_window_position = Vector2i(int(split_values[0]), int(split_values[1]))
		elif arg.contains("winSize="):
			var values = arg.get_slice('=', 1)
			var split_values = values.split(",", false, 2)
			speakerview_window_size = Vector2i(int(split_values[0]), int(split_values[1]))
		elif arg.contains("camPos="):
			var values = arg.get_slice('=', 1)
			var split_values = values.split(",", false, 3)
			camera_azimuth = float(split_values[0])
			camera_elevation = float(split_values[1])
			cam_radius = float(split_values[2])
			clampf(cam_radius, camera_node.CAMERA_MIN_RADIUS, camera_node.CAMERA_MAX_RADIUS)
		dbgArgs += arg + " "
	$Debug.text = dbgArgs
	
	get_viewport().initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_ABSOLUTE
	if speakerview_window_position != Vector2i(0, 0):
		get_viewport().position = speakerview_window_position
	if speakerview_window_size != Vector2i(0, 0):
		get_viewport().size = speakerview_window_size
	
	match rendering_method:
		"forward_plus":
			renderer = "Forward"
		"mobile":
			renderer = "Mobile"
		"gl_compatibility":
			renderer = "Compatibility"
	
	load_settings()
	
	get_viewport().set_title("SpeakerView " + app_version + " " + renderer + " - " + speaker_setup_name)
	
	if platform_is_macos and is_started_by_SG:
		should_move_SG_to_foreground = !SV_started_by_SG_for_the_first_time

func _process(delta):
#	$FrameRate.text = str("FPS : ", Engine.get_frames_per_second())
	if !is_started_by_SG:
		show_noSG_alert()
		return
	
	if window_position != get_viewport().position or window_size != get_viewport().size:
		window_position = get_viewport().position
		window_size = get_viewport().size
		network_node.send_UDP()
	
	if is_started_by_SG:
		# update_camera_position has to be called here if launched by SpatGris
		update_camera_position()
		
		sphere_grid.visible = ((spat_mode == SpatMode.DOME) or (spat_mode == SpatMode.HYBRID)) and show_sphere_or_cube
		cube_grid.visible = ((spat_mode == SpatMode.CUBE) or (spat_mode == SpatMode.HYBRID)) and show_sphere_or_cube
		
		dome_grid_node.visible = (spat_mode == SpatMode.DOME) or (spat_mode == SpatMode.HYBRID)
		cube_grid_node.visible = (spat_mode == SpatMode.CUBE) or (spat_mode == SpatMode.HYBRID)
		
		# camera zoom
		var zoom_to_add = delta * camera_zoom_velocity
		var current_zoom = (camera_node.global_position.length() - MIN_ZOOM) / ZOOM_RANGE
		var scaled_zoom = pow(current_zoom, ZOOM_CURVE)
		var scaled_target_zoom = max(scaled_zoom + zoom_to_add, 0.0)
		var unclipped_target_zoom = pow(scaled_target_zoom, INVERSE_ZOOM_CURVE) * ZOOM_RANGE + MIN_ZOOM
		var target_zoom = clamp(unclipped_target_zoom, MIN_ZOOM, MAX_ZOOM)
		
		camera_zoom_velocity *= pow(0.5, delta*8)
		cam_radius = target_zoom
		cam_radius = clampf(cam_radius, camera_node.CAMERA_MIN_RADIUS, camera_node.CAMERA_MAX_RADIUS)

func _input(event):
	if is_started_by_SG:
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
			cam_radius = clampf(cam_radius, camera_node.CAMERA_MIN_RADIUS, camera_node.CAMERA_MAX_RADIUS)
		
		elif event is InputEventKey:
			if event.pressed and event.keycode == KEY_C:
				print ("c")
				camera_azimuth = 90.0
				camera_elevation = 35.0
				#look_at(Vector3(0.0, 1.0, 0.0), Vector3(0, 1, 0))
			elif event.pressed and event.get_modifiers_mask() == 0 and event.echo == false:
				if event.keycode == KEY_F:
					handle_fullscreen()
				elif event.keycode == KEY_F4:
					handle_show_settings_window()
			# Handling quitting with CTRL or META + W
			elif event.pressed and event.echo == false and event.keycode == KEY_W:
				if (platform_is_macos and event.get_modifiers_mask() == KEY_MASK_META) or (!platform_is_macos and event.get_modifiers_mask() == KEY_MASK_CTRL):
					get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			elif event.pressed and event.echo == false and event.alt_pressed and event.shift_pressed:
				handle_keep_SV_on_top()
			elif event.pressed and event.echo == false and event.alt_pressed:
				if event.keycode == KEY_H:
					handle_show_hall()
				elif event.keycode == KEY_N:
					handle_show_source_numbers()
				elif event.keycode == KEY_Z:
					handle_show_speaker_numbers()
				elif event.keycode == KEY_S:
					handle_show_speakers()
				elif event.keycode == KEY_T:
					if spat_mode != SpatMode.CUBE and show_speakers:
						handle_show_speaker_triplets()
				elif event.keycode == KEY_A:
					handle_show_source_activity()
				elif event.keycode == KEY_L:
					handle_show_speaker_level()
				elif event.keycode == KEY_O:
					handle_show_sphere_or_cube()
				elif event.keycode == KEY_Q:
					handle_general_mute()
				if event.keycode == KEY_R:
					toggle_reset_sources_positions()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_started_by_SG:
			# When closing window, send info to SpatGris
			quitting = true
			network_node.send_UDP()
			save_settings()
		get_tree().quit()

func update_camera_position():
	var x = cam_radius * cos(deg_to_rad(camera_azimuth)) * cos(deg_to_rad(camera_elevation))
	var y = cam_radius * sin(deg_to_rad(camera_elevation))
	var z = cam_radius * sin(deg_to_rad(camera_azimuth)) * cos(deg_to_rad(camera_elevation))
	
	#camera_node.global_position = Vector3(x, y, z)

func toggle_reset_sources_positions():
	reset_sources_position = true
	network_node.send_UDP()
	reset_sources_position = false

func update_app_data(data: Variant):
	SG_asked_to_kill_speakerview = data.killSV
	speaker_setup_name = data.spkStpName
	SG_has_focus = data.SGHasFocus
	SV_keep_on_top = data.KeepSVOnTop
	SV_should_grab_focus = data.SVGrabFocus
	show_hall = data.showHall
	spat_mode = data.spatMode
	show_source_numbers = data.showSourceNumber
	show_speaker_numbers = data.showSpeakerNumber
	show_speakers = data.showSpeakers
	show_speaker_triplets = data.showSpeakerTriplets
	show_source_activity = data.showSourceActivity
	show_speaker_level = data.showSpeakerLevel
	show_sphere_or_cube = data.showSphereOrCube
	spk_triplets = data.spkTriplets
	SG_is_muted = data.genMute
	
	if show_speaker_triplets and !spk_triplets.is_empty() and show_speakers:
		triplets_node.visible = true
		render_spk_triplets()
	else:
		triplets_node.visible = false
	
	if old_speaker_setup_name != speaker_setup_name:
		old_speaker_setup_name = speaker_setup_name
		get_viewport().set_title("SpeakerView " + app_version + " " + renderer + " - " + speaker_setup_name)
	
	if SG_asked_to_kill_speakerview:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
	if SV_keep_on_top != SV_keep_on_top_last or SG_has_focus != SG_has_focus_last_focus:
		get_viewport().always_on_top = SV_keep_on_top and SG_has_focus
		SG_has_focus_last_focus = SG_has_focus
		SV_keep_on_top_last = SV_keep_on_top
	
	if SV_should_grab_focus != SV_should_grab_focus_last:
		if SV_should_grab_focus:
			get_window().grab_focus()
		SV_should_grab_focus_last = SV_keep_on_top_last
	
	if show_hall != show_hall_last:
		draw_hall()
		show_hall_last = show_hall
	
	if should_move_SG_to_foreground:
		SG_move_to_foreground()
		should_move_SG_to_foreground = false
	
	if !SV_has_received_SG_data_at_least_once:
		network_node.send_UDP()
		SV_has_received_SG_data_at_least_once = true

func render_spk_triplets():
	var vertices = PackedVector3Array()
	
	for triplet in spk_triplets:
		var spk_1 = speakers_node.get_speaker(triplet[0])
		var spk_2 = speakers_node.get_speaker(triplet[1])
		var spk_3 = speakers_node.get_speaker(triplet[2])
		
		if spk_1 != null and spk_2 != null and spk_3 != null:
			vertices.push_back(Vector3(spk_1.position.x, spk_1.position.y, spk_1.position.z))
			vertices.push_back(Vector3(spk_2.position.x, spk_2.position.y, spk_2.position.z))
			vertices.push_back(Vector3(spk_1.position.x, spk_1.position.y, spk_1.position.z))
			vertices.push_back(Vector3(spk_3.position.x, spk_3.position.y, spk_3.position.z))
			vertices.push_back(Vector3(spk_2.position.x, spk_2.position.y, spk_2.position.z))
			vertices.push_back(Vector3(spk_3.position.x, spk_3.position.y, spk_3.position.z))
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	triplets_node.mesh = arr_mesh

func SG_move_to_foreground():
	var output = []
	var exit_code = OS.execute("pgrep", ["SpatGRIS"], output)
	
	if exit_code == 0 and !output.is_empty():
		var err = []
		var script_path = OS.get_executable_path().get_base_dir() + "/../../../utilities/MSGTF/moveSGToForegroundMacOS.sh"
		script_path.simplify_path()
		var _osascript_exit_code = OS.execute("bash", [script_path], err)

func handle_fullscreen():
	var mode = get_viewport().get_mode()
	if mode == Window.MODE_FULLSCREEN:
		get_viewport().set_mode(Window.MODE_WINDOWED)
	else:
		get_viewport().set_mode(Window.MODE_FULLSCREEN)

func handle_keep_SV_on_top():
	SV_keep_on_top = !SV_keep_on_top
	network_node.send_UDP()

func draw_hall():
	var floor_deep_node = hall_node.get_node("floor_deep")
	var wall_left_node = hall_node.get_node("wall_left")
	var wall_front_node = hall_node.get_node("wall_front")
	var wall_back_node = hall_node.get_node("wall_back")
	var wall_right_node = hall_node.get_node("wall_right")
	var floor_stage_node = hall_node.get_node("floor_stage")
	floor_deep_node.visible = show_hall
	wall_left_node.visible = show_hall
	wall_front_node.visible = show_hall
	wall_back_node.visible = show_hall
	wall_right_node.visible = show_hall
	floor_stage_node.visible = show_hall

func handle_show_hall():
	show_hall = !show_hall
	network_node.send_UDP()

func handle_show_source_numbers():
	show_source_numbers = !show_source_numbers
	network_node.send_UDP()

func handle_show_speaker_numbers():
	show_speaker_numbers = !show_speaker_numbers
	network_node.send_UDP()

func handle_show_speakers():
	show_speakers = !show_speakers
	network_node.send_UDP()

func handle_show_speaker_triplets():
	show_speaker_triplets = !show_speaker_triplets
	network_node.send_UDP()

func handle_show_source_activity():
	show_source_activity = !show_source_activity
	network_node.send_UDP()

func handle_show_speaker_level():
	show_speaker_level = !show_speaker_level
	network_node.send_UDP()

func handle_show_sphere_or_cube():
	show_sphere_or_cube = !show_sphere_or_cube
	network_node.send_UDP()

func handle_general_mute():
	SG_is_muted = !SG_is_muted
	network_node.send_UDP()

func show_noSG_alert():
	var alert_label = $AlertNoSGLabel
	var axes = $axes
	var win_size = get_window().size
	
	alert_label.size = win_size
	alert_label.visible = true
	axes.visible = false

func handle_show_settings_window():
	if settings_window_inst in get_children():
		settings_window_inst.move_to_foreground()
		return
	
	settings_window_inst = settings_window.instantiate()
	add_child.call_deferred(settings_window_inst)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		return
	
	if config.has_section("graphics"):
		vsync = config.get_value("graphics", "vsync")
		fps_max = config.get_value("graphics", "fps")
		anti_aliasing = config.get_value("graphics", "anti_aliasing")
		
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	Engine.max_fps = fps_max
	
	for msaa in msaa_3d:
		if anti_aliasing in msaa:
			get_viewport().set_msaa_3d(msaa[0])
	
	DebugMenu.update_settings_label()

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("graphics", "vsync", vsync)
	config.set_value("graphics", "fps", fps_max)
	config.set_value("graphics", "anti_aliasing", anti_aliasing)
	
	config.save("user://settings.cfg")

func set_SV_anti_aliasing(msaa: Viewport.MSAA) -> void:
	get_viewport().set_msaa_3d(msaa)
	anti_aliasing = get_viewport().get_msaa_3d()
	DebugMenu.update_settings_label()
	
