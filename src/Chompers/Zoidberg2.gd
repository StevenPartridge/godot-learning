extends CharacterBody2D

# Constants
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const DECELERATION = 0.1
const MIN_SCALE = 1
const MAX_SCALE = 3
const GROUND_POUND_SPEED = 600.0
const BOUNCE_HEIGHT = 500.0
const ROTATION_MULTIPLIER = 1.5
const GROUND_POUND_COOLDOWN = 1.0

# Enums
enum State { NORMAL, GROUND_POUND, BOUNCE }
enum Direction { LEFT, RIGHT }

# Variables
var state = State.NORMAL
var is_rotating = false
var rotation_speed = 360 * ROTATION_MULTIPLIER
var total_rotation = 0
var last_used_ground_pound = -GROUND_POUND_COOLDOWN
var current_direction = Direction.LEFT
var gravity = get_default_gravity()

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("still")

func _physics_process(delta):
	handle_inputs()
	update_velocity(delta)
	update_animation_fps()
	move_and_slide()

func handle_inputs():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		start_jump()
	if Input.is_action_just_pressed("GroundPound"):
		try_start_ground_pound()

func update_velocity(delta):
	apply_gravity(delta)
	handle_horizontal_movement()
	handle_state_specific_behaviors(delta)
	
func update_animation_fps():
	var current_speed = abs(velocity.x)
	var max_speed = SPEED
	var fps = lerp(MIN_SCALE, MAX_SCALE, current_speed / max_speed)
	animated_sprite.speed_scale = fps

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func start_jump():
	velocity.y = JUMP_VELOCITY

func try_start_ground_pound():
	if state == State.NORMAL and not is_on_floor() and can_use_ground_pound():
		start_ground_pound()

func handle_horizontal_movement():
	if state != State.GROUND_POUND:
		var direction = get_input_direction()
		update_horizontal_velocity(direction)
		
func can_use_ground_pound() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0 # Get current time in seconds
	return current_time - last_used_ground_pound >= GROUND_POUND_COOLDOWN

func get_input_direction() -> int:
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		current_direction = Direction.LEFT
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		current_direction = Direction.RIGHT
		direction += 1
	return direction

func update_horizontal_velocity(direction: int):
	if direction != 0:
		if !is_rotating:
			animated_sprite.play("walking")
			velocity.x = direction * SPEED
	elif state != State.BOUNCE:
		animated_sprite.play("still")
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)
		
func start_ground_pound():
	last_used_ground_pound = Time.get_ticks_msec() / 1000.0
	state = State.GROUND_POUND
	animated_sprite.play("ground_pound")

func handle_state_specific_behaviors(delta):
	if is_rotating:
		perform_rotation(delta)
	if is_on_floor():
		on_ground_pound_collision()

func perform_rotation(delta):
	var rotation_step = rotation_speed * delta
	if abs(total_rotation) > 0:
		if total_rotation > 0:
			animated_sprite.rotation_degrees += rotation_step
			total_rotation -= rotation_step
			if animated_sprite.rotation_degrees > 180:
				animated_sprite.rotation_degrees = 180
		else:
			animated_sprite.rotation_degrees -= rotation_step
			total_rotation += rotation_step
			if animated_sprite.rotation_degrees < -180:
				animated_sprite.rotation_degrees = -180
	else:
		finish_bounce()
		
func finish_bounce():
	# Reset rotation to initial value if needed after the rotation is complete
	is_rotating = false
	state = State.NORMAL
	animated_sprite.play("still")
	animated_sprite.rotation_degrees = 0 # Reset rotation if needed
		
func on_ground_pound_collision():
	animated_sprite.rotation_degrees = 0
	if state == State.GROUND_POUND:
	# Stop downward momentum and start bounce
		velocity.y = 0
		state = State.BOUNCE
		velocity.y = -BOUNCE_HEIGHT
		# Start rotation
		is_rotating = true
		if current_direction == Direction.RIGHT:
			total_rotation = 180
		else:
			total_rotation = -180

func get_default_gravity() -> float:
	var default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	if typeof(default_gravity) != TYPE_FLOAT:
		push_error("Invalid gravity value in project settings")
		return 9.8 # Default value if error occurs
	return default_gravity
