extends Node3D

var velocity := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = Vector3(
		randf_range(-1.0, 1.0),
		0.0,
		randf_range(-1.0, 1.0)
	)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Movement math only (no physics, no rendering logic)
	position += velocity * delta
	#print("NPC processing...")
	#pass
