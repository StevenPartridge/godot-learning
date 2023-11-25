class_name StateWallJump
extends State

@export var animator: AnimatedSprite2D
@export var manny: Manny

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	
func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta):
	if animator.animation != "SmallJump":
		animator.play("SmallJump")
	if manny.jump_state == manny.JumpState.JUMP:
		if animator.flip_h:
			manny.velocity.x = 1 * manny.SPEED
		else:
			manny.velocity.x = -1 * manny.SPEED
		animator.flip_h = !animator.flip_h
		apply_jump_force()
		manny.jump_state = manny.JumpState.DOUBLEJUMP
	else:
		manny.velocity.y += manny.GRAVITY * delta
	handle_horizontal_movement()
	manny.move_and_slide()


func apply_jump_force():
	manny.velocity.y = manny.JUMP_VELOCITY

func handle_horizontal_movement():
	manny.velocity.x = manny.velocity.x

