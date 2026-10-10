class_name PlayerInput
extends Node
## Turns device input into the values the player reads each physics frame.
## Keyboard works in the editor. On phones, the touch controls add a joystick and two buttons.

signal web_pressed

const JUMP_BUFFER_MS: int = 150

var _jump_requested_at_ms: int = -1000000
var _touch: TouchControls = null


func _ready() -> void:
	_touch = get_node_or_null("../HUD/TouchControls") as TouchControls
	if _touch != null:
		_touch.jump_pressed.connect(request_jump)
		_touch.web_pressed.connect(func() -> void: web_pressed.emit())


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_SPACE:
		request_jump()
	elif key.keycode == KEY_E:
		web_pressed.emit()


## Returns the move stick as a Vector2. x = right, y = forward. Length is at most 1.
func get_move_axis() -> Vector2:
	var axis := Vector2.ZERO
	if Input.is_key_pressed(KEY_D):
		axis.x += 1.0
	if Input.is_key_pressed(KEY_A):
		axis.x -= 1.0
	if Input.is_key_pressed(KEY_W):
		axis.y += 1.0
	if Input.is_key_pressed(KEY_S):
		axis.y -= 1.0
	if _touch != null:
		axis += _touch.get_joystick_axis()
	return axis.limit_length(1.0)


func request_jump() -> void:
	_jump_requested_at_ms = Time.get_ticks_msec()


## True once per jump press, if the press is recent enough to still count.
func consume_jump() -> bool:
	var fresh: bool = Time.get_ticks_msec() - _jump_requested_at_ms <= JUMP_BUFFER_MS
	_jump_requested_at_ms = -1000000
	return fresh
