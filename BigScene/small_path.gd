extends Node2D

signal prayCatched(amount: int)

var pathLimits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pathLimits = [$Path.get_node("End").global_position.x, $Path.get_node("Start").global_position.x]
	
	if (!$Character/Catcher.is_catching()):
		if Input.is_action_pressed("move_right"):
			processPathMovement(-1)
		
		if Input.is_action_pressed("move_left"):
			processPathMovement(1)
	
	if Input.is_action_just_pressed("catch") && !$Character/Catcher.is_catching():
		$Character/Catcher.catchReady()
		$CatchTimer.start();


func processPathMovement(dir: int):
	var pathVelocity = (10 * dir)
	var characterVelocity = (10 * -dir)
	
	if (isCatcherInRange(characterVelocity, true)):
		$Character/Catcher.position.x += characterVelocity
		
	elif(!isPathOutOfBounds(pathVelocity)):
		$Path.position.x += pathVelocity
	
	elif (isCatcherInRange(characterVelocity, false)):
		$Character/Catcher.position.x += characterVelocity
		
		
func catcherMove(dir: int) -> bool:
	var newPos = (10 * dir)
	var inRange = isCatcherInRange(newPos, true)
	if (inRange):
		$Character/Catcher.position.x += newPos
	
	return !inRange;
	
func isCatcherInRange(movement: float, innerRange: bool) -> bool:
	if (innerRange):
		if (movement < 0 && $Character/Catcher.position.x + movement < $Character/LeftLimit.position.x):
			return false
		elif (movement > 0 && $Character/Catcher.position.x + movement > $Character/RightLimit.position.x):
			return false
	else:
		if (movement < 0 && $Character/Catcher.position.x + movement < $Character/LeftEdge.position.x):
			return false
		elif (movement > 0 && $Character/Catcher.position.x + movement > $Character/RightEdge.position.x):
			return false
	return true
		
func isPathOutOfBounds(movement: float) -> bool:
	if (movement > 0 && pathLimits[1] + movement > get_viewport_rect().position.x):
		return true
	
	elif (movement < 0 && pathLimits[0] + movement < get_viewport_rect().position.x + get_viewport_rect().size.x):
		return true
	return false


func _on_catch_timer_timeout() -> void:
	prayCatched.emit($Character/Catcher.catchDone())
	$CatchTimer.stop();
	
	
func spawnDefeatedBugs(bugs: Array):
	$Path.spawnDefeatedBugs(bugs)
