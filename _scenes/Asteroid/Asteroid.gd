extends Area2D

@export var size: int = 0
@export var value: int = 0

@onready var screen_size = get_viewport_rect().size

var velocity := Vector2.ZERO
var rotation_speed := 1
var rotation_dir := 0.0

signal asteroid_split
# Called when the node enters the scene tree for the first time.
func _ready():
	if size == 3:
		init_velocity()
	set_random_rot_dir()

func _process(delta) -> void:
	position += velocity * delta
	set_rotation(rotation + rotation_dir *  rotation_speed * delta)
	screen_wrap()

# called when asteroid is split
func split_velocity(new_velocity: Vector2):
	velocity = new_velocity

# initialize velocity for only largest asteroid size
func init_velocity():
	randomize()
	var x = randf_range(-100,100)
	var y = randf_range(-100,100)
	velocity = Vector2(x,y)

# should be called when initialized
func set_random_rot_dir():
	randomize()
	rotation_dir = randf_range(-2,2)

func get_asteroid_size() -> int:
	return size

func break_asteroid() -> void:
	emit_signal("asteroid_split", size, velocity, global_position, value)
	# split the asteroid in 2
	# check size of the asteroid
	# shrink the current one and add a medium as child?
	queue_free()

func screen_wrap() -> void:
	position = position.posmodv(screen_size)

#=====CONNECTED FUNCTIONS=====#

func _on_asteroid_body_entered(body):
	if body.is_in_group("player"):
		print("ASTEROID HIT: player")
		break_asteroid()
		body.destroy_player() # Player
