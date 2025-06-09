@icon("res://addons/godOSC/images/OSCReceiver.svg")
class_name OSCReceiver
extends Node
## Generic node for Receiving OSC messages. Must have an active OSCServer in the scene to work. 
## Make this node the child of a node you want to control with OSC. To add your own code, extend the 
## script attached to the OSCReceiver you create by right clicking and "extend script"

## The OSCServer to receive messages from
@export var target_server : OSCServer

var last_values = {}
var size_addr = []

func _process(delta):
	if not target_server:
		return
