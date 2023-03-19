extends CanvasLayer

@onready var p1_ships: TextureRect = $TopScreen/PlayerOne/Ships
@onready var p2_ships: TextureRect

var p1_num_lives: int
var p2_num_lives: int

signal play_again
signal quit
signal initial_submit
signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.ui = self
#	p1_num_lives = GameManager.player_one_lives
#	load_lives()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_not_clear(clear: bool, player_spawnable: bool) -> void:
	if player_spawnable:
		if  clear:
			$Inidicators/SpawnClear.visible = false
		else:
			$Inidicators/SpawnClear.visible = true

func toggle_wave_label() -> void:
	if $Inidicators/WaveLabel.visible:
		$Inidicators/WaveLabel.hide()
	else:
		$Inidicators/WaveLabel.show()

func update_wave_label(wave_num: int) -> void:
	$Inidicators/WaveLabel.text = str("WAVE ",wave_num)

func toggle_replay() -> void:
	if $ReplayMenu.visible:
		$ReplayMenu.hide()
	else:
		$ReplayMenu.show()

func toggle_highscores() -> void:
	if $HighScores.visible:
		$HighScores.hide()
	else:
		$HighScores.show()

func toggle_initials() -> void:
	if $HighScores/Initials.visible:
		$HighScores/Initials.hide()
	else:
		$HighScores/Initials.show()

func toggle_leaderboard() -> void:
	if $HighScores/Leaderboard.visible:
		$HighScores/Leaderboard.hide()
	else:
		$HighScores/Leaderboard.show()

func load_lives() -> void:
	p1_num_lives = GameManager.player_one_lives
	p1_ships.size.x = p1_num_lives * 18
	p1_ships.position.x = (GameManager.max_lives - p1_num_lives - 4) * 18
	if p1_num_lives <= 0:
		p1_ships.hide()
		$TopScreen/PlayerOne/NoLives.show()
	else:
		p1_ships.show()
		$TopScreen/PlayerOne/NoLives.hide()

func update_numba_one(numba_one) -> void:
	$TopScreen/Highscore.text = str(numba_one)

func update_score() -> void:
	$TopScreen/PlayerOne/Score.text = str(GameManager.score)

func update_highscore() -> void:
	$TopScreen/Highscore.text = str(GameManager.highscore)

func update_leaderboard(highscores) -> void:
	var leaderboard: String
	var score: int
	var initials: String
	var rank: int
	
	for i in highscores.size():
		rank = i + 1
		score = highscores[i][0]
		initials = highscores[i][1]
		leaderboard += str(rank," \t ",score," \t ",initials,"\n")
	$HighScores/Leaderboard.text = leaderboard

func _on_play_again_pressed():
	emit_signal("play_again")
#	toggle_initials() # turn back on for next highscore prompt
	pass # Replace with function body.

func _on_quit_pressed():
	emit_signal("quit")
	pass # Replace with function body.

func _on_initial_input_text_submitted(new_text: String):
	emit_signal("initial_submit", new_text)
	pass # Replace with function body.


func _on_start_game_pressed():
	emit_signal("start_game")
	$StartGame.hide()
	pass # Replace with function body.
