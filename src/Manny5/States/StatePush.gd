class_name StatePush
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
	animator.play("InteractionPush")
	manny.velocity.x = manny.get_input_direction() * manny.SPEED_PUSH_PULL
	if manny.get_input_direction() > 0:
		animator.flip_h = false
	else:
		animator.flip_h = true
	manny.move_and_slide()
