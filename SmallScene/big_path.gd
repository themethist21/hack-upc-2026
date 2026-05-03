extends Node2D

var playerVel := Vector2(0,0)
var playerInput := Vector2(0,0)
var facingRight = true
var defeatedBugs = []
signal hitTimeBonus(bonusTime: int)

func reset():	
	$Character/Mantis.position.x = 0
	$Path.removeBugs()
	defeatedBugs = []
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	playerInput = Vector2(0,0)
	if Input.is_action_pressed("move_right"):
		playerInput[0] = 1
		if (!facingRight): 
			$Character/Mantis.scale.x *= -1
			$Character/Mantis.rotation = 0
			facingRight = true
		
	elif Input.is_action_pressed("move_left"):
		playerInput[0] = -1 
		if (facingRight): 
			$Character/Mantis.scale.x *= -1
			$Character/Mantis.rotation = 0
			facingRight = false
		
	if Input.is_action_pressed("move_up"):
		playerInput[1] = -1 
		
	elif Input.is_action_pressed("move_down"):
		playerInput[1] = 1 
		
	if Input.is_action_just_pressed("catch"):
		processAttack()
		
	processCharacterMovement(delta)
	
	$Character/Mantis.position += playerVel


func processCharacterMovement(delta: float):
	var velocity = playerInput * 100 * delta
	playerVel = boundPlayerVelocity(velocity)
		
func boundPlayerVelocity(newVelocity: Vector2) -> Vector2:
	var bounded = newVelocity
	var newPosition = $Character/Mantis.position + newVelocity
	
	if (newPosition.x > $Character/RightLimit.position.x || newPosition.x < $Character/LeftLimit.position.x):
		bounded.x = 0
	if (newPosition.y > $Character/BottomLimit.position.y || newPosition.y < $Character/TopLimit.position.y):
		bounded.y = 0
	
	return bounded

func processAttack():
	var defeated = $Character/Mantis.attack()
	for node in defeated:
		var postition = node.position
		var transformedPosition: Vector2
		transformedPosition.x = remap(node.position.x, $Character/LeftLimit.position.x, $Character/RightLimit.position.x, 0, 1280/8)
		transformedPosition.y = remap(node.position.y, -52, 52, 0, 20)
		defeatedBugs.append(transformedPosition)
	
	hitTimeBonus.emit(defeated.size())
	
func getDefeatedBugs()->Array:
	return defeatedBugs
