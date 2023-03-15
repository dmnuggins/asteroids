extends Area2D

@onready var screen_size = get_viewport_rect().size

var size # 1, 2, 3 (large, medium, small)
var velocity = Vector2.ZERO

signal asteroid_split
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var x = randf_range(-100,100)
	var y = randf_range(-100, 100)
	velocity = Vector2(x,y)

func _process(delta) -> void:
	position += velocity * delta
	screen_wrap()
	

func break_asteroid() -> void:
	emit_signal("asteroid_split")
	# split the asteroid in 2
	# check size of the asteroid
	# shrink the current one and add a medium as child?
	GameManager.handle_asteroid_destruction()

func screen_wrap() -> void:
	position = position.posmodv(screen_size)


func _on_asteroid_area_entered(area):
	if area.is_in_group("player"):
		area.emit_signal("player_hit")
		print("ASTEROID HIT: player")
		
	pass # Replace with function body.


func _on_asteroid_body_entered(body):
	if body.is_in_group("player"):
		print("ASTEROID HIT: player")
		break_asteroid()
		body.destroy_player() # Player
