extends CanvasLayer

@onready var p1_ships: TextureRect = $TopScreen/PlayerOne/Ships
@onready var p2_ships: TextureRect

var p1_num_lives: int
var p2_num_lives: int

signal play_again
signal quit

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.ui = self
	p1_num_lives = GameManager.player_one_lives
	load_lives()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_lives() -> void:
	
	p1_num_lives = GameManager.player_one_lives
	p1_ships.size.x = p1_num_lives * 18
	p1_ships.position.x = (GameManager.max_lives - p1_num_lives - 1) * 18
	if p1_num_lives <= 0:
		p1_ships.hide()
		$TopScreen/PlayerOne/NoLives.show()
	else:
		p1_ships.show()
		$TopScreen/PlayerOne/NoLives.hide()

func update_score() -> void:
	$TopScreen/PlayerOne/Score.text = str(GameManager.score)

func update_highscore() -> void:
	$TopScreen/Highscore.text = str(GameManager.highscore)

func _on_play_again_pressed():
	emit_signal("play_again")
	pass # Replace with function body.

func _on_quit_pressed():
	emit_signal("quit")
	pass # Replace with function body.
