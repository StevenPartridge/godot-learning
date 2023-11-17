extends CharacterBody2D

@onready var crawler = $AnimatedSprite2D
var speed = 300 # Adjust speed as needed
var direction = -1 # -1 for left, 1 for right

var moving_time = 0.2 # Time in seconds the enemy moves before pausing
var pause_time = 0.8 # Time in seconds the enemy pauses before moving again

var current_time = 0.0 # Time tracker
var is_moving = true # State tracker

# Called when the node enters the scene tree for the first time.
func _ready():
	crawler.play("walk_left")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):


	# Move and slide
	move_crawler(delta)
	
	if is_colliding():
		direction *= -1 # Change direction
		update_flip()
		update_animation()

func move_crawler(delta):
	current_time += delta

	if is_moving:
		crawl_forward()
		if current_time >= moving_time:
			current_time = 0
			is_moving = false
	else:
		if current_time >= pause_time:
			current_time = 0
			is_moving = true
				
func crawl_forward():
	velocity.x = direction * speed # Set horizontal velocity
	move_and_slide()

func update_flip():
	# Flip the sprite based on the direction
	crawler.flip_h = (direction == 1)
	reset_vars()

func reset_vars():
	current_time = 0.0
	crawler.play("walk_left")
	
func is_colliding():
	# Check for collision
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var colliderName = collision.get_collider().get_name()
			if colliderName.find("WallSection") != -1: # Check if the collision is with a StaticBody2D (like your walls)
				return true
	return false

func update_animation():
	if direction == 1:
		crawler.play("walk_right")
	else:
		crawler.play("walk_left")
