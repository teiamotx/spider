class_name PlayerController
extends CharacterBody3D
## On-foot movement. Momentum-based: ground acceleration is firm, air acceleration is weak,
## so a jump keeps the speed you brought into it. Input is relative to the camera rig's yaw.

@export var max_speed: float = 9.0
@export var ground_accel: float = 14.0
@export var air_accel: float = 4.0
@export var jump_speed: float = 7.0
@export var gravity_strength: float = 14.0

@onready var _input: PlayerInput = $PlayerInput
@onready var _rig: CameraRig = $CameraRig


func _physics_process(delta: float) -> void:
	var wish: Vector3 = _camera_relative(_input.get_move_axis()) * max_speed
	var flat := Vector2(velocity.x, velocity.z)
	var accel: float = ground_accel if is_on_floor() else air_accel
	flat = flat.move_toward(Vector2(wish.x, wish.z), accel * delta)
	velocity.x = flat.x
	velocity.z = flat.y

	if is_on_floor():
		velocity.y = 0.0
		if _input.consume_jump():
			velocity.y = jump_speed
	else:
		velocity.y -= gravity_strength * delta

	move_and_slide()


## Turns a stick vector into a world-space direction, using the camera's facing.
func _camera_relative(axis: Vector2) -> Vector3:
	var rig_basis: Basis = _rig.global_transform.basis
	var right: Vector3 = rig_basis.x
	var forward: Vector3 = -rig_basis.z
	right.y = 0.0
	forward.y = 0.0
	return right * axis.x + forward * axis.y
