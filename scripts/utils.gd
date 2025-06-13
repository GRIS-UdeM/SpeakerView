class_name Utils
extends Node

static func are_aligned_with_up_vector(position:Vector3, target:Vector3):
	return Vector3.UP.cross(target - position).is_equal_approx(Vector3.ZERO)

static func safe_look_at(obj: Node3D, target: Vector3):
	if not obj.global_position.is_equal_approx(target) and not Utils.are_aligned_with_up_vector(obj.global_position, target):
		obj.look_at(target, Vector3.UP, true)
