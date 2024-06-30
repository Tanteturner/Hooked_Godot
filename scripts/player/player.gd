extends CharacterBody2D

const WALK_ACCELERATION = 1200.0
const WALK_DECCELERATION = 1200.0
const MAX_WALK_VELOCITY = 150.0
const AIR_ACCELERATION = 1000.0
const AIR_DECCELERATION = 700.0
const JUMP_VELOCITY = -200.0
const WALL_JUMP_VELOCITY = 200.0
const COYOTE_TIME = 0.1
const REMEMBER_INPUT_TIME = 0.1
const JUMP_GRAVITY = 0.6
const FALL_GRAVITY = 1
const WALL_GRAVITY = 1
const MAX_WALLSLIDE_VELOCITY = 20

@onready var animated_sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_gravity = gravity * JUMP_GRAVITY
var fall_gravity = gravity * FALL_GRAVITY
var wall_gravity = gravity * WALL_GRAVITY
var current_gravity = jump_gravity

var coyote_time = 0;
var remember_input_time = 0;

func _physics_process(delta):
	var direction = Input.get_axis("walk_left", "walk_right")
	
	apply_gravity(direction,delta)
	
	handle_jump(delta)
	handle_movement(direction,delta)
	
	handle_animation(direction)

	move_and_slide()

func apply_gravity(direction,delta):
	if velocity.y > 0 or not Input.is_action_pressed("jump"):
		current_gravity = fall_gravity
	
	if is_on_wall_only() and (direction > 0) != (get_wall_normal().x > 0):
		current_gravity = wall_gravity

	if not is_on_floor():
		velocity.y += current_gravity * delta
		
	if is_on_wall_only() and velocity.y > MAX_WALLSLIDE_VELOCITY and (direction > 0) != (get_wall_normal().x > 0):
		velocity.y = MAX_WALLSLIDE_VELOCITY;

func handle_animation(direction):
	if not is_on_wall_only():
		if(velocity.x != 0):
			animated_sprite.flip_h = velocity.x < 0
	else:
		animated_sprite.flip_h = get_wall_normal().x < 0
	
	if is_on_floor():
		if(velocity.x == 0):
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif is_on_wall_only() and (direction > 0) != (get_wall_normal().x > 0):
		animated_sprite.play("wallslide")
	else:
		animated_sprite.play("jump")

func handle_movement(direction,delta):
	var acceleration = WALK_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	var decceleration = WALK_DECCELERATION if is_on_floor() else AIR_DECCELERATION
	
	if direction:
		velocity.x += direction * acceleration * delta
	else:
		velocity.x = move_toward(velocity.x,0,decceleration * delta)
	
	velocity.x = clamp(velocity.x, -MAX_WALK_VELOCITY, MAX_WALK_VELOCITY)

#region Jump

func handle_jump_times(delta):
	remember_input_time -= delta
	coyote_time -= delta
	
	if(Input.is_action_just_pressed("jump")):
		remember_input_time = REMEMBER_INPUT_TIME
	
	if(is_on_floor() or is_on_wall_only()):
		coyote_time = COYOTE_TIME

func handle_jump(delta):
	handle_jump_times(delta)
	
	if remember_input_time > 0 and coyote_time > 0:
		jump()
		return

func jump():
	velocity.y = JUMP_VELOCITY
	
	if is_on_wall_only():
		velocity.x = WALL_JUMP_VELOCITY * get_wall_normal().x
	
	current_gravity = jump_gravity
	
	remember_input_time = 0
	coyote_time = 0

#endregion
