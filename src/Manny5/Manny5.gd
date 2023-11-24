class_name Manny
extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var ray_cast_2d_right = $RayCast2DRight
@onready var fsm = $FiniteStateMachine
@onready var state_idle = $FiniteStateMachine/StateIdle
@onready var state_walk = $FiniteStateMachine/StateWalk

@export var WALL_JUMP_DELAY = 0.5
@export var DOUBLE_JUMP_DELAY = 0.2
@export var SPEED = 200.0
@export var SPEED_SPRINT = 500.0
@export var JUMP_VELOCITY = -500.0
@export var DECELERATION = 0.08
@export var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity") as float

func _ready():
	fsm.change_state(state_idle)

func _physics_process(delta):
	handle_input()

func get_input_direction() -> int:
	var direction = 0
	if Input.is_action_pressed("MoveLeft"):
		direction -= 1
	if Input.is_action_pressed("MoveRight"):
		direction += 1
	return direction
	
func handle_input():
	if Input.is_action_pressed("MoveLeft") or Input.is_action_pressed("MoveRight"):
		fsm.change_state(state_walk)
	else: fsm.change_state(state_idle)
