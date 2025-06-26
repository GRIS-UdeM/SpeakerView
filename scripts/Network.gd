extends Node

var udp_peer: PacketPeerUDP
var udp_server: PacketPeerUDP

const DEFAULT_SG_IP: String = "127.0.0.1"
const DEFAULT_OUTPUT_PORT: int = 18023
const DEFAULT_INPUT_PORT: int = 18022

var current_sg_ip: String = DEFAULT_SG_IP
var current_output_port: int = DEFAULT_OUTPUT_PORT
var current_input_port: int = DEFAULT_INPUT_PORT

var packet: PackedByteArray
var message: String
var json_data: JSON

var num_of_udp_packets: int

var speakerview_node
var sources_node
var speakers_node
var ip_regex = RegEx.new()

func _ready():
	# This regex validates ip addresses. It was taken here : https://stackoverflow.com/a/36760050
	ip_regex.compile("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$")
	speakerview_node = get_node("/root/SpeakerView")
	sources_node = get_node("/root/SpeakerView/Sources")
	speakers_node = get_node("/root/SpeakerView/Speakers")

	# Listen to SpatGris
	udp_peer = PacketPeerUDP.new()
	udp_peer.set_dest_address(current_sg_ip, DEFAULT_OUTPUT_PORT)
	# Send to SpatGris
	udp_server = PacketPeerUDP.new()
	udp_server.bind(DEFAULT_INPUT_PORT)
	current_input_port = udp_server.get_local_port()
	json_data = JSON.new()

func _physics_process(_delta: float) -> void:
	listen_to_UDP()

func reconnect_udp_input(port) -> Error:
	udp_server.close()
	udp_server = PacketPeerUDP.new()
	return udp_server.bind(port)

func send_UDP():
	var camera_node = %OrbitCamera
	var json_dict_to_send = {"quitting":speakerview_node.quitting,
		"winPos":get_viewport().position,
		"winSize":get_viewport().size,
		"camPos":str(-camera_node.camera_azimuth, ",", camera_node.camera_elevation, ",", camera_node.cam_radius),
		"selSpkNum":str(speakerview_node.selected_speaker_number, ",", speakerview_node.spk_is_selected_with_mouse),
		"keepSVTop":speakerview_node.SV_keep_on_top,
		"showHall":speakerview_node.show_hall,
		"showSrcNum":speakerview_node.show_source_numbers,
		"showSpkNum":speakerview_node.show_speaker_numbers,
		"showSpks":speakerview_node.show_speakers,
		"showSpkTriplets":speakerview_node.show_speaker_triplets,
		"showSrcActivity":speakerview_node.show_source_activity,
		"showSpkLevel":speakerview_node.show_speaker_level,
		"showSphereCube":speakerview_node.show_sphere_or_cube,
		"resetSrcPos":speakerview_node.reset_sources_position,
		"genMute":speakerview_node.SG_is_muted}
	var json_string = JSON.stringify(json_dict_to_send, "\t")
	udp_peer.put_packet(json_string.to_ascii_buffer())

func listen_to_UDP():
	# for some reason the server does not always bind...
	if not udp_server.is_bound():
		udp_server.bind(current_input_port, current_sg_ip)

	num_of_udp_packets = udp_server.get_available_packet_count()
	while udp_server.get_available_packet_count() > 0:
		packet = udp_server.get_packet()
		message = packet.get_string_from_ascii()

		# Parse JSON data
		json_data.data = null
		if json_data.parse(message) == OK:
			if typeof(json_data.data) == Variant.Type.TYPE_ARRAY:
				if json_data.data[0] == "sources":
					sources_node.set_sources_info(json_data.data)
				elif json_data.data[0] == "speakers":
					speakers_node.set_speakers_info(json_data.data)
			elif typeof(json_data.data) == Variant.Type.TYPE_DICTIONARY:
				speakerview_node.update_app_data_from_json(json_data.data)


func update_settings_boxes():
	## calling this will trigger the text change signal of these
	## three elements, which is why we need to check for identical values
	## at the beginning of the three callbacks below.
	%SpatGRISIPLineEdit.text = DEFAULT_SG_IP
	%UDPINSpinBox.value = current_input_port
	%UDPINSpinBox.value = current_input_port

func _on_spat_grisip_line_edit_focus_exited() -> void:
	_on_spat_grisip_line_edit_text_submitted(%SpatGRISIPLineEdit.text)

func _on_spat_grisip_line_edit_text_submitted(spatgris_ip: String) -> void:
	if spatgris_ip == current_sg_ip:
		return
	if ip_regex.search(spatgris_ip):
		current_sg_ip = spatgris_ip
		udp_peer.set_dest_address(spatgris_ip, current_output_port)
	else:
		# if the regex do not validate, replace the text with the last valid
		# address
		update_settings_boxes()

func _on_udpin_spin_box_value_changed(udp_in_port: float) -> void:
	if udp_in_port == current_input_port:
		return
	var success: Error = reconnect_udp_input(udp_in_port)
	if success == OK:
		current_input_port = udp_in_port
	else:
		reconnect_udp_input(current_input_port)
		update_settings_boxes()


func _on_udpout_spin_box_value_changed(udp_out_port: float) -> void:
	var success: Error = udp_peer.set_dest_address(current_sg_ip, udp_out_port)
	if success == OK:
		current_output_port = udp_out_port
	else:
		udp_peer.set_dest_address(current_sg_ip, current_output_port)
		update_settings_boxes()
