class_name WebLine
extends MeshInstance3D
## Draws the web as a thin line from the hand to the anchor point.
## This node is top-level, so its vertices are in world space.

@onready var _shooter: WebShooter = $"../WebShooter"
@onready var _hand: Marker3D = $"../Hand"

var _mesh := ImmediateMesh.new()


func _ready() -> void:
	mesh = _mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.95, 0.95, 0.95)
	material_override = mat
	visible = false


func _process(_delta: float) -> void:
	visible = _shooter.is_attached
	if not visible:
		return
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_mesh.surface_add_vertex(_hand.global_position)
	_mesh.surface_add_vertex(_shooter.anchor_point)
	_mesh.surface_end()
