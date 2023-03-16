extends Area2D

@export var speed := 300.0

@onready var screen_size = get_viewport_rect().size

var velocity := Vector2.ZERO
var value

signal saucer_hit
signal saucer_shoot

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var x = randf_range(-100,100)
	var y = randf_range(-100, 100)
	velocity = Vector2(x,y)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	screen_wrap()


func screen_wrap() -> void:
	position = position.posmodv(screen_size)

func destroy_saucer() -> void:
	emit_signal("saucer_hit")
	print("SAUCER: hit")
	GameManager.handle_bonus_destruction()
	queue_free()

#=====CONNECTED FUNCTIONS=====#

func _on_flying_saucer_body_entered(body):
	if body.is_in_group("player"):
		print("BONUS HIT: player")
		destroy_saucer()
		body.destroy_player() # Player

func _on_shoot_timer_timeout():
	emit_signal("saucer_shoot")
	pass # Replace with function body.
