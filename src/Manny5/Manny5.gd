class_name Manny
extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var ray_cast_2d_right = $RayCast2DRight

@onready var fsm = $FiniteStateMachine
@onready var state_idle = $FiniteStateMachine/StateIdle
@onready var state_walk = $FiniteStateMachine/StateWalk
@onready var state_jump = $FiniteStateMachine/StateJump

@export var WALL_JUMP_DELAY = 0.5
@export var DOUBLE_JUMP_DELAY = 0.2
@export var SPEED = 200.0
@export var SPEED_SPRINT = 500.0
@export var JUMP_VELOCITY = -500.0
@export var DECELERATION = 0.08
@export var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity") as float

var current_time = 0.0
var input_delay_until = 0.0

const DELAY_JUMP = 0.5

var can_double_jump = true

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
	
func handle_input():
	if input_delay_until > current_time:
		return
	var direction = get_input_direction()
	var is_moving = direction != 0
	var is_jumping = Input.is_action_just_pressed("Jump") and is_on_floor()
	var current_state = fsm.getState()
	# Jump Logic
	if is_jumping:
		input_delay_until = current_time + DELAY_JUMP
		fsm.change_state(state_jump)
	elif is_on_floor():
		reset_jump_states()
		if is_moving:
			fsm.change_state(state_walk)
		else:
			fsm.change_state(state_idle)

func reset_jump_states():
	can_double_jump = true  # Reset double jump when on the floor
