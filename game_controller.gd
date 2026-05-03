extends Node2D

signal game_over(score: int)
signal switch(action:bool)
signal updateHud(time: int, score: int)
signal updateBar(val: float)
signal switchMode(mode: bool)
signal updateBonus(bonus: int)
signal showTimeBonus()

const START_TIME = 100

var score = 0
var timeLeft = START_TIME
var switchTimer = 0
var bonus = 1
var smallPath = true

var cameraPanning = false
var camVelocity = Vector2(0,0)
var camTarget = Vector2(0,0)

func _restart_game() -> void:
	$TimeLeftTimer.start()
	$StageSwitchTimer.start()
	timeLeft = START_TIME
	score = 0
	smallPath = true
	switchTimer = 0
	bonus = 0
	updateHud.emit(timeLeft, score)
	
	resume_node($SmallPath)
	pause_node($BigPath)
	$SmallPath/Camera2D.make_current()
	$SmallPath/Camera2D.position = Vector2(640,360)
	switchMode.emit(false)
	updateBonus.emit(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimeLeftTimer.start()
	$StageSwitchTimer.start()
	$BigPath.process_mode = Node.PROCESS_MODE_DISABLED
	$BigPath.request_ready()
	timeLeft = START_TIME
	score = 0
	updateHud.emit(timeLeft, score)
	$SwitchCutscene.play()
	updateBonus.emit(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (cameraPanning): $SmallPath/Camera2D.position += camVelocity*delta
	
	if Input.is_action_just_pressed("switch"):
		smallPath = !smallPath
		if (smallPath):
			resume_node($SmallPath)
			pause_node($BigPath)
			$SmallPath/Camera2D.make_current()
			$SmallPath.spawnDefeatedBugs($BigPath.getDefeatedBugs())
		else:
			pause_node($SmallPath)
			resume_node($BigPath)
			$BigPath/Character/Mantis/Camera2D.make_current()
			$BigPath.reset()


func _on_time_left_timer_timeout() -> void:
	timeLeft -= 1
	updateHud.emit(timeLeft, score)
	if (timeLeft == 0):
		$TimeLeftTimer.stop()
		$StageSwitchTimer.stop()
		game_over.emit(score)
		updateHud.emit(timeLeft, score)
		pause_node($BigPath)
		pause_node($SmallPath)


func _on_small_path_pray_catched(amount: int) -> void:
	score += amount*bonus
	updateHud.emit(timeLeft, score)
	
func pause_node(node: Node2D):
	node.process_mode = Node.PROCESS_MODE_DISABLED

func resume_node(node: Node2D):
	node.process_mode = Node.PROCESS_MODE_INHERIT
	

func switchToBigPath():
	smallPath = false
	pause_node($SmallPath)	
	$BigPath.reset()
	switchTimer = 7
	switchMode.emit(true)
	$StageSwitchTimer.stop()
	$SwitchDownTimer.start()
	setupCamMovement(Vector2(640,1360), 0.3)
	$SwitchCutscene.show()
	
func switchToSmallPath():
	smallPath = true
	$SmallPath/Camera2D.position = $BigPath/Character/Mantis/Camera2D.global_position
	resume_node($SmallPath)
	pause_node($BigPath)
	$SmallPath/Camera2D.make_current()
	$SmallPath.spawnDefeatedBugs($BigPath.getDefeatedBugs())
	switchTimer = 0
	switchMode.emit(false)
	setupCamMovement(Vector2(640,360), 0.3)
	$SwitchCutscene.hide()

func setupCamMovement(newPos: Vector2, time: float):
	camVelocity = (newPos - $SmallPath/Camera2D.position)/time
	camTarget = newPos
	$PanTimer.wait_time = time
	$PanTimer.start()
	$TimeLeftTimer.stop()
	cameraPanning = true


func _on_stage_switch_timer_timeout() -> void:
	if (smallPath): 
		switchTimer += 0.1
		updateBar.emit((switchTimer*100)/8)
	else: 
		switchTimer -= 0.1
		updateBar.emit((switchTimer*100)/7)
	if (smallPath && switchTimer >= 8):
		switchToBigPath()
		
	if (!smallPath && switchTimer <= 0):
		switchToSmallPath()
		


func _on_catcher_fresh_pray(many: int) -> void:
	switchTimer += many
	updateBar.emit((switchTimer*100)/8)


func _on_big_path_hit_time_bonus(bonusTime: int) -> void:
	switchTimer += 0.3*bonusTime
	updateBar.emit((switchTimer*100)/7)


func _on_switch_down_timer_timeout() -> void:
	$BigPath/Character/Mantis/Camera2D.make_current()
	resume_node($BigPath)
	$StageSwitchTimer.start()
	$SwitchDownTimer.stop()


func _on_pan_timer_timeout() -> void:
	$SmallPath/Camera2D.position = camTarget
	$PanTimer.stop()
	$TimeLeftTimer.start()
	cameraPanning = false


func _on_catcher_add_bonus() -> void:
	if bonus == 1: bonus = 2
	else: bonus += 2
	updateBonus.emit(bonus)


func _on_catcher_add_time(time: int) -> void:
	timeLeft += 10
	updateHud.emit(timeLeft, score)
