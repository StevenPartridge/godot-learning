class_name WallLand
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
	if manny.is_on_floor():
		return
	elif manny.is_on_wall():
		animator.play("WallLand")
		manny.velocity.x = 0

	manny.move_and_slide()
