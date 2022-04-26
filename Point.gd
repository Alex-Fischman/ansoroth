extends Area2D

export var PLAYER: NodePath
onready var player = get_node(PLAYER)
onready var spear = player.spear
onready var thrust_damage_time = player.THRUST.get_point_position(1).x

func _process(_delta):
	monitoring = player.get_elapsed() < thrust_damage_time or (not spear.held and not (spear.stuck or spear.retrieving))
	monitorable = monitoring

func _on_area_entered(area):
	area.get_child(1).texture.gradient.colors[0] = Color.pink
	yield(get_tree().create_timer(thrust_damage_time), "timeout")
	area.get_child(1).texture.gradient.colors[0] = Color.red
