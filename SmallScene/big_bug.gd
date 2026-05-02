extends Node2D


var velocity = 70
var dir = 0

var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DeathTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += velocity*dir*delta
	
func setDir(movement: int):
	dir = clampi(movement, -1, 1)

func onAttacked() -> bool:
	lives -= 1;
	if (lives <= 0):
		$CollisionShape2D.disabled = true
		dir = 0
	return lives <= 0

func _on_death_timer_timeout() -> void:
	queue_free()
