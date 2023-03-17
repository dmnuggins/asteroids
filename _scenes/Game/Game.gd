extends Node2D

@onready var bullet_prefab = preload("res://_scenes/Bullet/Bullet.tscn")

var rect
var color

signal can_spawn

# Called when the node enters the scene tree for the first time.
func _ready():
#	GameManager.spawn_asteroids()
#	rect = [Rect2(Vector2(192,192),Vector2(640,384))] 
#	color = [Color(1.0,0.0,0.0),Color(0.0,0.0,1.0)]
#	_draw()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_just_pressed("shoot"):
		# shoots bullets
		if GameManager.player != null: # checks if player exists
			player_shoot()

func player_shoot() -> void:
	var new_bullet = bullet_prefab.instantiate()
	new_bullet.position = GameManager.player.get_gun_position() 
	new_bullet.rotation = GameManager.player.rotation
	add_child(new_bullet)

func spawn_clear() -> bool:
	if $PlayerSpawnZone.has_overlapping_areas():
		return false
	else:
		return true

#func _draw(): 
#	for i in range(rect.size()): 
#		draw_rect(rect[i],color[i]) 
