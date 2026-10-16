@tool
extends Node3D

@export var chunk_size: float = 20.0
@export var cell_size: float = 1.0
@export var player: Player

var chunk := Vector2i(1000, 1000)
var chunks: Array[Vector2i] = []

func height(p: Vector2) -> float:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	return noise.get_noise_2dv(p) * 20 - sqrt(p.x * p.x + p.y * p.y) / 10

@export var debug_chunk_id: Vector2i
@export_tool_button("Generate Chunk (Debug)")
var action: Callable = debug_generate_chunk
func debug_generate_chunk() -> void:
	add_child(generate_chunk(debug_chunk_id))

func generate_chunk(id: Vector2i) -> StaticBody3D:
	var ncells := chunk_size / cell_size
	assert(is_equal_approx(ncells, roundf(ncells)), "Chunk size must be a multiple of cell size.")
	assert(is_equal_approx(chunk_size, round(chunk_size)), "Chunk size must be a whole number.")
	var chunk := StaticBody3D.new()
	var shape := HeightMapShape3D.new()
	var cells: int = roundi(ncells)
	var center := (id as Vector2) * chunk_size
	var offset := center - Vector2(chunk_size / 2, chunk_size / 2)

	var collision_arrays := PackedFloat32Array()
	var verts := PackedVector3Array()
	collision_arrays.resize((roundi(chunk_size) + 1) ** 2)
	shape.map_width = roundi(chunk_size + 1)
	shape.map_depth = roundi(chunk_size + 1)

	# Mesh
	for x in range(cells + 1):
		for z in range(cells + 1):
			var pos := offset + Vector2(x, z) * cell_size
			var h := height(pos)
			verts.push_back(Vector3(pos.x - center.x, h, pos.y - center.y))

	# HeightMapShape3D
	for x in range(roundi(chunk_size) + 1):
		for z in range(roundi(chunk_size) + 1):
			var pos: Vector2i = (offset.floor() as Vector2i) + Vector2i(x, z)
			var h := height(pos)
			collision_arrays[z * (roundi(chunk_size) + 1) + x] = h

	shape.map_data = collision_arrays

	var indices := PackedInt32Array()
	for x in range(cells):
		for z in range(cells):
			var current := x * (cells + 1) + z
			var plusZ := current + cells + 1
			var plusX := current + 1
			var opposite := plusZ + 1

			indices.push_back(plusX)
			indices.push_back(current)
			indices.push_back(plusZ)

			indices.push_back(plusX)
			indices.push_back(plusZ)
			indices.push_back(opposite)

	var mesh_arrays := []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = verts
	mesh_arrays[Mesh.ARRAY_INDEX] = indices

	var st := SurfaceTool.new()
	st.create_from_arrays(mesh_arrays)
	st.generate_normals()
	mesh_arrays = st.commit_to_arrays()
	var mesh_new := ArrayMesh.new()
	mesh_new.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	var cs := CollisionShape3D.new()
	cs.shape = shape
	chunk.add_child(cs)

	var ms := MeshInstance3D.new()
	ms.mesh = mesh_new
	chunk.add_child(ms)

	chunk.position = Vector3(center.x, 0, center.y)

	return chunk


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(generate_chunk(Vector2i(0, 0)))
	player.player_position.connect(_on_player_moved)
	# for x in range(5):
	# 	for z in range(5):
	# 		add_child(generate_chunk(Vector2i(x - 2, z - 2)))

func _on_player_moved(pos: Vector3) -> void:
	var newChunk := ((Vector2(pos.x, pos.z) / chunk_size).round()) as Vector2i
	if chunk != newChunk:
		chunk = newChunk
		for x in range(3):
			for z in range(3):
				var new_chunk := chunk + Vector2i(x - 1, z - 1)
				if !chunks.has(new_chunk):
					add_child(generate_chunk(new_chunk))
					chunks.push_back(new_chunk)
