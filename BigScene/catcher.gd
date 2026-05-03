extends Node2D

var isCatching : bool = false;
var catched = []
signal freshPray(many: int)
signal addTime(time: int)
signal addBonus()

func _game_start() -> void:
	$Hitmarker/CatchSprite.hide()
	position.x = 640
	$AnimatedSprite2D.set_frame_and_progress(0, 0)
	$CatchOutTimer.stop();
	isCatching = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hitmarker/CatchSprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_up") && !isCatching:
		processHitmarkerMovement(-1)
		
	if Input.is_action_pressed("move_down") && !isCatching:
		processHitmarkerMovement(1)
 

func processHitmarkerMovement(dir: int):
	var velocity = 0.5 * dir
	
	if (isHitmarkerInRange(velocity) && !isCatching):
		$Hitmarker.position.y += velocity
	

func isHitmarkerInRange(movement: float) -> bool:
	if ($Hitmarker.position.y + movement > $DownLimit.position.y):
		return false
	elif ($Hitmarker.position.y + movement < $UpLimit.position.y):
		return false
	return true
	
	
func catchReady() -> Vector2:
	isCatching = true;
	$AnimatedSprite2D.set_frame_and_progress(1, 0)
	
	return $Hitmarker.global_position
	
func catchDone() -> int:
	$AnimatedSprite2D.set_frame_and_progress(2, 0)
	$Hitmarker/CatchSprite.show()
	$Hitmarker/Pointer.hide()
	$CatchOutTimer.start()
	
	var score = 0
	var fresh = 0
	var bonus = false
	for bug in catched:
		if (bug.is_bonus()): addBonus.emit()
		if (bug.is_time()): addTime.emit(10)
		score += bug.getPoints()
		if (bug.onCatched()): fresh += 1
	
	freshPray.emit(fresh)
	return score

func _on_catch_out_timer_timeout() -> void:
	isCatching = false;
	$Hitmarker/CatchSprite.hide()
	$Hitmarker/Pointer.show()
	$AnimatedSprite2D.set_frame_and_progress(0, 0)
	$CatchOutTimer.stop();
	
func is_catching() -> bool:
	return isCatching;


func _on_hitbox_body_entered(body: Node2D) -> void:
	catched.append(body)


func _on_hitbox_body_exited(body: Node2D) -> void:
	catched.erase(body)
