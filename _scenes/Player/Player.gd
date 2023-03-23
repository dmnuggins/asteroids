extends CharacterBody2D

@export var rotation_speed: int = 5
@export var speed = 1000
@export var decel := 1.0
@export var accel := 1.0

@onready var screen_size = get_viewport_rect().size

var rotation_direction = 0
var warped = false

signal player_hit
signal player_shoot
signal player_destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var rotate = Input.get_axis("left","right") * rotation_speed
	rotate(rotate * delta)
	
	if warped:
		velocity = Vector2.ZERO
	
	if Input.is_action_pressed("thrust"):
		velocity = lerp(velocity, transform.y * -speed, accel * delta)
		$AnimatedSprite2D.show()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.hide()
		$AnimatedSprite2D.stop()
	
	move_and_slide()
	velocity = lerp(velocity, Vector2.ZERO, decel * delta)
	
	if Input.is_action_just_pressed("shoot"):
		# shoots bullets
		print("player_shot")
		get_node("Shoot").play()
		emit_signal("player_shoot")
	
	if Input.is_action_just_pressed("hyperspace"):
		teleport()
	screen_wrap()

# warp player
func teleport() -> void:
	randomize()
	# get random position vector
	var new_location = Vector2(randf_range(50,974) , randf_range(50,718))
	# animate at new location
	hide()
	warped = true
	global_position = new_location
	$WarpTimer.start()

# called in Asteroid
func destroy_player() -> void:
	# yeeted the player out of screen to avoid multiple collisions
	# funny, so not optimal
	global_position = Vector2(-100, -100)
	$CollisionShape2D.queue_free()
	emit_signal("player_hit")
	get_node("Explosion").play()
	get_node("DespawnTimer").start()
	hide()
	

# gets position of gun
func get_gun_position() -> Vector2:
	return $Gun.global_position

func get_center_screen() -> Vector2:
	return get_viewport_rect().size / 2

func screen_wrap() -> void:
	position = position.posmodv(screen_size)

func _on_warp_timer_timeout():
	show()
	warped = false
	pass # Replace with function body.


func _on_despawn_timer_timeout():
	emit_signal("player_destroyed")
	queue_free()
	pass # Replace with function body.
