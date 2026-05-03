extends Node2D

var rng = RandomNumberGenerator.new()
var velocity = 70
var dir = 0

var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DeathTimer.start()
	$AnimatedSprite2D.animation = "walk"
	$AnimatedSprite2D.play()
	velocity = rng.randf_range(65, 100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += velocity*dir*delta
	
func setDir(movement: int):
	dir = clampi(movement, -1, 1)
	if dir > 0: $AnimatedSprite2D.flip_h = true

func onAttacked() -> bool:
	lives -= 1;
	if (lives <= 0):
		$CollisionShape2D.disabled = true
		$AnimatedSprite2D.animation = "defeated"
		dir = 0
	else:
		$AnimatedSprite2D.animation = "damaged"
		$AttackedTimer.start()
	return lives <= 0

func _on_death_timer_timeout() -> void:
	queue_free()


func _on_attacked_timer_timeout() -> void:
	$AnimatedSprite2D.animation = "walk"
	$AttackedTimer.stop()
	
