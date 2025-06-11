extends Node

var udp_peer: PacketPeerUDP
var udp_server: PacketPeerUDP

var SG_IP: String = "127.0.0.1"
var SG_port: int = 18023
var speakerview_IP: String = "127.0.0.1"
var speakerview_port: int = 18022

var packet: PackedByteArray
var message: String
var json_data: JSON

var num_of_udp_packets: int

var speakerview_node
var sources_node
var speakers_node

func _ready():

	speakerview_node = get_node("/root/SpeakerView")
	sources_node = get_node("/root/SpeakerView/Sources")
	speakers_node = get_node("/root/SpeakerView/Speakers")

	# Listen to SpatGris
	udp_peer = PacketPeerUDP.new()
	udp_peer.connect_to_host(SG_IP, SG_port)
	# Send to SpatGris
	udp_server = PacketPeerUDP.new()
	udp_server.bind(speakerview_port, speakerview_IP)

	json_data = JSON.new()

func _physics_process(_delta):
	listen_to_UDP()

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
		udp_server.bind(speakerview_port, speakerview_IP)

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
