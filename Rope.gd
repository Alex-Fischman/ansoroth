extends Line2D

export var A: NodePath
export var B: NodePath
onready var a = get_node(A)
onready var b = get_node(B)
func _process(_delta):
	points[0] = a.global_position
	points[1] = b.global_position
