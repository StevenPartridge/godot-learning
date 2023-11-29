class_name Manny
extends CharacterBody2D

enum JumpState {
	FLOOR,
	JUMP,
	DOUBLEJUMP
}

@onready var anim = $AnimatedSprite2D
@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_2_left = $RayCast2D2Left
@onready var pin_joint_2d = $PinJoint2D

@onready var fsm = $FiniteStateMachine
@onready var state_idle = $FiniteStateMachine/StateIdle
@onready var state_walk = $FiniteStateMachine/StateWalk
@onready var state_jump = $FiniteStateMachine/StateJump
@onready var state_double_jump = $FiniteStateMachine/StateDoubleJump
@onready var wall_land = $FiniteStateMachine/WallLand
@onready var state_wall_jump = $FiniteStateMachine/StateWallJump
@onready var state_land = $FiniteStateMachine/StateLand
@onready var state_crouch = $FiniteStateMachine/StateCrouch
@onready var state_push_pull_idle = $FiniteStateMachine/StatePushPullIdle

@export var SPEED = 200.0
@export var SPEED_SPRINT = 500.0
@export var SPEED_PUSH_PULL = 100.0
@export var JUMP_VELOCITY = -600.0
@export var DECELERATION = 0.12
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

func get_collider():
	var right = ray_cast_2d_right.get_collider()
	var left = ray_cast_2d_2_left.get_collider()
	if right:
		return right
	if left:
		return left
	

func get_is_grab_allowed():	
	var collider = get_collider()
	if collider is Node:
		if collider.is_in_group("can_push_pull"):
			return true
	return false

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
	var is_crouching = Input.is_action_pressed("Crouch") and is_on_floor()
	var is_interacting = Input.is_action_pressed("Interact")
	
	if !is_interacting:
		$PinJoint2D.node_b = $PinJoint2D.node_a

	# print('flip_h: ', anim.flip_h, ', Is_jumping: ', is_jumping, ', jump_state == JumpState.JUMP: ', jump_state == JumpState.JUMP, ', is_on_wall: ', is_on_wall(), ', is_on_floor: ', is_on_floor())

	# Jump Logic
	if is_crouching:
		fsm.change_state(state_crouch)	
	elif is_jumping:
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
		elif is_moving and !is_interacting:
			fsm.change_state(state_walk)
		elif is_interacting and get_is_grab_allowed():
			$PinJoint2D.node_b = get_collider().get_path()
			fsm.change_state(state_push_pull_idle)
		else:
			fsm.change_state(state_idle)

func reset_jump_states():
	jump_state = JumpState.FLOOR  # Reset double jump when on the floor
