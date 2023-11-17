extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	JUMP,
	LAND,
	CROUCH
	# Add other states like ATTACK, CLIMB, etc.
}

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const DECELERATION = 0.1

enum Direction { LEFT, RIGHT }
var current_direction = Direction.RIGHT

var current_state = State.JUMP
var previous_state = State.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var Manny = $AnimatedSprite2D

func _ready():
	Manny.play("SmallJump")

func _physics_process(delta):
	play_animation_based_on_state()
	handle_input()
	update_velocity(delta)
	move_and_slide()
	
func update_velocity(delta):
	apply_gravity(delta)
	handle_horizontal_movement()
	
func handle_horizontal_movement():
	if !Input.is_action_just_pressed("Crouch"):
		var direction = get_input_direction()
		update_horizontal_velocity(direction)
			
func update_horizontal_velocity(direction: int):
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)
			
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func get_input_direction() -> int:
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		current_direction = Direction.LEFT
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		current_direction = Direction.RIGHT
		direction += 1
	return direction
	

func is_crouching():
	return Input.is_action_pressed("Crouch") and is_on_floor() and get_input_direction() == 0

func is_press_left():
	return Input.is_action_just_pressed("MoveLeft") or Input.is_action_pressed("MoveLeft") and is_on_floor()
	
func is_press_right():
	return Input.is_action_just_pressed("MoveRight") or Input.is_action_pressed("MoveRight") and is_on_floor()

func handle_input():
	if current_state == State.LAND and get_input_direction() == 0: return
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if !is_on_floor():
		update_state(State.JUMP)
	if is_press_left() and is_on_floor():
		current_direction = Direction.LEFT
		update_state(State.WALK)
		Manny.flip_h = true
	if is_press_right() and is_on_floor():
		current_direction = Direction.RIGHT
		update_state(State.WALK)
		Manny.flip_h = false
	if is_crouching():
		update_state(State.CROUCH)
	elif is_on_floor() and get_input_direction() == 0:
		update_state(State.IDLE)

func update_state(state: State):
	# Update the state based on conditions, like landing
	if is_on_floor() and previous_state == State.JUMP:
		previous_state = current_state
		current_state = State.LAND
		return
		
	previous_state = current_state
	current_state = state

func play_animation_based_on_state():
	if current_state == State.LAND and Manny.animation == "LandOnGround" and get_input_direction() == 0:
		return

	match current_state:
		State.IDLE:
			play_animation("Idle")
		State.WALK:
			play_animation("Walk")
		State.JUMP:
			play_animation("SmallJump")
		State.LAND:
			play_animation("LandOnGround")
			# Set a deferred call to switch to idle after the landing animation
			call_deferred("_set_state_idle")
		State.CROUCH:
			play_animation("CrouchIdle")
		# Add cases for other states

func play_animation(anim_name):
	if anim_name == "LandOnGround":
		Manny.play(anim_name)
	if Manny.animation != anim_name:
		Manny.play(anim_name)

func _set_state_idle():
	if is_on_floor():
		update_state(State.IDLE)

