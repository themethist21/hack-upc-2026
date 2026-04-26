extends Node2D

@export var bug_scene: PackedScene
var timeUnilNextBug
var rng = RandomNumberGenerator.new()
var bugTimer = 0
@export var pathXLimits:Vector2


func _game_start() -> void:
	$BugTimer.start()
	timeUnilNextBug = rng.randi_range(0,2)
	bugTimer = 0;
	
func _game_end() -> void:
	$BugTimer.stop()

func _game_pause(action: bool) -> void:
	if (action): $BugTimer.stop()
	else: $BugTimer.start()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bug_timer_timeout() -> void:
	bugTimer += 0.1
	print(bugTimer)
	if (bugTimer >= timeUnilNextBug):
		var bug = bug_scene.instantiate()
		bug.position = Vector2((rng.randf_range(get_viewport_rect().position.x, get_viewport_rect().position.x + get_viewport_rect().size.x))/7,rng.randi_range(0,20))
		add_child(bug)
		
		timeUnilNextBug = rng.randf_range(2,4)
		bugTimer = 0
