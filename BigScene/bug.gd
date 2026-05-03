extends Node2D

enum {BUG_COMMON, BUG_NORMAL, BUG_RARE, BUG_LEGEND, BUG_TIME, BUG_DOUBLE}

var rng = RandomNumberGenerator.new()
var timer = 0
var timeTillDeath
var speed = 0

var dying = false
var defeated = false

var rarity = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.start()
	$AnimatedSprite2D.animation = "spawn"
	$AnimatedSprite2D.play()
	chooseRarity()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed*delta


func _on_death_timer_timeout() -> void:
	timer += 1 
	if (timer == timeTillDeath):
		speed = 0
		$AnimatedSprite2D.play()
		$DeathTimer.stop()
		$HideTimer.start()
		$CollisionShape2D.disabled = true


func _on_spawn_timer_timeout() -> void:
	$SpawnTimer.stop()
	$DeathTimer.start()
	
	timeTillDeath = rng.randi_range(2,5)
	speed = (rng.randf_range(-10,10)) * 7 
	$CollisionShape2D.disabled = false
	
	$AnimatedSprite2D.animation = "hide_%d" % rarity
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.set_frame_and_progress(0,0)
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hide_%d" % rarity:
		queue_free()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _on_hide_timer_timeout() -> void:
	queue_free()

func onCatched() -> bool:
	speed = 0
	$AnimatedSprite2D.animation = "points_%d" % rarity
	$AnimatedSprite2D.play()
	$DeathTimer.stop()
	$HideTimer.wait_time = 3
	$HideTimer.start()
	$CollisionShape2D.disabled = true
	
	return !defeated
	
func spawnAsDefeated():
	$SpawnTimer.stop()
	$AnimatedSprite2D.animation = "defeated_%d" % rarity
	$AnimatedSprite2D.play()
	$CollisionShape2D.disabled = false
	defeated = true
	
func chooseRarity():
	var rarity_value = rng.randi_range(0, 100)
	if rarity_value >= 90:
		rarity = BUG_DOUBLE
	elif rarity_value >= 70:
		rarity = BUG_TIME
	elif rarity_value >= 65:
		rarity = BUG_LEGEND
	elif rarity_value >= 55:
		rarity = BUG_RARE
	elif rarity_value >= 35:
		rarity = BUG_NORMAL
	else:
		rarity = BUG_COMMON

func getPoints()->int:
	match rarity:
		BUG_COMMON:
			return 1
		BUG_NORMAL:
			return 2
		BUG_RARE:
			return 3
		BUG_LEGEND:
			return 5
		_:
			return 0

func is_bonus() -> bool:
	return rarity == BUG_DOUBLE

func is_time() -> bool:
	return rarity == BUG_TIME
