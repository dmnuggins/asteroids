extends Node

@onready var asteroid_scene: PackedScene = load("res://_scenes/Asteroid/Asteroid.tscn")
@onready var player_prefab: PackedScene = load("res://_scenes/Player/Player.tscn")
@onready var bonus_prefab: PackedScene = load("res://_scenes/FlyingSaucer/FlyingSaucer.tscn")
@onready var bullet_prefab: PackedScene = preload("res://_scenes/Bullet/Bullet.tscn")

# General vars
var wave: int = 1
var asteroids_remaining: int = 4
var spawn_count: int = 0
var bonus_spawned: bool = false
var level: Node2D
var spawn_timer: Timer
var respawn_timer: Timer
var time_between_spawns: float = 1.0

# Player vars
var player_lives: int = 3
var player_timer: Timer
var player

# Bonus vars
var bonus
var bonus_timer: Timer

func _ready():
	level = get_tree().get_first_node_in_group("level")
#	asteroid_spawns = get_tree().get_nodes_in_group("asteroid_spawn")
#	initialize_spawn_timer()
#	spawn_bonus()
	spawn_asteroids()
	spawn_player()

#	connect_signals()

func _process(delta):
	if !bonus_spawned:
		bonus_spawn_timer()
	pass

# connect signals of objects in game scene
func connect_signals() -> void:
#	player.player_hit.connect(spawn_player)
	pass

#=====TIMERS=====#
# respawn timer for player after colliding with asteroid
func initialize_respawn_timer():
	print("Initialized respawn timer")
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = 2.0
	respawn_timer.one_shot = true
	respawn_timer.start()
	respawn_timer.timeout.connect(spawn_player) # player respawn is called when respawn_timer timeout

func bonus_spawn_timer() -> void:
	print("Initialized bonus spawn timer")
	bonus_spawned = true
	bonus_timer = Timer.new()
	add_child(bonus_timer)
	bonus_timer.wait_time = 1.0
	bonus_timer. one_shot = true
	bonus_timer.start()
	bonus_timer.timeout.connect(spawn_bonus) # bonus spawner is called when bonus_timer timeout

#=====TIMERS END=====#

#func handle_next_wave() -> void:
#	spawn_count = 0
#	spawn_timer.start()

#=====SPAWNERS=====#

# spawn player called after player death
func spawn_player() -> void:
	# removes timer when player spawns
	if respawn_timer:
		respawn_timer.queue_free()
	player = player_prefab.instantiate()
	level.add_child(player)
	player.global_position = level.get_node("PlayerSpawn").global_position
	player.player_hit.connect(initialize_respawn_timer)
#	player_lives -= 1
	# need another function to handle player life logic

func spawn_asteroids() -> void:
	for i in asteroids_remaining:
		var asteroid = asteroid_scene.instantiate()
		level.add_child(asteroid)
		asteroid.global_position = random_position()
		spawn_count += 1

func spawn_bonus() -> void:
	if bonus_timer:
		bonus_timer.queue_free()
	print("Bonus spawned")
	bonus = bonus_prefab.instantiate()
	bonus.global_position = random_position()
	level.add_child(bonus)
	bonus_spawned = true
	bonus.saucer_shoot.connect(bonus_shoot)
	
#=====SPAWNERS END=====#

# shoots bullet from saucer when called
func bonus_shoot() -> void:
	var sauce_bullet = bullet_prefab.instantiate()
	# position init
	sauce_bullet.position = bonus.position
	if player != null:
		sauce_bullet.look_at(player.global_position)
		sauce_bullet.rotate(PI/2) # rotation accounted for initial launch vector of bullet
		var rand_ang = random_angle()
		sauce_bullet.rotate(rand_ang)
		print("Randome angle: ", rand_ang)
	# rotation init
	sauce_bullet.set_invader_projectile()
	level.add_child(sauce_bullet)
	pass

#=====DESTRUCTION=====#

func handle_asteroid_destruction() -> void:
	asteroids_remaining -= 1
	if asteroids_remaining == 0:
		wave += 1
		asteroids_remaining = wave + 4
#		handle_next_wave()

func handle_bonus_destruction() -> void:
	bonus_spawned = false
#=====DESTRUCTION END=====#

func random_position() -> Vector2:
	randomize()
	# get random position vector
	return Vector2(randf_range(0,1024) , randf_range(0,768))

func random_angle():
	randomize()
	return randf_range(-PI/8, PI/8)
