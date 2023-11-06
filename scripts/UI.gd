extends Control

enum MenuItemId {SEPARATOR_CMDS=0,
				SHOW_ROOM,
				SHOW_VBAP_SPANS_COMPLETE_SPHERE,
				SEPARATOR_WINDOW,
				TOGGLE_FULLSCREEN,
				SHOW_FRAMES_PER_SECOND,
				SEPARATOR_APP,
				ABOUT_WINDOW}

var commands: Array

var speakerview_node
var network_node
var framerate_node
var room_node
var params_node

var show_room: bool = false
var show_framerate: bool = false

func _ready():
	speakerview_node = get_node("/root/SpeakerView")
	network_node = get_parent().get_node("Network")
	framerate_node = get_parent().get_node("FrameRate")
	room_node = get_node("/root/SpeakerView/room")
	params_node = get_node("MenuBar/Params")
	
	commands.append("Commands")
	commands.append("Show Room")
	commands.append("Show Vbap Spans Complete Sphere")
	commands.append("Window")
	commands.append("Toggle Fullscreen")
	commands.append("Show Frames Per Second")
	commands.append("Application")
	commands.append("About SpeakerView")
	
	params_node.get_popup().add_separator(commands[MenuItemId.SEPARATOR_CMDS], MenuItemId.SEPARATOR_CMDS)

	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_ROOM] + " (R)", MenuItemId.SHOW_ROOM)
	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_VBAP_SPANS_COMPLETE_SPHERE] + " (S)", MenuItemId.SHOW_VBAP_SPANS_COMPLETE_SPHERE)
	
	params_node.get_popup().add_separator(commands[MenuItemId.SEPARATOR_WINDOW], MenuItemId.SEPARATOR_WINDOW)
	params_node.get_popup().add_check_item(commands[MenuItemId.TOGGLE_FULLSCREEN] + " (F)", MenuItemId.TOGGLE_FULLSCREEN)
	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_FRAMES_PER_SECOND] + "", MenuItemId.SHOW_FRAMES_PER_SECOND)
	
	params_node.get_popup().add_separator(commands[MenuItemId.SEPARATOR_APP], MenuItemId.SEPARATOR_APP)
	params_node.get_popup().add_item(commands[MenuItemId.ABOUT_WINDOW], MenuItemId.ABOUT_WINDOW)
	
	params_node.get_popup().id_pressed.connect(_on_popup_menu_id_pressed)
	
	set_menu_scale()

func _on_params_about_to_popup():
	set_menu_scale()
	var popup = params_node.get_popup()
	
	popup.set_item_checked(MenuItemId.SHOW_ROOM, show_room)
	popup.set_item_checked(MenuItemId.SHOW_VBAP_SPANS_COMPLETE_SPHERE, speakerview_node.use_vbap_complete_sphere)
	popup.set_item_checked(MenuItemId.TOGGLE_FULLSCREEN, get_viewport().get_mode() == Window.MODE_FULLSCREEN)
	popup.set_item_checked(MenuItemId.SHOW_FRAMES_PER_SECOND, show_framerate)

func _on_popup_menu_id_pressed(id: int):
	match id:
		MenuItemId.SHOW_ROOM:
			handle_show_room()
		MenuItemId.SHOW_VBAP_SPANS_COMPLETE_SPHERE:
			handle_show_vbap_spans_complete_sphere()
		MenuItemId.TOGGLE_FULLSCREEN:
			handle_fullscreen()
		MenuItemId.SHOW_FRAMES_PER_SECOND:
			handle_show_framerate()
		MenuItemId.ABOUT_WINDOW:
			speakerview_node.handle_show_about_window()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.get_modifiers_mask() == 0 and event.echo == false and event.keycode == KEY_F:
			handle_fullscreen()
		elif event.pressed and event.get_modifiers_mask() == 0 and event.echo == false and event.keycode == KEY_R:
			handle_show_room()
		elif event.pressed and event.get_modifiers_mask() == 0 and event.echo == false and event.keycode == KEY_S:
			handle_show_vbap_spans_complete_sphere()

func handle_show_room():
	var floor_deep_node = room_node.get_node("floor_deep")
	var wall_left_node = room_node.get_node("wall_left")
	var wall_front_node = room_node.get_node("wall_front")
	var wall_back_node = room_node.get_node("wall_back")
	var wall_right_node = room_node.get_node("wall_right")
	var floor_stage_node = room_node.get_node("floor_stage")
	floor_deep_node.visible = !floor_deep_node.visible
	wall_left_node.visible = !wall_left_node.visible
	wall_front_node.visible = !wall_front_node.visible
	wall_back_node.visible = !wall_back_node.visible
	wall_right_node.visible = !wall_right_node.visible
	floor_stage_node.visible = !floor_stage_node.visible
	
	show_room = !show_room

func handle_show_vbap_spans_complete_sphere():
	speakerview_node.use_vbap_complete_sphere = !speakerview_node.use_vbap_complete_sphere

func handle_fullscreen():
	var mode = get_viewport().get_mode()
	if mode == Window.MODE_FULLSCREEN:
		get_viewport().set_mode(Window.MODE_WINDOWED)
	else:
		get_viewport().set_mode(Window.MODE_FULLSCREEN)

func handle_show_framerate():
	show_framerate = !show_framerate
	framerate_node.visible = show_framerate

func set_menu_scale():
	var new_scale_factor: float
	
	match OS.get_name():
		"Windows", "UWP", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			new_scale_factor = 1.0
		"macOS":
			new_scale_factor = DisplayServer.screen_get_dpi() / 160.0
	
	params_node.get_popup().add_theme_font_size_override("font_size", get_theme_default_font_size() * new_scale_factor)
	params_node.scale = Vector2(0.04 * new_scale_factor, 0.04 * new_scale_factor)

func _process(_delta):
	if show_framerate:
		framerate_node.text = str("FPS : ", Engine.get_frames_per_second())
