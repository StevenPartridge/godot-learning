extends StaticBody2D
@onready var sprite_2d = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	set_random_color()

func set_random_color():
	var random_color = Color(randf(), randf(), randf(), randf_range(.5, 1))  # Random RGB color
	sprite_2d.modulate = random_color
