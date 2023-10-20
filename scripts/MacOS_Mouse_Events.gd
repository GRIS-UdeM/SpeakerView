extends Node

var platform_is_macos: bool = false

var udp_server: PacketPeerUDP
var speakerview_IP: String = "127.0.0.1"
var speakerview_port: int = 18021

var packet: PackedByteArray
var message: String
var json_data: JSON

var num_of_udp_packets: int

var packer: PCKPacker

var speakerview_node

func _ready():
	platform_is_macos = OS.get_name() == "macOS"
	
	if platform_is_macos:
		speakerview_node = get_node("/root/SpeakerView")
		udp_server = PacketPeerUDP.new()
		udp_server.bind(speakerview_port, speakerview_IP)

func _process(_delta):
	if !platform_is_macos:
		return
	
	# for some reason the server does not always bind...
	if not udp_server.is_bound():
		udp_server.bind(speakerview_port, speakerview_IP)
	
	num_of_udp_packets = udp_server.get_available_packet_count()
	while udp_server.get_available_packet_count() > 0:
		packet = udp_server.get_packet()
		message = packet.get_string_from_ascii()
	
	speakerview_node.macos_mouse_left_button_state = message
	
