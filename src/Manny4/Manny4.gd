extends CharacterBody2D

enum States {
	IDLE,
	WALK,
	JUMP,
	JUMPROLL,
	LAND,
	WALLLAND,
	WALLSLIDE,
	CROUCH,
	RUN,
	PUNCHJAB,
	PUNCHHEAVY,
	PUNCHCROSS,
	PUSHPULLIDLE,
	PUSH,
	PULL,
	SWORDIDLE,
	SWORDRUN,
	SWORDSTAB
	# Add other states like ATTACK, CLIMB, etc.
}

enum Weapon {
	UNARMED,
	GUN,
	SWORD
}

enum JumpState {
	FLOOR,
	SINGLE,
	DOUBLE
}

var current_jump_state = JumpState.SINGLE
var current_equiped = Weapon.SWORD
var current_time = 0.0
var jump_time = current_time
var wall_jump_time = current_time

const WALL_JUMP_DELAY = 0.5
const DOUBLE_JUMP_DELAY = 0.2
const SPEED = 300.0
const SPEED_SPRINT = 500.0
const JUMP_VELOCITY = -500.0
const DECELERATION = 0.08

enum Direction { LEFT, RIGHT }

var current_state = States.JUMP
var previous_state = States.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var Manny = $AnimatedSprite2D

func _ready():
	Manny.play("SmallJump")

func _physics_process(delta):
	current_time += delta
	update_hitboxes()
	handle_input()
	play_animation_based_on_state()
	update_velocity(delta)
	move_and_slide()
	
func update_hitboxes():
	if Manny.flip_h:
		$RayCast2DRight.enabled = false
		$RayCast2DLeft.enabled = true
	else:
		$RayCast2DRight.enabled = true
		$RayCast2DLeft.enabled = false
	
func current_direction_locked():
	return Input.is_action_pressed("Interact") or Manny.animation == "WallSlide" or Manny.animation == "WallLand"
	
func update_velocity(delta):
	apply_gravity(delta)
	handle_horizontal_movement()

func is_frozen_horizontal():
	match current_state:
		States.SWORDSTAB:
			return true
		States.CROUCH:
			return true
	return false

func handle_horizontal_movement():
	if !Input.is_action_just_pressed("Crouch"):
		var direction = get_input_direction()
		update_horizontal_velocity(direction)
			
func update_horizontal_velocity(direction: int):
	if direction != 0 and !is_frozen_horizontal():
		if is_sprinting():
			velocity.x = direction * SPEED_SPRINT
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)
			
func apply_gravity(delta):
	if current_state == States.WALLLAND or current_state == States.WALLSLIDE:
		velocity.y += gravity * (delta * .6)
	elif not is_on_floor():
		velocity.y += gravity * delta
		
func get_input_direction() -> int:
	if current_time > 0 and current_time - wall_jump_time < WALL_JUMP_DELAY:
		if Manny.flip_h: return -1
		else: return 1
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		if !current_direction_locked():
			Manny.flip_h = true
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		if !current_direction_locked():
			Manny.flip_h = false
		direction += 1
	return direction
	

func is_crouching():
	return Input.is_action_pressed("Crouch") and is_on_floor() and get_input_direction() == 0

func is_press_left():
	return Input.is_action_just_pressed("MoveLeft") or Input.is_action_pressed("MoveLeft") and is_on_floor()
	
func is_press_right():
	return Input.is_action_just_pressed("MoveRight") or Input.is_action_pressed("MoveRight") and is_on_floor()
	
func is_land_on_wall():
	return (Input.is_action_pressed("MoveLeft") or Input.is_action_pressed("MoveRight")) and ($RayCast2DLeft.is_colliding() or $RayCast2DRight.is_colliding()) and !is_on_floor()

func is_sprinting():
	return Input.is_action_pressed("Sprint")
	
func is_current_state_locked():
	return (current_state == States.LAND and get_input_direction() == 0 and !is_crouching()) \
		or current_state == States.SWORDSTAB or \
		(current_state == States.WALLLAND and !is_on_floor())

func handle_input():
	if is_on_floor():
		current_jump_state = JumpState.FLOOR
	if current_state == States.WALLSLIDE and is_on_floor():
		update_state(States.IDLE)
	
	if Input.is_action_just_pressed("Jump") and current_jump_state == JumpState.FLOOR:
		jump_time = current_time
		current_jump_state = JumpState.SINGLE
		velocity.y = JUMP_VELOCITY
		update_state(States.JUMP)
		return
	elif Input.is_action_just_pressed("Jump") and (current_state == States.WALLLAND or current_state == States.WALLSLIDE):
		wall_jump_time = current_time
		current_jump_state = JumpState.DOUBLE
		velocity.y = JUMP_VELOCITY * .8
		if Manny.flip_h:
			velocity.x = SPEED * 1.5
		else:
			velocity.x = -1 * SPEED * 1.5
		Manny.flip_h = !Manny.flip_h
		previous_state = current_state
		current_state = States.JUMP
		return
	elif Input.is_action_just_pressed("Jump") and current_jump_state == JumpState.SINGLE and current_time - jump_time > DOUBLE_JUMP_DELAY:
		current_jump_state = JumpState.DOUBLE
		velocity.y = JUMP_VELOCITY * 0.8
		update_state(States.JUMPROLL)
		
	if is_current_state_locked(): return
	if is_press_left() and is_on_floor():
		if abs(velocity.x) == 0:
			update_state(States.PUSH)
		elif is_sprinting():
			update_state(States.RUN)
		else:
			update_state(States.WALK)
	if is_press_right() and is_on_floor():
		if abs(velocity.x) == 0:
			update_state(States.PUSH)
		elif is_sprinting():
			update_state(States.RUN)
		else:
			update_state(States.WALK)
	if is_land_on_wall():
		update_state(States.WALLLAND)
	if is_crouching():
		update_state(States.CROUCH)
	elif is_holding_push_pull():
		update_state(States.PUSHPULLIDLE)
		if is_press_left() or is_press_right():
			if (is_press_left() and Manny.flip_h) or (is_press_right() and !Manny.flip_h):
				update_state(States.PUSH)
			else:
				update_state(States.PULL)
	elif Input.is_action_just_pressed("MainAttack"):
		update_state(States.SWORDSTAB)
	elif is_on_floor() and get_input_direction() == 0 and !is_holding_push_pull():
		update_state(States.IDLE)

func is_holding_push_pull():
	return is_on_floor() and Input.is_action_pressed("Interact")

func update_state(state: States, force: bool = false):
	if !force and is_current_state_locked(): return
	# Update the state based on conditions, like landing
	if is_on_floor() and previous_state == States.JUMP:
		previous_state = current_state
		current_state = States.LAND
		return
		
	previous_state = current_state
	current_state = state

func play_animation_based_on_state():
	if current_state == States.LAND and Manny.animation == "LandOnGround" and get_input_direction() == 0:
		return
	elif current_state == States.SWORDSTAB and Manny.animation == "SwordStab":
		return

	match current_state:
		States.IDLE:
			if current_equiped == Weapon.UNARMED:
				play_animation("Idle")
			elif current_equiped == Weapon.SWORD:
				play_animation("SwordIdle")
		States.WALK:
			match current_equiped:
				Weapon.UNARMED:
					play_animation("Walk")
				Weapon.SWORD:
					play_animation("SwordRun")
		States.RUN:
			match current_equiped:
				Weapon.UNARMED:
					play_animation("Run")
				Weapon.SWORD:
					play_animation("SwordRun")
		States.JUMP:
			play_animation("SmallJump")
		States.JUMPROLL:
			play_animation("JumpRoll")
		States.LAND:
			play_animation("LandOnGround")
		States.WALLLAND:
			play_animation("WallLand")
		States.WALLSLIDE:
			play_animation("WallSlide")
		States.CROUCH:
			play_animation("CrouchIdle")
		States.PUSH:
			play_animation("InteractionPush")
		States.PULL:
			play_animation("InteractionPull")
		States.PUSHPULLIDLE:
			play_animation("InteractionPushPullIdle")
		States.SWORDSTAB:
			play_animation("SwordStab")
		States.PUNCHJAB:
			play_animation("PunchJab")
		States.PUNCHCROSS:
			play_animation("PunchCross")
		States.PUNCHHEAVY:
			play_animation("PunchHeavy")
		# Add cases for other states

func play_animation(anim_name):
	if Manny.animation != anim_name:
		Manny.play(anim_name)

func _set_state_idle():
	if is_on_floor() and current_state == States.LAND:
		current_state = States.IDLE
	if current_state == States.SWORDSTAB:
		current_state = States.IDLE
	if current_state == States.WALLLAND:
		current_state = States.WALLSLIDE
	if current_state == States.WALLSLIDE and is_on_floor():
		current_state = States.IDLE

