extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const DECELERATION = 0.1 # Deceleration factor for smooth stopping

const MIN_SCALE = 1
const MAX_SCALE = 3

enum State { NORMAL, GROUND_POUND, BOUNCE }
var state = State.NORMAL
const GROUND_POUND_SPEED = 600.0 # Adjust as needed
const BOUNCE_HEIGHT = 500.0 # Adjust as needed

var is_rotating = false
const ROTATION_MULTIPLIER = 1.5
const rotation_speed = 360 * ROTATION_MULTIPLIER # degrees per second
var total_rotation = 0 # total rotation needed

const GROUND_POUND_COOLDOWN = 1
var last_used_ground_pound = -GROUND_POUND_COOLDOWN

enum Direction { LEFT, RIGHT }
var current_direction = Direction.LEFT

@onready var animated_sprite = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	animated_sprite.play("still")

func _physics_process(delta):
	update_velocity(delta)
	update_animation_fps()
	move_and_slide()

func update_velocity(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Ground Pound Input
	if Input.is_action_just_pressed("GroundPound") and state == State.NORMAL and not is_on_floor():
		if can_use_ground_pound():
			start_ground_pound()
		
	# Handle Ground Pound Logic
	if state == State.GROUND_POUND and can_use_ground_pound():
		# Halt forward momentum after a short delay (if needed)
		if current_direction == Direction.RIGHT:
			velocity.x = 100
		else:
			velocity.x = -100
		velocity.y = GROUND_POUND_SPEED
		
	if is_rotating:
		perform_rotation(delta)

	# Handle Horizontal Movement
	if state != State.GROUND_POUND:
		var direction = 0
		if Input.is_action_pressed("MoveLeft"):
			current_direction = Direction.LEFT
			direction -= 1
		if Input.is_action_pressed("MoveRight"):
			current_direction = Direction.RIGHT
			direction += 1

		if direction != 0:
			if !is_rotating:
				animated_sprite.play("walking")
			velocity.x = direction * SPEED
		elif state != State.BOUNCE:
			animated_sprite.play("still")
			# Smooth deceleration when no input is provided
			velocity.x = lerp(velocity.x, 0.0, DECELERATION)
			
	if is_on_floor():
		on_ground_pound_collision()

func update_animation_fps():
	var current_speed = abs(velocity.x)
	var max_speed = SPEED
	var fps = lerp(MIN_SCALE, MAX_SCALE, current_speed / max_speed)
	animated_sprite.speed_scale = fps
	
func start_ground_pound():
	last_used_ground_pound = Time.get_ticks_msec() / 1000.0
	state = State.GROUND_POUND
	animated_sprite.play("ground_pound")
	# Set initial downward velocity if needed

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

func can_use_ground_pound() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0 # Get current time in seconds
	return current_time - last_used_ground_pound >= GROUND_POUND_COOLDOWN
