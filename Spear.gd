extends KinematicBody2D

export var LENGTH: float

var velocity = Vector2.ZERO
var gravity = Vector2.ZERO
var held = true
var stuck = false
var retrieving = false

func _physics_process(delta):
	if not held and not stuck and not retrieving:
		velocity += gravity
		if velocity: rotation = velocity.angle()
		if move_and_collide(velocity * delta):
			stuck = true
			retrieving = false
			velocity = Vector2.ZERO
