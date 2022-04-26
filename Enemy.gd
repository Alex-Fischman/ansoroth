extends Area2D

export var CONTACT_DAMAGE: float

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if "shields" in body:
			body.shields -= CONTACT_DAMAGE * delta
