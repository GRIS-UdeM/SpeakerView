extends Control

enum MenuItemId {SEPARATOR_CMDS=0,
#				SHOW_SOURCE_NUMBERS,
#				SHOW_SPEAKER_NUMBERS,
#				SHOW_SPEAKERS,
#				SHOW_SPEAKER_TRIPLETS,
#				SHOW_SOURCE_ACTIVITY,
#				SHOW_SPEAKER_LEVEL,
#				SHOW_SPHERE_CUBE,
#				RESET_SOURCE_POSITION,
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
#	commands.append("Show Source Numbers")
#	commands.append("Show Speaker Numbers")
#	commands.append("Show Speakers")
#	commands.append("Show Speaker Triplets")
#	commands.append("Show Source Activity")
#	commands.append("Show Speaker Level")
#	commands.append("Show Sphere/Cube")
#	commands.append("Reset Sources Positions")
	commands.append("Show Room")
	commands.append("Show Vbap Spans Complete Sphere")
	commands.append("Window")
	commands.append("Toggle Fullscreen")
	commands.append("Show Frames Per Second")
	commands.append("Application")
	commands.append("About SpeakerView")

#	var shortcut_string: String
#	match OS.get_name():
#		"Windows", "UWP", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
#			shortcut_string = "Alt"
#		"macOS":
#			shortcut_string = "Opt"
	
	params_node.get_popup().add_separator(commands[MenuItemId.SEPARATOR_CMDS], MenuItemId.SEPARATOR_CMDS)

#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SOURCE_NUMBERS] + " (" + shortcut_string + "+N)", MenuItemId.SHOW_SOURCE_NUMBERS)
#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SPEAKER_NUMBERS] + " (" + shortcut_string + "+Z)", MenuItemId.SHOW_SPEAKER_NUMBERS)
#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SPEAKERS] + " (" + shortcut_string + "+S)", MenuItemId.SHOW_SPEAKERS)
#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SPEAKER_TRIPLETS] + " (" + shortcut_string + "+T)", MenuItemId.SHOW_SPEAKER_TRIPLETS)
#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SOURCE_ACTIVITY] + " (" + shortcut_string + "+A)", MenuItemId.SHOW_SOURCE_ACTIVITY)
#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SPEAKER_LEVEL] + " (" + shortcut_string + "+L)", MenuItemId.SHOW_SPEAKER_LEVEL)
#	params_node.get_popup().add_check_item(commands[MenuItemId.SHOW_SPHERE_CUBE] + " (" + shortcut_string + "+O)", MenuItemId.SHOW_SPHERE_CUBE)
#
#	params_node.get_popup().add_item(commands[MenuItemId.RESET_SOURCE_POSITION] + " (" + shortcut_string + "+R)", MenuItemId.RESET_SOURCE_POSITION)
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
#	popup.set_item_checked(MenuItemId.SHOW_SOURCE_NUMBERS, speakerview_node.show_source_number)
#	popup.set_item_checked(MenuItemId.SHOW_SPEAKER_NUMBERS, speakerview_node.show_speaker_number)
#	popup.set_item_checked(MenuItemId.SHOW_SPEAKERS, speakerview_node.show_speakers)
#	popup.set_item_checked(MenuItemId.SHOW_SPEAKER_TRIPLETS, speakerview_node.show_speaker_triplets)
#	popup.set_item_checked(MenuItemId.SHOW_SOURCE_ACTIVITY, speakerview_node.show_source_activity)
#	popup.set_item_checked(MenuItemId.SHOW_SPEAKER_LEVEL, speakerview_node.show_speaker_level)
#	popup.set_item_checked(MenuItemId.SHOW_SPHERE_CUBE, speakerview_node.show_sphere_or_cube)
	popup.set_item_checked(MenuItemId.SHOW_ROOM, show_room)
	popup.set_item_checked(MenuItemId.SHOW_VBAP_SPANS_COMPLETE_SPHERE, speakerview_node.use_vbap_complete_sphere)
	popup.set_item_checked(MenuItemId.TOGGLE_FULLSCREEN, get_viewport().get_mode() == Window.MODE_FULLSCREEN)
	popup.set_item_checked(MenuItemId.SHOW_FRAMES_PER_SECOND, show_framerate)
	
#	popup.set_item_disabled(MenuItemId.SHOW_SPEAKER_TRIPLETS, speakerview_node.spat_mode == speakerview_node.SpatMode.CUBE)
	

func _on_popup_menu_id_pressed(id: int):
	match id:
#		MenuItemId.SHOW_SOURCE_NUMBERS:
#			handle_show_source_numbers()
#		MenuItemId.SHOW_SPEAKER_NUMBERS:
#			handle_show_speaker_numbers()
#		MenuItemId.SHOW_SPEAKERS:
#			handle_show_speakers()
#		MenuItemId.SHOW_SPEAKER_TRIPLETS:
#			if speakerview_node.spat_mode != speakerview_node.SpatMode.CUBE:
#				handle_show_speaker_triplets()
#		MenuItemId.SHOW_SOURCE_ACTIVITY:
#			handle_show_source_activity()
#		MenuItemId.SHOW_SPEAKER_LEVEL:
#			handle_show_speaker_level()
#		MenuItemId.SHOW_SPHERE_CUBE:
#			handle_show_sphere_or_cube()
#		MenuItemId.RESET_SOURCE_POSITION:
#			speakerview_node.toggle_reset_sources_positions()
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
#		if event.pressed and event.echo == false and event.alt_pressed:
#			if event.keycode == KEY_R:
#				speakerview_node.toggle_reset_sources_positions()
#			elif event.keycode == KEY_N:
#				handle_show_source_numbers()
#			elif event.keycode == KEY_S:
#				handle_show_speakers()
#			elif event.keycode == KEY_T:
#				if speakerview_node.spat_mode != speakerview_node.SpatMode.CUBE:
#					handle_show_speaker_triplets()
#			elif event.keycode == KEY_A:
#				handle_show_source_activity()
#			elif event.keycode == KEY_L:
#				handle_show_speaker_level()
#			elif event.keycode == KEY_O:
#				handle_show_sphere_or_cube()
#			elif event.keycode == KEY_Z:
#				handle_show_speaker_numbers()
		if event.pressed and event.get_modifiers_mask() == 0 and event.echo == false and event.keycode == KEY_F:
			handle_fullscreen()
		elif event.pressed and event.get_modifiers_mask() == 0 and event.echo == false and event.keycode == KEY_R:
			handle_show_room()
		elif event.pressed and event.get_modifiers_mask() == 0 and event.echo == false and event.keycode == KEY_S:
			handle_show_vbap_spans_complete_sphere()

#func handle_show_source_numbers():
#	speakerview_node.show_source_number = !speakerview_node.show_source_number
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SOURCE_NUMBERS, speakerview_node.show_source_number)
#	network_node.send_UDP()
#
#func handle_show_speaker_numbers():
#	speakerview_node.show_speaker_number = !speakerview_node.show_speaker_number
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SPEAKER_NUMBERS, speakerview_node.show_speaker_number)
#	network_node.send_UDP()
#
#func handle_show_speakers():
#	speakerview_node.show_speakers = !speakerview_node.show_speakers
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SPEAKERS, speakerview_node.show_speakers)
#	network_node.send_UDP()
#
#func handle_show_speaker_triplets():
#	speakerview_node.show_speaker_triplets = !speakerview_node.show_speaker_triplets
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SPEAKER_TRIPLETS, speakerview_node.show_speaker_triplets)
#	network_node.send_UDP()
#
#func handle_show_source_activity():
#	speakerview_node.show_source_activity = !speakerview_node.show_source_activity
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SOURCE_ACTIVITY, speakerview_node.show_source_activity)
#	network_node.send_UDP()
#
#func handle_show_speaker_level():
#	speakerview_node.show_speaker_level = !speakerview_node.show_speaker_level
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SPEAKER_LEVEL, speakerview_node.show_speaker_level)
#	network_node.send_UDP()
#
#func handle_show_sphere_or_cube():
#	speakerview_node.show_sphere_or_cube = !speakerview_node.show_sphere_or_cube
#	params_node.get_popup().set_item_checked(MenuItemId.SHOW_SPHERE_CUBE, speakerview_node.show_sphere_or_cube)
#	network_node.send_UDP()

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
