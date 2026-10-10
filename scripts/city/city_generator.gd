class_name CityGenerator
extends Node3D
## Spawns a grid of box buildings at runtime.
## Every building is a StaticBody3D in the "webbable" group, so the web raycast can attach to it.

const WEBBABLE_GROUP: StringName = &"webbable"
const PALETTE_SIZE: int = 6

@export var grid_size: int = 12
@export var block_spacing: float = 30.0
@export var footprint: float = 16.0
@export var min_height: float = 10.0
@export var max_height: float = 70.0
## 0 gives a new layout every run. Any other value gives the same city every run.
@export var layout_seed: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _palette: Array[StandardMaterial3D] = []


func _ready() -> void:
	_rng.seed = layout_seed if layout_seed != 0 else randi()
	_build_palette()
	_build_city()
	print("Webbable buildings: ", get_tree().get_nodes_in_group(WEBBABLE_GROUP).size())


func _build_palette() -> void:
	for _i in PALETTE_SIZE:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(_rng.randf(), _rng.randf_range(0.15, 0.45), _rng.randf_range(0.55, 0.9))
		mat.roughness = 1.0
		_palette.append(mat)


func _build_city() -> void:
	var half_extent: float = (grid_size - 1) * block_spacing * 0.5
	for gx in grid_size:
		for gz in grid_size:
			var ground_pos := Vector3(gx * block_spacing - half_extent, 0.0, gz * block_spacing - half_extent)
			_spawn_building(ground_pos)


func _spawn_building(ground_pos: Vector3) -> void:
	var height: float = _rng.randf_range(min_height, max_height)
	var dims := Vector3(footprint, height, footprint)

	var body := StaticBody3D.new()
	body.name = "Building"
	body.position = ground_pos + Vector3(0.0, height * 0.5, 0.0)
	body.add_to_group(WEBBABLE_GROUP)
	add_child(body)

	var box_mesh := BoxMesh.new()
	box_mesh.size = dims
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = _palette[_rng.randi_range(0, PALETTE_SIZE - 1)]
	body.add_child(mesh_instance)

	var box_shape := BoxShape3D.new()
	box_shape.size = dims
	var collision := CollisionShape3D.new()
	collision.shape = box_shape
	body.add_child(collision)
