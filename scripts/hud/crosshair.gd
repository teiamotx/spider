class_name Crosshair
extends Control
## Plus-sign crosshair at the center of the screen. The web is aimed from here.

@export var arm_length: float = 10.0
@export var gap: float = 4.0
@export var thickness: float = 2.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var col := Color(1.0, 1.0, 1.0, 0.85)
	draw_line(c + Vector2(-gap - arm_length, 0.0), c + Vector2(-gap, 0.0), col, thickness)
	draw_line(c + Vector2(gap, 0.0), c + Vector2(gap + arm_length, 0.0), col, thickness)
	draw_line(c + Vector2(0.0, -gap - arm_length), c + Vector2(0.0, -gap), col, thickness)
	draw_line(c + Vector2(0.0, gap), c + Vector2(0.0, gap + arm_length), col, thickness)
