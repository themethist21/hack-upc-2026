extends CanvasLayer

signal start_game
signal resume_game(action: bool)

var gameStarted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		$StartScreen.hide()
		if (!gameStarted):
			start_game.emit()
			gameStarted = true
		else:
			resume_game.emit(false)
			$PauseScreen.hide()

func updateScore(score: int):
	$ScoreLabel.text = str(score)

func updateTime(time: int):
	$TimeLabel.text = str(time)

func showGameOverScreen(score: int):
	$GameOverScreen.show()
	$GameOverScreen/GOScoreLabel.text = str(score)
	gameStarted = false
 	
func showPauseScreen():
	$PauseScreen.show()


func _on_retry_button_pressed() -> void:
	start_game.emit()
	$GameOverScreen.hide()
	gameStarted = true
	updateScore(0)


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
