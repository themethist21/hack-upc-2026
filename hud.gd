extends CanvasLayer

signal restart_game()

var gamePaused = true
var inGame = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		$StartScreen.hide()
		if (!gamePaused && inGame):
			$PauseScreen.show()
			gamePaused = true
			get_tree().paused = true
		else:
			get_tree().change_scene_to_file("res://MainMenu.tscn")
	
	if Input.is_action_just_pressed("start"):
		if (gamePaused):
			$StartScreen.hide()
			$PauseScreen.hide()
			gamePaused = false
			get_tree().paused = false
			inGame = true
		

func updateHud(timeLeft: int, score: int):
	$ScoreLabel.text = str(score)
	$TimeLabel.text = str(timeLeft)

func showGameOverScreen(score: int):
	$GameOverScreen.show()
	$GameOverScreen/GOScoreLabel.text = str(score)
	gamePaused = true
	get_tree().paused = true
	inGame = false


func _on_retry_button_pressed() -> void:
	restart_game.emit()
	$GameOverScreen.hide()
	gamePaused = false
	get_tree().paused = false
	inGame = true
	$IconSprite.animation = "net"


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func setSwitchBarPercentage(val: float) -> void:
	$SwitchBar.value = val
	


func _on_stage_switch_mode(mode: bool) -> void:
	if mode: $IconSprite.animation = "bug"
	else: $IconSprite.animation = "net"
