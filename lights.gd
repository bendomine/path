extends Node3D

@export var numLights := 50
@export var lightSpacing := 10
@export var lightNode: PackedScene

@onready var terrain: Terrain = $"../Terrain"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(numLights):
		var newLight: Node3D = lightNode.instantiate()
		var height := terrain.height(Vector2(lightSpacing * i, 0))
		newLight.position = Vector3(lightSpacing * i, height, 0)
		add_child(newLight)
