extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DECELERATION = 0.1 # Deceleration factor for smooth stopping

const MIN_SCALE = 1
const MAX_SCALE = 3

@onready var animation = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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

	# Handle Horizontal Movement
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		direction += 1

	if direction != 0:
		animation.play("walking")
		velocity.x = direction * SPEED
	else:
		animation.play("still")
		# Smooth deceleration when no input is provided
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)

func update_animation_fps():
	var current_speed = abs(velocity.x)
	var max_speed = SPEED
	var fps = lerp(MIN_SCALE, MAX_SCALE, current_speed / max_speed)
	animation.speed_scale = fps
