class_name DebugOverlay
extends Label
## Temporary readout for testing on a phone: frame rate, physics rate, speed, and web state.
## Remove or hide it before release.

@onready var _body: CharacterBody3D = get_node("../..") as CharacterBody3D
@onready var _web: WebShooter = get_node("../../WebShooter") as WebShooter


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2(12.0, 12.0)


func _process(_delta: float) -> void:
	var web_state: String = "on" if _web.is_attached else "off"
	text = "FPS %d  physics %d\nspeed %.1f m/s  web %s" % [
		int(Engine.get_frames_per_second()),
		Engine.physics_ticks_per_second,
		_body.velocity.length(),
		web_state
	]
