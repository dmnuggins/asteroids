extends Node2D

@onready var bullet_prefab = preload("res://_scenes/Bullet/Bullet.tscn")

var rect
var color

signal can_spawn

func _ready():
	pass # Replace with function body.

#func _physics_process(delta):
#
#	if Input.is_action_just_pressed("shoot"):
#		# shoots bullets
#		if GameManager.player != null: # checks if player exists
#			player_shoot()
#
## may move to singleton for consistency
#func player_shoot() -> void:
#	var new_bullet = bullet_prefab.instantiate()
#	new_bullet.position = GameManager.player.get_gun_position() 
#	new_bullet.rotation = GameManager.player.rotation
#	add_child(new_bullet)

func spawn_clear() -> bool:
	if $PlayerSpawnZone.has_overlapping_areas():
		return false
	else:
		return true
