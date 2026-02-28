extends Node3D

var velocity := Vector3(1, 0, 0)
var accumulator := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Spawned")
	self.set_process(false)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Movement math only (no physics, no rendering logic)
	var v = velocity * delta
	position += v

	#Small CPU work per node
	var x = accumulator
	for i in range(10):
		x += sin(x + float(i))
	accumulator += x
	
	#pass
