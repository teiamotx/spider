class_name WebShooter
extends Node
## Web button logic. A press only queues a request. The raycast runs in _physics_process.
## A ray from the camera's center attaches to the first "webbable" surface within range.
## Pressing again releases. While attached, the player script keeps the body on the rope.

signal released

const WEBBABLE_GROUP: StringName = &"webbable"

@export var web_range: float = 60.0
## Attaches closer than this are refused, since a very short rope swings badly.
@export var min_rope_length: float = 3.0

var is_attached: bool = false
var anchor_point: Vector3 = Vector3.ZERO
var rope_length: float = 0.0

var _fire_queued: bool = false

@onready var _body: CharacterBody3D = get_parent() as CharacterBody3D
@onready var _camera: Camera3D = $"../CameraRig/Camera3D"
@onready var _player_input: PlayerInput = $"../PlayerInput"


func _ready() -> void:
	_player_input.web_pressed.connect(_on_web_pressed)


func _on_web_pressed() -> void:
	_fire_queued = true


func _physics_process(_delta: float) -> void:
	if not _fire_queued:
		return
	_fire_queued = false
	if is_attached:
		is_attached = false
		print("Web released at %.1f m/s" % _body.velocity.length())
		released.emit()
	else:
		_try_attach()


func _try_attach() -> void:
	var origin: Vector3 = _camera.global_position
	var forward: Vector3 = -_camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + forward * web_range)
	query.exclude = [_body.get_rid()]
	var hit: Dictionary = _body.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		print("Web missed: nothing within %d m" % int(web_range))
		return
	var collider: Node = hit["collider"] as Node
	if collider == null or not collider.is_in_group(WEBBABLE_GROUP):
		print("Web hit a surface that is not webbable")
		return
	var point: Vector3 = hit["position"]
	var distance: float = _body.global_position.distance_to(point)
	if distance < min_rope_length:
		print("Web too close to swing from")
		return
	anchor_point = point
	rope_length = distance
	is_attached = true
	print("Web attached, rope %.1f m" % rope_length)
