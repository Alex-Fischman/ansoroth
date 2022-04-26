extends PathFollow2D

export var following: NodePath
onready var node = get_node(following)
export var speed_lerp: float

func _process(_delta):
	offset = lerp(offset, get_parent().curve.get_closest_offset(node.global_position), speed_lerp)
