extends Node

@onready var asteroid_scene: PackedScene = load("res://_scenes/Asteroid/Asteroid.tscn")
@onready var player_prefab: PackedScene = load("res://_scenes/Player/Player.tscn")

# Game objects
#var asteroid
var player

var wave: int = 1
var asteroids_remaining: int = 4
var spawn_count: int = 0
var level: Node2D
var spawn_timer: Timer
var respawn_timer: Timer
var time_between_spawns: float = 1.0

# Player variables
var player_lives: int = 3
var player_timer: Timer

func _ready():
	level = get_tree().get_first_node_in_group("level")
#	asteroid_spawns = get_tree().get_nodes_in_group("asteroid_spawn")
#	initialize_spawn_timer()
	spawn_asteroids()
	spawn_player()
	connect_signals()

func _process(delta):
	pass

# connect signals of objects in game scene
func connect_signals() -> void:
	player.player_hit.connect(spawn_player)
	pass

#func initialize_spawn_timer():
#	spawn_timer = Timer.new()
#	add_child(spawn_timer)
#	spawn_timer.wait_time = time_between_spawns
#	spawn_timer.one_shot = false
#	spawn_timer.timeout.connect(spawn_asteroids)

# respawn timer for player after colliding with asteroid
func initialize_respawn_timer():
	print("Initialized respawn timer")
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = 2.0
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(spawn_player)

#func handle_next_wave() -> void:
#	spawn_count = 0
#	spawn_timer.start()

# spawn player called after player death
func spawn_player() -> void:
	print("Player spawned")
	player = player_prefab.instantiate()
	level.add_child(player)
	player.global_position = level.get_node("PlayerSpawn").global_position
	player.player_hit.connect(spawn_player)
#	player_lives -= 1

func spawn_asteroids() -> void:
	for i in asteroids_remaining:
		var asteroid = asteroid_scene.instantiate()
		level.add_child(asteroid)
		asteroid.global_position = random_position()
		spawn_count += 1

func handle_asteroid_destruction() -> void:
	asteroids_remaining -= 1
	if asteroids_remaining == 0:
		wave += 1
		asteroids_remaining = wave + 4
#		handle_next_wave()

func random_position() -> Vector2:
	randomize()
	# get random position vector
	var rand_v = Vector2(randf_range(0,1024) , randf_range(0,768))
	return rand_v
