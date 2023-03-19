extends Area2D

@export var speed: int = 500

@onready var screen_size = get_viewport_rect().size

# flag for determining if bullet belongs to bonus ship or player
var invader_projectile: bool = false

signal asteroid_hit
signal player_hit
signal bonus_hit
signal bullet_destroyed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# bullet movement
	position += transform.y * -speed * delta
	screen_wrap()

# updates position to opposite side of screen (x/y respectively) when node
# position exceeds screen border (x/y)
func screen_wrap() -> void:
	position = position.posmodv(screen_size)

func set_invader_projectile() -> void:
	invader_projectile = true
	$ColorRect.color = Color(1, 0, 0, 1)
	speed = 300
	$DecayTimer.wait_time = 2.5

func destroy_bullet() -> void:
	emit_signal("bullet_destroyed")
	queue_free()

#=====CONNECTED FUNCTIONS=====#

func _on_timer_timeout():
	queue_free()

func _on_bullet_area_entered(area):
	if !invader_projectile && area.is_in_group("asteroid"):
		emit_signal("asteroid_hit")
		area.break_asteroid()
		destroy_bullet()

	if invader_projectile && area.is_in_group("player"):
		emit_signal("player_hit")
		destroy_bullet()

	if !invader_projectile && area.is_in_group("bonus"):
		emit_signal("bonus_hit")
		area.destroy_saucer()
		destroy_bullet()

func _on_bullet_body_entered(body):
	if invader_projectile && body.is_in_group("player"):
		emit_signal("player_hit")
		body.destroy_player()
		destroy_bullet()
