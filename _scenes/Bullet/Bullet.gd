extends Area2D

@export var speed: int = 500

@onready var screen_size = get_viewport_rect().size

# flag for determining if bullet belongs to bonus ship or player
var invader_projectile = false

signal asteroid_hit
signal player_hit
signal bonus_hit
signal bullet_hit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# bullet movement
	position += transform.y * -speed * delta
	screen_wrap()

func _on_timer_timeout():
	queue_free()

# updates position to opposite side of screen (x/y respectively) when node
# position exceeds screen border (x/y)
func screen_wrap() -> void:
	position = position.posmodv(screen_size)

func _on_bullet_area_entered(area):
	if area.is_in_group("asteroid"):
		emit_signal("asteroid_hit")
		area.queue_free()
		print("BULLET HIT: asteroid")

	if area.is_in_group("player") && invader_projectile:
		emit_signal("player_hit")
		print("BULLET HIT: player")

	if area.is_in_group("bonus") && !invader_projectile:
		emit_signal("bonus_hit")
		print("BULLET HIT: bonus")


#=====SIGNALS=====#

func hit() -> void:
	emit_signal("bullet_hit")
