extends Node2D

@export var bug_scene: PackedScene
@export var player_node: Node2D
var rng = RandomNumberGenerator.new()

var timeUnilNextBug
var bugTimer = 0

func _game_restart() -> void:
	timeUnilNextBug = rng.randi_range(0,2)
	bugTimer = 0;
	$BugTimer.start()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeUnilNextBug = rng.randi_range(0,2)
	bugTimer = 0;
	$BugTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_bug_timer_timeout() -> void:
	bugTimer += 0.1
	if (bugTimer >= timeUnilNextBug):
		var bug = bug_scene.instantiate()
		var sidePos =  -get_viewport_rect().size.x/2 - 20 if rng.randi_range(0,1) == 0 else get_viewport_rect().size.x/2 + 20
		bug.position = Vector2(player_node.position.x + sidePos/7,rng.randf_range(-48,48))
		bug.setDir(-sidePos)
		$Bugs.add_child(bug)
		
		timeUnilNextBug = rng.randf_range(1,3)
		bugTimer = 0
		
func removeBugs():
	var bugs = $Bugs.get_children()
	for bug in bugs:
		bug.queue_free()
