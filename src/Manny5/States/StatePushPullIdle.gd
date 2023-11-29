class_name StatePushPullIdle
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

	var move_x = 0
	if manny.is_on_floor():
		if manny.get_input_direction() > 0 and animator.flip_h:
			move_x = manny.SPEED
			animator.play("InteractionPull")
		elif manny.get_input_direction() > 0 and !animator.flip_h:
			move_x = manny.SPEED
			animator.play("InteractionPush")
		elif manny.get_input_direction() < 0 and animator.flip_h:
			move_x = -manny.SPEED
			animator.play("InteractionPush")
		elif manny.get_input_direction() < 0 and !animator.flip_h:
			move_x = -manny.SPEED
			animator.play("InteractionPull")
		else:
			animator.play("InteractionPushPullIdle")
#	var collider = manny.get_collider()
#	if collider is Node:
#		pass
			
	manny.velocity.x = move_x
	manny.move_and_slide()
