# SINGLETON

extends Node

@onready var sml_asteroid_scene: PackedScene = load("res://_scenes/Asteroid/Asteroid.tscn")
@onready var med_asteroid_scene: PackedScene = load("res://_scenes/Asteroid/MediumAsteroid.tscn")
@onready var lrg_asteroid_scene: PackedScene = load("res://_scenes/Asteroid/LargeAsteroid.tscn")
@onready var player_prefab: PackedScene = load("res://_scenes/Player/Player.tscn")
@onready var bonus_prefab: PackedScene = load("res://_scenes/FlyingSaucer/FlyingSaucer.tscn")
@onready var bullet_prefab: PackedScene = load("res://_scenes/Bullet/Bullet.tscn")

# Save data
var save_data = {
	"rank": 1,
	"high_score": 0,
	"initials": "AAA"
}
var SAVEFILE = "user://highscores.save"

# General vars
var score: int = 0
var highscore: int = 0
var wave: int = 1
var difficulty: int = 1
var to_spawn: int = 3 # number of asteroids to spawn based on difficulty increase
var bonus_init: bool = false
var level: Node2D
var spawn_path
var spawn_follow_path
var spawn_timer: Timer
var respawn_timer: Timer
var time_between_spawns: float = 1.0
var ui
var game_over = false

# Player vars
var max_lives: int = 1
var player_one_lives: int = max_lives
var player_timer: Timer
var player
var spawnable: bool = false

# Bonus vars
var bonus
var bonus_timer: Timer

# Asteroid vars
var max_asteroids := 196
var asteroids_timer: Timer
var asteroids_remaining: int = 0
var asteroid
var ast_spawnable = true # true to init asteroids

# Signals
signal last_asteroid_destroyed

func _ready():
	set_references()
	load_game()

func _process(delta):
	if !game_over:
		if !bonus_init:
			init_bonus_spawn_timer()
		if spawnable && level.spawn_clear():
			spawn_player()
		if ast_spawnable && wave != 1 && !bonus:
			handle_next_wave()
	pass

# connect signals of objects in game scene
func connect_signals() -> void:
	# ui connectors
	ui.quit.connect(quit_game)
	ui.play_again.connect(reset_game)
	# asteroid connectors
	var asteroids = get_tree().get_nodes_in_group("asteroid")
	for asteroid in asteroids:
		asteroid.asteroid_split.connect(handle_asteroid_destruction)
	pass

#=====SAVE_DATA=====#
func save_highscore() -> void:
	var saveFile = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	saveFile.store_32(highscore)

func load_highscore() -> void:
	var loadFile = FileAccess.open(SAVEFILE, FileAccess.READ)
	if FileAccess.file_exists(SAVEFILE):
		highscore = loadFile.get_32()
#=====SAVE_DATA_END=====#

#=====GAME_FLOW=====#
func set_references() -> void:
	level = get_tree().get_first_node_in_group("level")
	ui = get_tree().get_first_node_in_group("ui")
	spawn_path = get_tree().get_first_node_in_group("spawn_path")
	spawn_follow_path = spawn_path.get_child(0)
	
func load_game() -> void:
	spawn_asteroids(3)
	set_remaining_asteroids()
	spawn_player()
	connect_signals()
#	ui.update_score()
#	ui.load_lives()

func reset_game() -> void:
	clear_screen()
	player_one_lives = 1
	score = 0
	difficulty = 1
	wave = 1
	ui.toggle_replay()
	ui.update_score()
	ui.load_lives()
	load_game()
	pass

func clear_screen() -> void:
	print("RESET GAME")
	if player != null:
		player.queue_free()
	if bonus != null:
		bonus.queue_free()
	clear_asteroids()
	pass

func clear_asteroids() -> void:
	var asteroids = get_tree().get_nodes_in_group("asteroid")
	if asteroids.size() > 0:
		for asteroid in asteroids:
			asteroid.queue_free()
		pass

func handle_next_wave() -> void:
#	print("handle_next_wave")
#	print("Wave: ", wave)
#	print("Difficulty: ", difficulty)
#	print("to_spawn:", to_spawn)
	spawn_asteroids(3)
	set_remaining_asteroids()

func set_remaining_asteroids() -> void:
	asteroids_remaining = to_spawn * 11

func quit_game() -> void:
		get_tree().quit()
		
#=====GAME_FLOW_END=====#

#=====TIMERS=====#
# respawn timer for player after colliding with asteroid
func init_asteroid_timer():
	print("Initialized asteroid timer")
	asteroids_timer = Timer.new()
	add_child(asteroids_timer)
	asteroids_timer.wait_time = 3.0
	asteroids_timer.one_shot = true
	asteroids_timer.start()
	asteroids_timer.timeout.connect(set_ast_status) # player respawn is called when respawn_timer timeout

# respawn timer for player after colliding with asteroid
func init_respawn_timer():
	print("Initialized respawn timer")
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = 2.0
	respawn_timer.one_shot = true
	respawn_timer.start()
	respawn_timer.timeout.connect(set_spawn_status) # player respawn is called when respawn_timer timeout

func init_bonus_spawn_timer() -> void:
	print("Initialized bonus spawn timer")
	bonus_timer = Timer.new()
	add_child(bonus_timer)
	bonus_init = true
	bonus_timer.wait_time = 5.0
	bonus_timer. one_shot = true
	bonus_timer.start()
	bonus_timer.timeout.connect(spawn_bonus) # bonus spawner is called when bonus_timer timeout
#=====TIMERS END=====#

#=====SPAWNERS=====#
func set_spawn_status() -> void:
	spawnable = true

func set_ast_status() -> void:
	ast_spawnable = true
	
# spawn player called after player death
func spawn_player() -> void:
	# removes timer when player spawns
	if respawn_timer != null:
		respawn_timer.queue_free()
	player = player_prefab.instantiate()
	player.position = level.get_node("PlayerSpawn").position
	player.player_hit.connect(init_respawn_timer)
	player.player_hit.connect(handle_player_destruction)
	level.add_child(player)
	spawnable = false

# spawn asteroids given size and number
func spawn_asteroids(size: int) -> void:
	# removes timer spawn timer
	if asteroids_timer:
		asteroids_timer.queue_free()
	if size == 3:
		for i in to_spawn:
			asteroid = lrg_asteroid_scene.instantiate()
			add_asteroids(random_position())
	elif size == 2:
		for i in to_spawn:
			asteroid = med_asteroid_scene.instantiate()
			add_asteroids(random_position())
	elif size == 1:
		for i in to_spawn:
			asteroid = sml_asteroid_scene.instantiate()
			add_asteroids(random_position())
	ast_spawnable = false
	
# adds asteroids to scene
func add_asteroids(position: Vector2) -> void:
	asteroid.asteroid_split.connect(handle_asteroid_destruction) # connect destruction signal
	level.add_child(asteroid)
	asteroid.global_position = position

# splits asteroids into smaller asteroids given size and instances given velocity and position
func split_asteroids(size: int, velocity: Vector2, ast_position: Vector2) -> void:
	if size == 3:
		for i in 2:
			asteroid = med_asteroid_scene.instantiate()
			asteroid.split_velocity(random_velocity(velocity))
			add_asteroids(ast_position)
	elif size == 2:
		for i in 4:
			asteroid = sml_asteroid_scene.instantiate()
			asteroid.split_velocity(random_velocity(velocity))
			add_asteroids(ast_position)
		pass
	pass

func spawn_bonus() -> void:
	if bonus_timer:
		bonus_timer.queue_free()
	print("Bonus spawned")
	bonus = bonus_prefab.instantiate()
	bonus.global_position = random_position()
	level.add_child(bonus)
#	bonus = get_tree().get_first_node_in_group("bonus")
	bonus.saucer_shoot.connect(bonus_shoot)
	bonus.saucer_hit.connect(handle_bonus_destruction)
	bonus.saucer_timeout.connect(handle_bonus_timeout)
#=====SPAWNERS END=====#

#=====DESPAWN=====#
func handle_asteroid_destruction(size: int, velocity: Vector2, ast_position: Vector2, value: int) -> void:
	score += value
	asteroids_remaining -= 1
	ui.update_score()
	# get asteroid last position
	if size == 3:
		split_asteroids(size, velocity, ast_position)
	elif size == 2:
		split_asteroids(size, velocity, ast_position)
	# spawn next set of asteroids based on size
	if asteroids_remaining == 0:
		init_asteroid_timer()
		difficulty += 1
		wave += 1
		to_spawn = difficulty + 3

func handle_bonus_destruction(value: int) -> void:
	print("HANDLE BONUS DESTRUCTION")
	score += value
	ui.update_score()
	bonus_init = false

func handle_bonus_timeout() -> void:
	bonus_init = false

func handle_player_destruction() -> void:
	player_one_lives -= 1
	ui.load_lives()
	if player_one_lives < 0:
		game_over = true
		ui.toggle_replay()
#=====DESPAWN END=====#

#=====BONUS=====#
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
		sauce_bullet.set_invader_projectile()
		level.add_child(sauce_bullet)
#=====BONUS_END=====#

#=====RNG=====#
func random_position() -> Vector2:
	randomize()
	# get random position vector
	spawn_follow_path.progress_ratio = randf()
#	Vector2(randf_range(0,1024) , randf_range(0,768))
	return spawn_follow_path.position

func random_velocity(velocity: Vector2) -> Vector2:
	randomize()
	var x = velocity.x + randf_range(-50,50)
	var y = velocity.y + randf_range(-50, 50)
	velocity = Vector2(x,y)
	return velocity

func random_angle() -> float:
	randomize()
	return randf_range(-PI/8, PI/8)
#=====RNG END=====#
