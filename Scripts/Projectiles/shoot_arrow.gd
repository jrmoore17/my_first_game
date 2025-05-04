extends Area2D

@export var speed := 400
@export var direction := Vector2.UP  # default to shoot upward

func _process(delta):
	position += direction * speed * delta

	# Optional: auto-remove if offscreen
	if position.y < -100 or position.y > 1000:
		queue_free()
