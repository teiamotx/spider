class_name TouchControls
extends Control
## Phone controls. Each finger is tracked by its touch index, so a thumb on the joystick
## and a finger on Jump can be down at the same time.
## Left half of the screen: floating joystick, which appears where the finger lands.
## Right side: Web and Jump buttons.

signal web_pressed
signal jump_pressed

enum Role { NONE, JOYSTICK, WEB, JUMP }

@export var joystick_radius: float = 90.0
@export var joystick_dead_zone: float = 0.12
@export var button_radius: float = 64.0

var _roles: Dictionary = {}  # touch index -> Role
var _joy_index: int = -1
var _joy_origin: Vector2 = Vector2.ZERO
var _joy_knob: Vector2 = Vector2.ZERO
var _web_held: bool = false
var _jump_held: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_down(touch.index, touch.position)
		else:
			_touch_up(touch.index)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_touch_drag(drag.index, drag.position)


## Stick vector for the player. x = right, y = forward, length at most 1.
func get_joystick_axis() -> Vector2:
	if _joy_index == -1:
		return Vector2.ZERO
	var raw := Vector2(_joy_knob.x - _joy_origin.x, _joy_origin.y - _joy_knob.y) / joystick_radius
	var length: float = raw.length()
	if length <= joystick_dead_zone:
		return Vector2.ZERO
	return raw / length * clampf(inverse_lerp(joystick_dead_zone, 1.0, length), 0.0, 1.0)


func _touch_down(index: int, pos: Vector2) -> void:
	if _in_circle(pos, _jump_center()):
		_roles[index] = Role.JUMP
		_jump_held = true
		jump_pressed.emit()
	elif _in_circle(pos, _web_center()):
		_roles[index] = Role.WEB
		_web_held = true
		web_pressed.emit()
	elif pos.x < size.x * 0.5 and _joy_index == -1:
		_roles[index] = Role.JOYSTICK
		_joy_index = index
		_joy_origin = pos
		_joy_knob = pos
	queue_redraw()


func _touch_drag(index: int, pos: Vector2) -> void:
	if index == _joy_index:
		_joy_knob = _joy_origin + (pos - _joy_origin).limit_length(joystick_radius)
		queue_redraw()


func _touch_up(index: int) -> void:
	var role: int = _roles.get(index, Role.NONE)
	_roles.erase(index)
	if index == _joy_index:
		_joy_index = -1
	match role:
		Role.WEB:
			_web_held = false
		Role.JUMP:
			_jump_held = false
	queue_redraw()


func _in_circle(pos: Vector2, center: Vector2) -> bool:
	return pos.distance_to(center) <= button_radius


func _jump_center() -> Vector2:
	return Vector2(size.x - 120.0, size.y - 120.0)


func _web_center() -> Vector2:
	return Vector2(size.x - 290.0, size.y - 120.0)


func _draw() -> void:
	_draw_button(_web_center(), "WEB", _web_held)
	_draw_button(_jump_center(), "JUMP", _jump_held)
	if _joy_index != -1:
		draw_circle(_joy_origin, joystick_radius, Color(1.0, 1.0, 1.0, 0.12))
		draw_arc(_joy_origin, joystick_radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.4), 3.0)
		draw_circle(_joy_knob, joystick_radius * 0.45, Color(1.0, 1.0, 1.0, 0.5))


func _draw_button(center: Vector2, label: String, held: bool) -> void:
	draw_circle(center, button_radius, Color(1.0, 1.0, 1.0, 0.45 if held else 0.18))
	draw_arc(center, button_radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.5), 3.0)
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 22
	var text_width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, center + Vector2(-text_width * 0.5, font_size * 0.35), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1.0, 1.0, 1.0, 0.9))
