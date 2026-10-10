class_name PlayerInput
extends Node
## Turns device input into the values the player reads each physics frame.
## Step 2: keyboard only. Step 3 adds the touch joystick and buttons here.

const JUMP_BUFFER_MS: int = 150

var _jump_requested_at_ms: int = -1000000


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_SPACE:
		request_jump()


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
	return axis.limit_length(1.0)


func request_jump() -> void:
	_jump_requested_at_ms = Time.get_ticks_msec()


## True once per jump press, if the press is recent enough to still count.
func consume_jump() -> bool:
	var fresh: bool = Time.get_ticks_msec() - _jump_requested_at_ms <= JUMP_BUFFER_MS
	_jump_requested_at_ms = -1000000
	return fresh
