extends Node2D

signal game_over(score: int)
signal switch(action:bool)
signal updateHud(time: int, score: int)
signal updateBar(val: float)
signal switchMode(mode: bool)

var score = 0
var timeLeft = 60
var switchTimer = 0
var smallPath = true

func _restart_game() -> void:
	$TimeLeftTimer.start()
	$StageSwitchTimer.start()
	timeLeft = 60
	score = 0
	updateHud.emit(timeLeft, score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimeLeftTimer.start()
	$StageSwitchTimer.start()
	$BigPath.process_mode = Node.PROCESS_MODE_DISABLED
	$BigPath.request_ready()
	timeLeft = 60
	score = 0
	updateHud.emit(timeLeft, score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:		
	if Input.is_action_just_pressed("switch"):
		smallPath = !smallPath
		if (smallPath):
			$SmallPath.process_mode = Node.PROCESS_MODE_INHERIT
			$BigPath.process_mode = Node.PROCESS_MODE_DISABLED
			$SmallPath/Camera2D.make_current()
			
			$SmallPath.spawnDefeatedBugs($BigPath.getDefeatedBugs())
		else:
			$SmallPath.process_mode = Node.PROCESS_MODE_DISABLED
			$BigPath.process_mode = Node.PROCESS_MODE_INHERIT
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


func _on_small_path_pray_catched(amount: int) -> void:
	score += amount
	updateHud.emit(timeLeft, score)
	
func pause_node(node: Node2D):
	node.process_mode = Node.PROCESS_MODE_DISABLED

func resume_node(node: Node2D):
	node.process_mode = Node.PROCESS_MODE_INHERIT


func _on_stage_switch_timer_timeout() -> void:
	if (smallPath): 
		switchTimer += 0.1
		updateBar.emit((switchTimer*100)/8)
	else: 
		switchTimer -= 0.1
		updateBar.emit((switchTimer*100)/5)
	if (smallPath && switchTimer >= 8):
		smallPath = !smallPath
		$SmallPath.process_mode = Node.PROCESS_MODE_DISABLED
		$BigPath.process_mode = Node.PROCESS_MODE_INHERIT
		$BigPath/Character/Mantis/Camera2D.make_current()
		$BigPath.reset()
		switchTimer = 5
		switchMode.emit(true)
		
	if (!smallPath && switchTimer <= 0):
		smallPath = !smallPath
		$SmallPath.process_mode = Node.PROCESS_MODE_INHERIT
		$BigPath.process_mode = Node.PROCESS_MODE_DISABLED
		$SmallPath/Camera2D.make_current()
		$SmallPath.spawnDefeatedBugs($BigPath.getDefeatedBugs())
		switchTimer = 0
		switchMode.emit(false)
		
	


func _on_catcher_fresh_pray(many: int) -> void:
	switchTimer += many
	updateBar.emit((switchTimer*100)/8)
