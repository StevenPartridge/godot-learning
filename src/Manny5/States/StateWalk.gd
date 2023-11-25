class_name StateWalk
extends State

@export var animator: AnimatedSprite2D
@export var manny: Manny



func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(_delta):
	if Input.is_action_pressed("Sprint"):
		animator.play("Run")
		manny.velocity.x = manny.get_input_direction() * manny.SPEED_SPRINT
	else:
		animator.play("Walk")
		manny.velocity.x = manny.get_input_direction() * manny.SPEED
	if manny.get_input_direction() > 0:
		animator.flip_h = false
	else:
		animator.flip_h = true
	manny.move_and_slide()
