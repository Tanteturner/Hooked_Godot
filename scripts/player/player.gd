extends CharacterBody2D

enum JumpFrom{}

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.1
const REMEMBER_INPUT_TIME = 0.1
const JUMP_GRAVITY = 1
const FALL_GRAVITY = 1.5

@onready var animated_sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_gravity = gravity * JUMP_GRAVITY
var fall_gravity = gravity * FALL_GRAVITY
var current_gravity = jump_gravity

var coyote_time = 0;
var remember_input_time = 0;

func _physics_process(delta):
	apply_gravity(delta)
	
	var direction = Input.get_axis("walk_left", "walk_right")
	handle_jump(delta)
	handle_movement(direction)
	
	handle_animation(direction)

	move_and_slide()

func apply_gravity(delta):
	if velocity.y > 0 or not Input.is_action_pressed("jump"):
		current_gravity = fall_gravity

	if not is_on_floor():
		velocity.y += current_gravity * delta

func handle_animation(direction):
	if(direction != 0):
		animated_sprite.flip_h = direction < 0
	
	if is_on_floor():
		if(velocity.x == 0):
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("Jump")

func handle_movement(direction):
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	


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
	current_gravity = jump_gravity
	remember_input_time = 0
	coyote_time = 0

#endregion
