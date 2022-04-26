extends KinematicBody2D

export var GRAVITY: float
export var JUMP: float
export var GROUND_ACCEL: float
export var AIR_ACCEL: float
export var TOP_SPEED: float

export var THROW: float
export var PULL_SCALE: Vector2
export var PULL_CURVE: Curve
export var RETRIEVE: float
export var ANGLE_LERP: float
export var THRUST: Curve

export var max_shields: int
onready var shields = max_shields

export var SPEAR: NodePath
onready var spear = get_node(SPEAR)
func _ready(): spear.gravity = Vector2.DOWN * GRAVITY

export var CONNECTION: NodePath
onready var connection = get_node(CONNECTION)
onready var connection_width = connection.width

onready var total_thrust_time = THRUST.get_point_position(THRUST.get_point_count() - 1).x
onready var last_time = OS.get_ticks_msec()
func reset_timer(): last_time = OS.get_ticks_msec()
func get_elapsed(): return (float(OS.get_ticks_msec()) - last_time) / 1000

var velocity = Vector2.ZERO

func _process(delta):
	if shields < 0:
		get_tree().reload_current_scene() # TODO
	elif spear.held:
		var curr_dir = Vector2.RIGHT.rotated(spear.rotation)
		var move_dir = get_vector("move_right", "move_left", "move_down", "move_up")
		var spear_dir = get_vector("spear_right", "spear_left", "spear_down", "spear_up")
		var direction = spear_dir if spear_dir else move_dir if move_dir else curr_dir
		spear.rotation = lerp_angle(spear.rotation, direction.angle(), ANGLE_LERP)
		spear.position = position
		connection.width = 0
		if Input.is_action_pressed("throw"):
			spear.held = false
			spear.stuck = false
			spear.retrieving = false
			spear.velocity = direction * THROW + velocity
		elif get_elapsed() < total_thrust_time:
			spear.position += direction * THRUST.interpolate(get_elapsed())
		elif Input.is_action_pressed("thrust"): reset_timer()
	else:
		var relative = spear.position - position
		var pull_strength = PULL_CURVE.interpolate(relative.length() / PULL_SCALE.x)
		connection.width = pull_strength * connection_width
		if spear.retrieving and relative.length() < spear.LENGTH / 2: spear.held = true
		elif spear.retrieving:
			spear.rotation = lerp_angle(spear.rotation, relative.angle(), ANGLE_LERP)
			spear.velocity = spear.velocity.project(relative.normalized())
			spear.velocity -= RETRIEVE * relative.normalized()
			spear.position += spear.velocity * delta
			if spear.position.distance_to(position) > relative.length():
				spear.velocity = Vector2.ZERO
				spear.position = position + relative
		elif Input.is_action_pressed("thrust"): spear.retrieving = true
		elif spear.stuck and Input.is_action_pressed("throw"):
			velocity += relative.normalized() * pull_strength * PULL_SCALE.y

func _physics_process(_delta):
	var run = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var accel = GROUND_ACCEL if is_on_floor() else AIR_ACCEL
	velocity.x = velocity.x * (TOP_SPEED - accel) / TOP_SPEED + run * accel
	if Input.is_action_pressed("jump") and is_on_floor(): velocity.y -= JUMP
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)

func get_vector(right, left, down, up):
	return Vector2(
		Input.get_action_strength(right) - Input.get_action_strength(left),
		Input.get_action_strength(down)  - Input.get_action_strength(up)
	).clamped(1)
