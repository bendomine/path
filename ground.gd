@tool
extends MeshInstance3D

@export_tool_button("Generate Mesh!")
var action: Callable = generate_mesh

@export var source_mesh: PrimitiveMesh

# Called when the node enters the scene tree for the first time.
func generate_mesh() -> void:
	var amesh := ArrayMesh.new();
	
	var arrays: Array = source_mesh.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	
	for i in vertices.size():
		var v: Vector3 = vertices[i]
		#var length: float = (v * Vector3(1, 0, 1)).length() * 5
		v.y = sin(v.x) * sin(v.z)
		vertices[i] = v
	arrays[Mesh.ARRAY_VERTEX] = vertices
		
	amesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var collider: CollisionShape3D = $"../GroundCollider"
	var shape := amesh.create_trimesh_shape()
	collider.shape = shape
	
	var st := SurfaceTool.new()
	st.create_from(amesh, 0)
	st.generate_normals()
	mesh = st.commit()
