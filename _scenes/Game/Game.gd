extends Node2D

@onready var bullet_prefab = preload("res://_scenes/Bullet/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
#	GameManager.spawn_asteroids()
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

# shoots bullet from saucer when called
func saucer_shoot() -> void:
	var sauce_bullet = bullet_prefab.instantiate()
	# position init
	sauce_bullet.position = GameManager.bonus.position
	sauce_bullet.look_at(GameManager.player.position)
	# rotation init
	sauce_bullet.set_invader_projectile()
	add_child(sauce_bullet)
	pass
