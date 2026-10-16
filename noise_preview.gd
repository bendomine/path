@tool
extends Sprite2D

@export_tool_button("Generate image")
var action: Callable = makeNoise

func makeNoise() -> void:
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	var i := n.get_image(500, 500)
	var t := ImageTexture.create_from_image(i)
	texture = t
