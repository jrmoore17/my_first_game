extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()  # Sword disappears after hitting
