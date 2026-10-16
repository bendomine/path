class_name Player
extends RigidBody3D

signal player_position(pos: Vector3)

func _physics_process(_delta: float) -> void:
	player_position.emit(position)
