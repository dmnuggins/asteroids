extends CharacterBody2D

@export var rotation_speed: int = 5
@export var speed = 1000
@export var decel := 1.0
@export var accel := 1.0

@onready var screen_size = get_viewport_rect().size

var rotation_direction = 0
signal player_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rotation = Input.get_axis("left","right") * rotation_speed
	rotate(rotation * delta)
	
	if Input.is_action_pressed("thrust"):
		velocity = lerp(velocity, transform.y * -speed, accel * delta)
	
	move_and_slide()
	velocity = lerp(velocity, Vector2.ZERO, decel * delta)
	
	if Input.is_action_just_pressed("hyperspace"):
		pass
	screen_wrap()

# called in Asteroid
func destroy_player() -> void:
	emit_signal("player_hit")
	queue_free()

# gets position of gun
func get_gun_position() -> Vector2:
	return $Gun.global_position

func get_center_screen() -> Vector2:
	return get_viewport_rect().size / 2

func screen_wrap() -> void:
	position = position.posmodv(screen_size)
