extends Node2D

@export var bug_scene: PackedScene
var timeUnilNextBug
var rng = RandomNumberGenerator.new()
var bugTimer = 0
@export var pathXLimits:Vector2


func _game_restart() -> void:
	timeUnilNextBug = rng.randi_range(0,2)
	bugTimer = 0;
	$BugTimer.start()
	removeBugs()
	

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
		bug.position = Vector2((rng.randf_range(get_viewport_rect().position.x, get_viewport_rect().position.x + get_viewport_rect().size.x))/8 - global_position.x/8,rng.randi_range(0,20))
		print(bug.position)
		$Bugs.add_child(bug)
		
		timeUnilNextBug = rng.randf_range(2,4)
		bugTimer = 0
		
func _on_switch(action : bool):
	if (action): $BugTimer.stop()
	else: $BugTimer.start()
	
func spawnDefeatedBugs(bugs: Array):
	for bug in bugs:
		print(bug)
		var newBug = bug_scene.instantiate()
		newBug.position = bug - Vector2(global_position.x/8, 0)
		$Bugs.add_child(newBug)
		newBug.spawnAsDefeated()


func removeBugs():
	var bugs = $Bugs.get_children()
	for bug in bugs:
		bug.queue_free()
