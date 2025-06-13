class_name Utils
extends Node

static func are_colinear(v1:Vector3, v2:Vector3):
	return v1.cross(v2).is_equal_approx(Vector3.ZERO)

static func safe_look_at(obj: Node3D, target: Vector3):
	if not obj.global_position.is_equal_approx(target) and not Utils.are_colinear(target, Vector3.UP):
		obj.look_at(target, Vector3.UP, true)
