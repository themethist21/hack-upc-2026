extends Node2D
signal game_over(score: int)
signal switch(action:bool)
signal updateHud(time: int, score: int)

var pathLimits
var score = 0
var timeLeft = 60
var gameStarted = false
var smallPath = false

func _restart_game() -> void:
	pathLimits = [$SmallPath/Path.get_node("End").position.x, $SmallPath/Path.get_node("Start").position.x]
	$SmallPath/TimeLeftTimer.stop()
	gameStarted = true
	timeLeft = 60
	score = 0
	updateHud.emit(timeLeft, score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pathLimits = [$SmallPath/Path.get_node("End").position.x, $SmallPath/Path.get_node("Start").position.x]
	$SmallPath/TimeLeftTimer.start()
	gameStarted = true
	timeLeft = 60
	score = 0
	updateHud.emit(timeLeft, score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pathLimits = [$SmallPath/Path.get_node("End").global_position.x, $SmallPath/Path.get_node("Start").global_position.x]
	
	if (!$SmallPath/Character/Catcher.is_catching() && !smallPath):
		if Input.is_action_pressed("move_right"):
			processPathMovement(-1)
		
		if Input.is_action_pressed("move_left"):
			processPathMovement(1)
	
	if Input.is_action_just_pressed("catch"):
		$SmallPath/Character/Catcher.catchReady()
		$SmallPath/CatchTimer.start();
		
	if Input.is_action_just_pressed("switch"):
		smallPath = !smallPath
		switch.emit(smallPath)


func processPathMovement(dir: int):
	var pathVelocity = (10 * dir)
	var characterVelocity = (10 * -dir)
	
	if (isCatcherInRange(characterVelocity, true)):
		$SmallPath/Character/Catcher.position.x += characterVelocity
		
	elif(!isPathOutOfBounds(pathVelocity)):
		$SmallPath/Path.position.x += pathVelocity
	
	elif (isCatcherInRange(characterVelocity, false)):
		$SmallPath/Character/Catcher.position.x += characterVelocity
		
		
func catcherMove(dir: int) -> bool:
	var newPos = (10 * dir)
	var inRange = isCatcherInRange(newPos, true)
	if (inRange):
		$SmallPath/Character/Catcher.position.x += newPos
	
	return !inRange;
	
func isCatcherInRange(movement: float, innerRange: bool) -> bool:
	if (innerRange):
		if (movement < 0 && $SmallPath/Character/Catcher.position.x + movement < $SmallPath/Character/LeftLimit.position.x):
			return false
		elif (movement > 0 && $SmallPath/Character/Catcher.position.x + movement > $SmallPath/Character/RightLimit.position.x):
			return false
	else:
		if (movement < 0 && $SmallPath/Character/Catcher.position.x + movement < $SmallPath/Character/LeftEdge.position.x):
			return false
		elif (movement > 0 && $SmallPath/Character/Catcher.position.x + movement > $SmallPath/Character/RightEdge.position.x):
			return false
	return true
		
func isPathOutOfBounds(movement: float) -> bool:
	if (movement > 0 && pathLimits[1] + movement > get_viewport_rect().position.x):
		return true
	
	elif (movement < 0 && pathLimits[0] + movement < get_viewport_rect().position.x + get_viewport_rect().size.x):
		return true
	return false


func _on_catch_timer_timeout() -> void:
	score += $SmallPath/Character/Catcher.catchDone()
	updateHud.emit(timeLeft, score)
	$SmallPath/CatchTimer.stop();


func _on_time_left_timer_timeout() -> void:
	timeLeft -= 1
	updateHud.emit(timeLeft, score)
	if (timeLeft == 0):
		$SmallPath/TimeLeftTimer.stop()
		game_over.emit(score)
		updateHud.emit(timeLeft, score)
