class_name PlayerController
extends CharacterBody3D
## On-foot movement and swinging.
## Walking is momentum-based: ground acceleration is firm, air acceleration is weak,
## so a jump keeps the speed you brought into it. Input is relative to the camera rig's yaw.
## While the web is attached, the player is a pendulum on a rope of fixed length.
## The stick then pumps and steers with small forward and sideways pushes.

@export var max_speed: float = 9.0
@export var ground_accel: float = 14.0
@export var air_accel: float = 4.0
@export var jump_speed: float = 7.0
@export var gravity_strength: float = 14.0
## Stronger than walking gravity, so a long rope swings with a quicker period.
@export var swing_gravity: float = 22.0
@export var max_speed_cap: float = 40.0
## Stick pushes while swinging (m/s²). Sideways steers, forward pumps.
@export var swing_side_accel: float = 4.0
@export var swing_forward_accel: float = 4.0
## Release counts as "near the top" when vertical speed is at most this (m/s)...
@export var apex_vertical_speed: float = 4.0
## ...and the rope is at least this far from straight down (degrees).
@export var apex_min_angle_deg: float = 25.0
@export var apex_boost_up: float = 3.0
@export var apex_boost_forward: float = 3.0

@onready var _input: PlayerInput = $PlayerInput
@onready var _rig: CameraRig = $CameraRig
@onready var _web: WebShooter = $WebShooter


func _ready() -> void:
	_web.released.connect(_on_web_released)


func _physics_process(delta: float) -> void:
	if _web.is_attached:
		_swing_control(delta)
	else:
		_walk_control(delta)

	move_and_slide()

	if _web.is_attached:
		_enforce_rope()
	velocity = velocity.limit_length(max_speed_cap)


func _walk_control(delta: float) -> void:
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


## Gravity plus the stick's pump and steer pushes. The rope limit is applied after the move.
func _swing_control(delta: float) -> void:
	var axis: Vector2 = _input.get_move_axis()
	var push: Vector3 = _camera_relative(Vector2(axis.x * swing_side_accel, axis.y * swing_forward_accel))
	velocity += push * delta
	velocity.y -= swing_gravity * delta


## Keeps the body on the rope. Only the outward part of the velocity is removed,
## so sideways speed is kept.
func _enforce_rope() -> void:
	var offset: Vector3 = global_position - _web.anchor_point
	var dist: float = offset.length()
	if dist <= _web.rope_length:
		return
	var outward: Vector3 = offset / dist
	global_position = _web.anchor_point + outward * _web.rope_length
	var radial: float = velocity.dot(outward)
	if radial > 0.0:
		velocity -= outward * radial


## Releasing near the top of a swing adds a small lift and push, so the release feels like a launch.
## Velocity is kept either way. The boost only adds to it.
func _on_web_released() -> void:
	if is_on_floor():
		return
	var outward: Vector3 = (global_position - _web.anchor_point).normalized()
	var rope_angle: float = acos(clampf(outward.dot(Vector3.DOWN), -1.0, 1.0))
	if absf(velocity.y) > apex_vertical_speed or rope_angle < deg_to_rad(apex_min_angle_deg):
		return
	velocity += Vector3.UP * apex_boost_up
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	if flat.length() > 0.5:
		velocity += flat.normalized() * apex_boost_forward
	print("Apex release boost applied")


## Turns a stick vector into a world-space direction, using the camera's facing.
func _camera_relative(axis: Vector2) -> Vector3:
	var rig_basis: Basis = _rig.global_transform.basis
	var right: Vector3 = rig_basis.x
	var forward: Vector3 = -rig_basis.z
	right.y = 0.0
	forward.y = 0.0
	return right * axis.x + forward * axis.y
