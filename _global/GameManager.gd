# SINGLETON

extends Node

@onready var sml_asteroid_scene: PackedScene = load("res://_scenes/Asteroid/Asteroid.tscn")
@onready var med_asteroid_scene: PackedScene = load("res://_scenes/Asteroid/MediumAsteroid.tscn")
@onready var lrg_asteroid_scene: PackedScene = load("res://_scenes/Asteroid/LargeAsteroid.tscn")
@onready var player_prefab: PackedScene = load("res://_scenes/Player/Player.tscn")
@onready var bonus_prefab: PackedScene = load("res://_scenes/FlyingSaucer/FlyingSaucer.tscn")
@onready var bullet_prefab: PackedScene = load("res://_scenes/Bullet/Bullet.tscn")

# State/Node vars
var level: Node2D
var ui
var spawn_path
var spawn_follow_path
var spawn_timer: Timer
var respawn_timer: Timer
var next_wave_timer: Timer
var start_game_timer: Timer
var next_wave_loadable: bool = false
var GAME_OVER = false
var GAME_START = false
var GAME_PAUSE = false

# Level scaling
var wave: int = 1
var difficulty: int = 1
var to_spawn: int = 1 # number of asteroids to spawn based on difficulty increase

# Save/data vars
var score: int = 0
var highscore: int = 0
var player_initials: String
var new_score: int
var new_score_index: int
var high_flag = false
var highest_scores = []
var numba_one: int = 0
var SAVEFILE = "user://highscores.save"

# Player vars
var max_lives: int = 8
var player_one_lives: int = 3
var player_timer: Timer
var player
var player_spawnable: bool = false

# Bonus vars
var bonus
var bonus_timer: Timer
var bonus_spawnable: bool = false

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
	for i in 4:
		spawn_asteroids()
	init_bonus_spawn_timer()
	ui.start_game.connect(start_game)
	ui.start_game.connect(clear_screen)

func _process(delta):
	
#
	if GAME_START:
		init_start_game_timer()
		GAME_START = false
	
	if !GAME_OVER: 
		
		
		
		if next_wave_loadable && wave > 1 && bonus == null:
			init_next_wave_timer()
		if bonus_spawnable && asteroids_remaining > 0:
			init_bonus_spawn_timer()
			
		ui.show_not_clear(level.spawn_clear(),player_spawnable)
		if player_spawnable && level.spawn_clear():
			spawn_player()

	
	pass

# connect signals of objects in game scene
func connect_signals() -> void:
	# ui connectors
	ui.quit.connect(quit_game)
	ui.play_again.connect(reset_game)
	ui.initial_submit.connect(set_initials)

#=====SAVE_DATA=====#
# returns true if new high score is achieved that makes top 10
func new_highscore() -> bool:
	var new_highscore = false
	# conditinal when there is no save data
	if highest_scores.size() <= 1:
#		highest_scores.push_front([score, "initials"])
		new_highscore = true
	else:
#		highest_scores.reverse() # so array goes from lowest to highest
		var cur_num
		var size = highest_scores.size()
		
		for x in size:
			cur_num = highest_scores[x][0]
			# check if there is only one value, just add to array if higher
			if score > cur_num && size < 1:
#				highest_scores.push_front([score, "initials"])
				new_highscore = true
#				new_score_index = 0
				break
			# if more than one value
			if score >= cur_num && size >= 1:
#				highest_scores.insert(x, [score,"initials"])
				new_highscore = true
				new_score_index = x
				break
				# check if next number is >=, then push if conditional true
			else:
				continue
		
#	print(highest_scores)
	return new_highscore

# save high scores in save file
func upload_scores():
	if highest_scores.size() <= 1:
		highest_scores.push_front([score,player_initials])
	else:
		highest_scores.insert(new_score_index, [score,player_initials])
	# conditional to truncate top 10 scores
	if highest_scores.size() > 10:
		highest_scores.pop_back()
	var saveFile = FileAccess.open("user://highscores.save", FileAccess.WRITE)
	for i in highest_scores.size():
		saveFile.store_line(str(i, ":", highest_scores[i][0], ",",highest_scores[i][1],"\r"))

# loads high scores from save file
func load_highscore():
	
	if not FileAccess.file_exists("user://highscores.save"):
		print("ERROR: no save data to load")
		return # Error! No save data to load.
		
	var loadFile = FileAccess.open(SAVEFILE, FileAccess.READ)
	var loaded_scores = []
	
	for i in loadFile.get_as_text().count(":"):
		var line = loadFile.get_line()
		var index = line.split(":")[0]
		var content = line.split(":")[1]
		var load_score = content.split(",")[0]
		var load_name = content.split(",")[1]
		loaded_scores.push_back([int(load_score), load_name])
		
	loadFile.close()
	if loaded_scores.size() > 0:
		numba_one = loaded_scores[0][0]
	ui.update_numba_one(numba_one)
	print(loaded_scores)
	return loaded_scores
#=====SAVE_DATA_END=====#

#=====GAME_FLOW=====#
# links up singleton with primary game elements (ui, level, spawn_path)
func set_references() -> void:
	level = get_tree().get_first_node_in_group("level")
	ui = get_tree().get_first_node_in_group("ui")
	spawn_path = get_tree().get_first_node_in_group("spawn_path")
	spawn_follow_path = spawn_path.get_child(0)

# to-do
func start_game() -> void:
	if bonus != null:
		bonus.manual_timeout()
	if bonus_timer != null:
		bonus_timer.queue_free()
	GAME_START = true
	pass

# loads game assets & initialize spawners
func load_game() -> void:
	highest_scores = load_highscore()
	spawn_asteroids()
	set_remaining_asteroids()
	player_spawn_init()
	spawn_player()
	bonus_spawn_init()
	connect_signals()

# initialize game load
func initial_game() -> void:
	GAME_OVER = false
	clear_screen()
	player_one_lives = 3
	score = 0
	difficulty = 1
	wave = 1
	to_spawn = difficulty
	ui.update_score()
	ui.load_lives()
	load_game()
	pass

# reset game
func reset_game() -> void:
	# toggle specific UI elements for loop when player has new high score
	if high_flag: # add conditional if game is not idle
		#replay & highscore
		ui.toggle_replay()
		ui.toggle_highscores()
		ui.toggle_leaderboard()
		ui.toggle_initials()
	# toggle specific UI elements for loop when NO new high score
	else:
		ui.toggle_replay()
	GAME_OVER = false
	clear_screen()
	player_one_lives = 3
	score = 0
	difficulty = 1
	wave = 1
	to_spawn = difficulty
	ui.update_score()
	ui.load_lives()
	load_game()
	pass

# clears screen of all player, asteroid, bonus assets
func clear_screen() -> void:
	print("Screen cleared")
	if player != null:
		player.queue_free()
	if bonus != null:
		bonus_spawnable = false
		bonus.queue_free()
	clear_asteroids()
	pass

# clear all asteroids from tree
func clear_asteroids() -> void:
	var asteroids = get_tree().get_nodes_in_group("asteroid")
	if asteroids.size() > 0:
		for asteroid in asteroids:
			asteroid.queue_free()
		pass

# spawns next wave of asteroids
func handle_next_wave() -> void:
	difficulty += 1
	wave += 1
	to_spawn = difficulty
	print("next wave handled")
	if bonus != null:
		print("bonus timeout")
		bonus.manual_timeout()
		bonus_spawnable = false
	if bonus_timer != null:
		bonus_timer.queue_free()
	if player_one_lives <= max_lives:
		player_one_lives += 1
	ui.load_lives()
	next_wave_init()
	

func set_remaining_asteroids() -> void:
	asteroids_remaining = to_spawn * 7

# quit game
func quit_game() -> void:
	get_tree().quit()

# handle game over state
func game_over() -> void:
	GAME_OVER = true
	if new_highscore():
		print("NEW HIGH SCORE")
		# Prompt user for for initials
		ui.toggle_highscores()
		high_flag = true
	else:
		high_flag = false
		print("NO NEW SCORE")
		ui.toggle_replay()
	
	

# get initals, update temp array of high scores, upload new high scores (may rename func to something more suitable)
func set_initials(new_text: String) -> void:
	player_initials = new_text
	upload_scores()
	numba_one = highest_scores[0][0]
	ui.update_numba_one(numba_one)
	ui.toggle_initials()
	ui.update_leaderboard(highest_scores)
	ui.toggle_leaderboard()
	ui.toggle_replay()
#=====GAME_FLOW_END=====#

#=====TIMERS=====#
# delay timer for player after colliding with asteroid
func init_start_game_timer():
	print("Initialized respawn timer")
	ui.update_wave_label(wave)
	ui.toggle_wave_label()
	start_game_timer = Timer.new()
	add_child(start_game_timer)
	start_game_timer.wait_time = 1.0
	start_game_timer.one_shot = true
	start_game_timer.start()
	start_game_timer.timeout.connect(initial_game) # player respawn is called when respawn_timer timeout
# respawn timer for player after colliding with asteroid
func init_respawn_timer():
	print("Initialized respawn timer")
	respawn_timer = Timer.new()
	add_child(respawn_timer)
	respawn_timer.wait_time = 1.0
	respawn_timer.one_shot = true
	respawn_timer.start()
	respawn_timer.timeout.connect(player_spawn_init) # player respawn is called when respawn_timer timeout

# bonus spawn timer
func init_bonus_spawn_timer() -> void:
	bonus_spawnable = false
	print("Initialized bonus spawn timer")
	bonus_timer = Timer.new()
	add_child(bonus_timer)
	bonus_timer.wait_time = 15.0
	bonus_timer. one_shot = true
	bonus_timer.start()
	bonus_timer.timeout.connect(spawn_bonus) # bonus spawner is called when bonus_timer timeout

# next_wave timer
func init_next_wave_timer() -> void:
	print("Initialized next wave spawn timer")
	ui.update_wave_label(wave)
	ui.toggle_wave_label()
	next_wave_loadable = false
	next_wave_timer = Timer.new()
	add_child(next_wave_timer)
	next_wave_timer.wait_time = 5.0
	next_wave_timer. one_shot = true
	next_wave_timer.start()
	next_wave_timer.timeout.connect(spawn_asteroids) # bonus spawner is called when bonus_timer timeout
	next_wave_timer.timeout.connect(bonus_spawn_init)
	
func next_wave_init() -> void:
	next_wave_loadable = true
#=====TIMERS END=====#

#=====SPAWNERS=====#
func player_spawn_init() -> void:
	player_spawnable = true

func ast_spawn_init() -> void:
	ast_spawnable = true

func bonus_spawn_init() -> void:
	bonus_spawnable = true
	
# spawn player called after player death
func spawn_player() -> void:
	# removes timer when player spawns
	if respawn_timer != null:
		respawn_timer.queue_free()
	player = player_prefab.instantiate()
	player.position = level.get_node("PlayerSpawn").position
	player.player_destroyed.connect(init_respawn_timer)
	player.player_hit.connect(handle_player_destruction)
	player.player_shoot.connect(player_shoot)
	level.add_child(player)
	player_spawnable = false

func spawn_bonus() -> void:
	if bonus_timer != null:
		bonus_timer.queue_free()
	print("Bonus spawned")
	bonus = bonus_prefab.instantiate()
	bonus.global_position = random_position()
	level.add_child(bonus)
	
	# Connect bonus signals
	bonus.saucer_shoot.connect(bonus_shoot)
	bonus.saucer_hit.connect(handle_bonus_destruction)
	bonus.saucer_timeout.connect(handle_bonus_timeout)
	bonus_spawnable = false

# spawn asteroids given size and number
func spawn_asteroids() -> void:
	ui.toggle_wave_label()
	# removes timer spawn timer
	if asteroids_timer != null:
		asteroids_timer.queue_free()
	for i in to_spawn:
			asteroid = lrg_asteroid_scene.instantiate()
			add_asteroids(random_position())
	next_wave_loadable = false
	set_remaining_asteroids()
	
# adds asteroids to scene
func add_asteroids(position: Vector2) -> void:
	asteroid.asteroid_split.connect(handle_asteroid_destruction) # connect destruction signal
	level.add_child(asteroid)
	asteroid.global_position = position
#=====SPAWNERS END=====#

#=====DESPAWN=====#
func handle_asteroid_destruction(size: int, velocity: Vector2, ast_position: Vector2, value: int) -> void:
	score += value
	print(asteroids_remaining)
	asteroids_remaining -= 1
	
	ui.update_score()
	# get asteroid last position
	if size == 3:
		split_asteroids(size, velocity, ast_position)
	elif size == 2:
		split_asteroids(size, velocity, ast_position)
	# spawn next set of asteroids based on size
	if asteroids_remaining <= 0:
		emit_signal("last_asteroid_destroyed")
		handle_next_wave()

# splits asteroids into smaller asteroids given size and instances given velocity and position
func split_asteroids(size: int, velocity: Vector2, ast_position: Vector2) -> void:
	if size == 3:
		for i in 2:
			asteroid = med_asteroid_scene.instantiate()
			asteroid.split_velocity(random_velocity(velocity))
			add_asteroids(ast_position)
	elif size == 2:
		for i in 2:
			asteroid = sml_asteroid_scene.instantiate()
			asteroid.split_velocity(random_velocity(velocity))
			add_asteroids(ast_position)
		pass
	pass

func handle_bonus_destruction(value: int) -> void:
	print("HANDLE BONUS DESTRUCTION")
	bonus_spawn_init()
	score += value
	ui.update_score()

func handle_bonus_timeout() -> void:
	if asteroids_remaining >= 0 && !next_wave_loadable:
		bonus_spawn_init()
	pass

func handle_player_destruction() -> void:
	player_one_lives -= 1
	ui.load_lives()
	if player_one_lives <= 0:
		game_over()
#=====DESPAWN END=====#

#=====PLAYER=====#

func player_shoot() -> void:
	var new_bullet = bullet_prefab.instantiate()
	new_bullet.position = player.get_gun_position() 
	new_bullet.rotation = player.rotation
	add_child(new_bullet)

#=====PLAYER_END=====#

#=====BONUS=====#
# shoots bullet from saucer when called
func bonus_shoot() -> void:
	var sauce_bullet = bullet_prefab.instantiate()
	# position init
	if sauce_bullet != null:
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
