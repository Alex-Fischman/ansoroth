extends TextureProgress

export var node_path: NodePath
onready var node = get_node(node_path)

func _process(_delta):
	max_value = node.max_shields
	value = node.shields
