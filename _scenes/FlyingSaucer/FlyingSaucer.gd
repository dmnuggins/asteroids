extends Area2D

@export var speed := 500.0
@export var value: int = 300

@onready var screen_size = get_viewport_rect().size

var velocity := Vector2.ZERO
var eol := false
var x_y := true

signal saucer_hit
signal saucer_shoot
signal saucer_warp
signal saucer_timeout

# Called when the node enters the scene tree for the first time.
func _ready():
	init_velocity()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	screen_wrap()

func init_velocity():
	randomize()
	var x = randf_range(-50,50)
	var y = randf_range(-50,50)
	
	if x > 0:
		x += 100
	elif x < 0:
		x -= 100
	if y > 0:
		y += 100
	else:
		y -= 100

	velocity = Vector2(x,y)

func change_dir():
	if randf() < 0.5:
		velocity.x = -velocity.x
	else:
		velocity.y = -velocity.y

func screen_wrap() -> void:
	position = position.posmodv(screen_size)

func destroy_saucer() -> void:
	emit_signal("saucer_hit", value)
	print("SAUCER: hit")
	queue_free()

func warp_saucer() -> void:
	queue_free()

#=====CONNECTED FUNCTIONS=====#

func _on_flying_saucer_body_entered(body):
	if body.is_in_group("player"):
		print("BONUS COLLIDE: player")
		destroy_saucer()
		body.destroy_player() # Player

# signal emitted when saucer timer is up
func _on_life_timeout():
	eol = true
	print("BONUS: EOL")

func _on_shoot_timer_timeout():
	emit_signal("saucer_shoot")

func _on_area_entered(area):
	if(area.is_in_group("bounds")) && eol:
		print("Bound enetered")
		warp_saucer()
		emit_signal("saucer_timeout")
	pass # Replace with function body.

# timeout changes the direction of the bonus ship
func _on_dir_timer_timeout():
	change_dir()
	pass # Replace with function body.
