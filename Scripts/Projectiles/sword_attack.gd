extends Area2D

@export var lifetime := 0.2  # Duration in seconds

func _ready():
	# Optional: log or manipulate shape
	# $CollisionShape2D.disabled = false

	# Auto-destroy after a short time
	await get_tree().create_timer(lifetime).timeout
	queue_free()
