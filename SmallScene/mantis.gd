extends Node2D

var catched = []
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	$HitSprite.hide()
	$AnimatedSprite2D.animation = "walk"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func attack() -> Array:
	if attacking: return []
	attacking = true
	
	$HitSprite.show()
	$HitSprite.play()
	$HitTimer.start()
	$AnimatedSprite2D.animation = "attack"
	
	var defeated = []
	for bug in catched:
		if( bug.onAttacked()): defeated.append(bug)
		
	return defeated


func _on_hitbox_body_entered(body: Node2D) -> void:
	catched.append(body)


func _on_hitbox_body_exited(body: Node2D) -> void:
	catched.erase(body)


func _on_hit_timer_timeout() -> void:
	$HitSprite.hide()
	$HitSprite.stop()
	$HitSprite.set_frame_and_progress(0, 0)
	$AnimatedSprite2D.animation = "walk"
	$HitTimer.stop()
	attacking = false
