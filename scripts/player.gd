extends KinematicBody

export var gravity = -25
export var walk_speed = 14.0
export var run_speed = 20.0
export var jumprun_speed = 20.0
export var jump_speed = 10.0
export var mouse_sensitivity = 0.002
export var acceleration = 8
export var friction = 10
export var fall_limit = -1000.0

var pivot

var playable = true
var dir = Vector3.ZERO
var velocity = Vector3.ZERO
var canmove = true
var number
func _ready():
	pivot = $pivot
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _physics_process(delta):
	if is_on_floor() == false:
		friction = -0.35
	else: 
		friction = 10
	canmove = true
	dir = Vector3.ZERO
	var basis = global_transform.basis
	if Input.is_action_pressed("move_forward") and canmove == true:
		dir -= basis.z
		number = 2
		

	if Input.is_action_pressed("move_back") and canmove == true:
		dir += basis.z
	if Input.is_action_pressed("move_left") and canmove == true:
		dir -= basis.x
	if Input.is_action_pressed("move_right") and canmove == true:
		dir += basis.x
	dir = dir.normalized()
	var speed = walk_speed
	if is_on_floor() or is_on_wall():
		#this prevents you from sliding without messing up the is_on_ground() check
		velocity.y += gravity * delta / 100.0
		if Input.is_action_pressed("run"):
			speed = run_speed
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
			speed = jumprun_speed
	else:
		velocity.y += gravity * delta

	var hvel = velocity
	hvel.y = 0.0

	var target = dir * speed
	var accel
	if dir.dot(hvel) > 0.0:
		accel = acceleration
	else:
		accel = friction
	hvel = hvel.linear_interpolate(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	if playable:
		velocity = move_and_slide(velocity, Vector3.UP, true)

	#prevents infinite falling
	if translation.y < fall_limit and playable:
		playable = false
		fader._reload_scene()

func _unhandled_input(event):
	if event is InputEventMouseMotion and playable:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)
