class_name Manny
extends CharacterBody2D

enum JumpState {
	FLOOR,
	JUMP,
	DOUBLEJUMP
}

@onready var anim = $AnimatedSprite2D

@onready var fsm = $FiniteStateMachine
@onready var state_idle = $FiniteStateMachine/StateIdle
@onready var state_walk = $FiniteStateMachine/StateWalk
@onready var state_jump = $FiniteStateMachine/StateJump
@onready var state_double_jump = $FiniteStateMachine/StateDoubleJump
@onready var wall_land = $FiniteStateMachine/WallLand
@onready var state_wall_jump = $FiniteStateMachine/StateWallJump
@onready var state_land = $FiniteStateMachine/StateLand

@export var SPEED = 200.0
@export var SPEED_SPRINT = 500.0
@export var JUMP_VELOCITY = -600.0
@export var DECELERATION = 0.08
@export var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity") as float
@export var jump_state = JumpState.JUMP
var current_time = 0.0
var input_delay_until = 0.0



@export var can_double_jump = true

func _ready():
	fsm.change_state(state_idle)

func _physics_process(delta):
	current_time += delta
	velocity.y += GRAVITY * delta
	handle_input()

func get_input_direction() -> int:
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		direction += 1
	return direction

const WALL_JUMP_DELAY = 0.5
const DOUBLE_JUMP_DELAY = 0.2
const JUMP_DELAY = 0.1
const LAND_DELAY = 0.4
func handle_input():
	if is_on_floor():
		jump_state = JumpState.FLOOR
	if input_delay_until > current_time:
		return
	var direction = get_input_direction()
	var is_moving = direction != 0
	var is_jumping = Input.is_action_just_pressed("Jump") and jump_state == JumpState.FLOOR
	var is_double_jumping = Input.is_action_just_pressed("Jump") and jump_state == JumpState.JUMP and !is_on_floor()

	# print('flip_h: ', anim.flip_h, ', Is_jumping: ', is_jumping, ', jump_state == JumpState.JUMP: ', jump_state == JumpState.JUMP, ', is_on_wall: ', is_on_wall(), ', is_on_floor: ', is_on_floor())

	# Jump Logic
	if is_jumping:
		input_delay_until = current_time + JUMP_DELAY
		fsm.change_state(state_jump)
	elif !is_on_wall() and is_double_jumping:
		input_delay_until = current_time + DOUBLE_JUMP_DELAY
		fsm.change_state(state_double_jump)
	elif is_double_jumping and is_on_wall() and !is_on_floor():
		input_delay_until = current_time + WALL_JUMP_DELAY
		fsm.change_state(state_wall_jump)
	elif !is_on_floor() and is_on_wall():
		fsm.change_state(wall_land)
	elif is_on_floor():
		if (fsm.state == state_jump or fsm.state == state_double_jump or fsm.state == state_wall_jump):
			input_delay_until = current_time + LAND_DELAY
			fsm.change_state(state_land)
		elif is_moving:
			fsm.change_state(state_walk)
		else:
			fsm.change_state(state_idle)

func reset_jump_states():
	jump_state = JumpState.FLOOR  # Reset double jump when on the floor
