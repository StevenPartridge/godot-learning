class_name StateDoubleJump
extends State

@export var animator: AnimatedSprite2D
@export var manny: Manny



func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	if animator.animation != "SmallJump":
		animator.play("SmallJump")
	

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta):
	handle_horizontal_movement()
	if manny.is_on_floor():
		apply_jump_force()
	else:
		manny.velocity.y += manny.GRAVITY * delta
	manny.move_and_slide()


func apply_jump_force():
	manny.velocity.y = manny.JUMP_VELOCITY

func handle_horizontal_movement():
	var direction = manny.get_input_direction()
	manny.velocity.x = manny.velocity.x
	animator.flip_h = direction < 0

