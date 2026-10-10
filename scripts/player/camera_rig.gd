class_name CameraRig
extends Node3D
## Third-person follow camera. The rig is a top-level child of the player, so it moves
## with the player's position but not its rotation. Its yaw eases toward the direction
## of travel, so the camera trails behind the player. FOV widens with speed.

@export var follow_speed: float = 8.0
@export var turn_speed: float = 3.0
@export var look_height: float = 0.6
@export var base_fov: float = 68.0
@export var max_fov: float = 90.0
## Speed in m/s at which max_fov is reached.
@export var fov_speed_ref: float = 25.0

## Current heading of the camera. Player movement reads this.
var yaw: float = 0.0

@onready var _body: CharacterBody3D = get_parent() as CharacterBody3D
@onready var _camera: Camera3D = $Camera3D


func _ready() -> void:
	global_position = _body.global_position + Vector3.UP * look_height


func _physics_process(delta: float) -> void:
	var look_at_pos: Vector3 = _body.global_position + Vector3.UP * look_height
	global_position = global_position.lerp(look_at_pos, 1.0 - exp(-follow_speed * delta))

	var flat := Vector3(_body.velocity.x, 0.0, _body.velocity.z)
	if flat.length() > 1.0:
		# Heading whose local forward (-Z) points along the travel direction.
		var desired_yaw: float = atan2(-flat.x, -flat.z)
		yaw = lerp_angle(yaw, desired_yaw, 1.0 - exp(-turn_speed * delta))
	rotation.y = yaw

	var speed_t: float = clampf(_body.velocity.length() / fov_speed_ref, 0.0, 1.0)
	_camera.fov = lerpf(base_fov, max_fov, speed_t)
