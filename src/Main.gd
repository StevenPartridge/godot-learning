extends Node

@export var Ball: PackedScene

#func _input(event):
#	if event.is_action_pressed("click"):
#		var new_ball = Ball.instantiate()
#		new_ball.position = get_viewport().get_mouse_position()
#		add_child(new_ball)

func _on_go_to_scene_1_pressed():
	SceneManager.SwitchScene("HelloWorld")
	
func _on_go_to_scene_2_pressed():
	SceneManager.SwitchScene("Chompers")



func _on_go_to_manys_world_pressed():
	SceneManager.SwitchScene("MannysWorld")


func _on_go_to_manny_2_pressed():
	SceneManager.SwitchScene("Manny2")


func _on_go_to_manny_3_pressed():
	SceneManager.SwitchScene("Manny3")


func _on_go_to_manny_4_pressed():
	SceneManager.SwitchScene("Manny4")


func _on_go_to_manny_5_pressed():
	SceneManager.SwitchScene("Manny5")
