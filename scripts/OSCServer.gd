@icon("res://addons/godOSC/images/OSCServer.svg")
class_name OSCServer
extends Node
## Server for recieving Open Sound Control messages over UDP.

## This is a modified version of https://github.com/afarra6/godOSC/blob/main/addons/godOSC/scripts/OSCServer.gd
## Thanks.

## The port over which to recieve messages
@export var port = 4646

## The amount of OSC packets to parse per frame. Higher parse rates are more responsive
## but require more calculations per frame. The default rate should work for most use cases.
## A simple way to determine
## a reasonable parse rate would be to use the following equation:
## amount of recieved messages * average message rate / 60.
#@export var parse_rate = 10 deprecated
var server = UDPServer.new()
var peers: Array[PacketPeerUDP] = []

signal speaker_message_received(address:String, value)
signal source_message_received(address:String, value)
signal control_message_received(address:String, value)

func _ready():
	server.listen(port)
	server.max_pending_connections = 10000000000000

## Sets the port for the server to listen on. Can only listen to one port at a time.
func listen(new_port):
	server.stop()
	port = new_port
	server.listen(port)

func _process(_delta):
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)

	parse()


## Parses an OSC packet. This is not intended to be called directly outside of the OSCServer
func parse():
	for peer in peers:
		for l in range(peer.get_available_packet_count()):
			var packet = peer.get_packet()

			if packet.get_string_from_ascii() == "#bundle":
				parse_bundle(packet)
			else:
				parse_message(packet)

func parse_message(packet: PackedByteArray):
	var comma_index = packet.find(44)
	var address = packet.slice(0, comma_index).get_string_from_ascii()
	var args = packet.slice(comma_index, packet.size())
	var tags = args.get_string_from_ascii()
	var vals = []

	args = args.slice(ceili((tags.length() + 1) / 4.0) * 4, args.size())

	for tag in tags.to_ascii_buffer():
		match tag:
			44: #,: comma
				pass
			70: #false
				vals.append(false)
			84: #true
				vals.append(true)
			105: #i: int32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_s32(0))
				args = args.slice(4, args.size())
			102: #f: float32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_float(0))
				args = args.slice(4, args.size())
			115: #s: string
				var val = args.get_string_from_ascii()
				vals.append(val)
				args = args.slice(ceili((val.length() + 1) / 4.0) * 4, args.size())
			98:  #b: blob
				vals.append(args)


	if vals is Array and len(vals) == 1:
		vals = vals[0]
	if address.begins_with("/source"):
		source_message_received.emit(address, vals)
	if address.begins_with("/speaker"):
		speaker_message_received.emit(address, vals)
	if address.begins_with("/control"):
		control_message_received.emit(address, vals)

#Handle and parse incoming bundles
func parse_bundle(packet: PackedByteArray):

	packet = packet.slice(7)
	var mess_num = []
	var bund_ind = 0
	var messages = []

	# Find beginning of messages in bundle
	for i in range(packet.size()/4.0):
		var bund_arr = PackedByteArray([32,0,0,0])
		var testo = ""
		if packet.slice(i*4, i*4+4) == PackedByteArray([1, 0, 0, 0]):
			mess_num.append(i*4)
			bund_ind + 1

		elif packet[i*4+1] == 47 and packet[i*4 - 2] <= 0 and packet.slice(i*4 - 4, i*4) != PackedByteArray([1, 0, 0, 0]):
			mess_num.append(i*4-4)


		pass

	# Add messages to an array
	for i in range(len(mess_num)):

		if i  < len(mess_num) - 1:
			messages.append(packet.slice(mess_num[i]+4, mess_num[i+1]+1))
		else:
			var pack = packet.slice(mess_num[i]+4)

			messages.append(pack)




	# Iterate and parse the messages
	for bund_packet in messages:

		bund_packet.remove_at(0)
		bund_packet.insert(0,0)
		var comma_index = bund_packet.find(44)
		var address = bund_packet.slice(1, comma_index).get_string_from_ascii()
		var args = bund_packet.slice(comma_index, packet.size())
		var tags = args.get_string_from_ascii()
		var vals = []


		args = args.slice(ceili((tags.length() + 1) / 4.0) * 4, args.size())

		for tag in tags.to_ascii_buffer():
			match tag:
				44: #,: comma
					pass
				70: #false
					vals.append(false)
					args = args.slice(4, args.size())
				84: #true
					vals.append(true)
					args = args.slice(4, args.size())
				105: #i: int32
					var val = args.slice(0, 4)
					val.reverse()
					vals.append(val.decode_s32(0))
					args = args.slice(4, args.size())
				102: #f: float32
					var val = args.slice(0, 4)
					val.reverse()
					vals.append(val.decode_float(0))
					args = args.slice(4, args.size())
				115: #s: string
					var val = args.get_string_from_ascii()
					vals.append(val)
					args = args.slice(ceili((val.length() + 1) / 4.0) * 4, args.size())
				98:  #b: blob
					vals.append(args)

		if address.begins_with("/source"):
			source_message_received.emit(address, vals)
		if address.begins_with("/speaker"):
			speaker_message_received.emit(address, vals)
		if address.begins_with("/control"):
			control_message_received.emit(address, vals)


func _on_text_edit_value_changed(value: float) -> void:
	print(value)
	listen(value)
