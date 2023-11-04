extends RigidBody2D


var repel_force = 35000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_position = get_global_mouse_position()
	var difference = mouse_position - global_position

	# Check if the distance between the node and the mouse is less than 30 pixels
	if difference.length() < 1000:
		# Normalize the difference to get a direction
		var repel_direction = difference.normalized()

		# Repel away by applying the opposite force
		apply_central_impulse(-repel_direction * repel_force * delta)

func _input(event):
	if event is InputEventMouseMotion:
		_process(0)  # Call _process to check distance and apply impulse if needed.
