extends CharacterBody2D

enum Direction { LEFT, RIGHT }
var current_direction = Direction.RIGHT

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const DECELERATION = 0.1
const MIN_SCALE = 1
const MAX_SCALE = 3
const GROUND_POUND_SPEED = 600.0
const BOUNCE_HEIGHT = 500.0
const ROTATION_MULTIPLIER = 1.5
const GROUND_POUND_COOLDOWN = 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var Manny = $AnimatedSprite2D

func _physics_process(delta):
	handle_inputs()
	update_velocity(delta)

	move_and_slide()

func update_velocity(delta):
	apply_gravity(delta)
	handle_horizontal_movement()
	
func handle_horizontal_movement():
	if !Input.is_action_just_pressed("Crouch"):
		var direction = get_input_direction()
		update_horizontal_velocity(direction)
		var new_animation = update_animation(direction)
		if new_animation:
			set_animation(new_animation)
		

func set_animation(anim: String):
	var current_animation = Manny.animation
	var let_finish = ["LandOnGround"]
	var should_finish = let_finish.any(func(string): return string == current_animation)
	print(should_finish, anim, let_finish)
	if should_finish and anim == current_animation:
		return
	if (Manny.animation != anim):
		Manny.play(anim)

func update_animation(direction: int):
	var current_animation = Manny.animation
	print(current_animation)
	if current_animation == "SmallJump" and is_idle():
		return "LandOnGround"
	elif is_idle():
		return "Idle"
	elif !is_on_floor():
		if Manny.animation != "SmallJump":
			return "SmallJump"
		else:
			return
	elif abs(velocity.x) >= 15:
		return "Walk"
	elif Input.is_action_just_pressed("Crouch"):
		print("Not happening")
		return "CrouchIdle"

func is_idle():
	var current_animation = Manny.animation
	return !Input.is_action_pressed("Crouch") and is_on_floor() and abs(velocity.x) < 15

func update_horizontal_velocity(direction: int):
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)

func get_input_direction() -> int:
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		current_direction = Direction.LEFT
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		current_direction = Direction.RIGHT
		direction += 1
	return direction
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_inputs():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("MoveLeft"):
		current_direction = Direction.LEFT
		Manny.flip_h = true
	if Input.is_action_just_pressed("MoveRight"):
		current_direction = Direction.RIGHT
		Manny.flip_h = false
