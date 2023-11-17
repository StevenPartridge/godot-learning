extends Node

func _on_home_button_pressed():
	SceneManager.SwitchScene("Home")


func _on_reset_button_pressed():
	SceneManager.RestartScene()


func _on_quit_button_pressed():
	SceneManager.QuitGame()
