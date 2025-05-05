extends Area2D

@export var speed := 400
@export var direction: Vector2 = Vector2.RIGHT

func _ready():
	# Rotate the visual only (guaranteed to work no matter what sprite orientation)
	if has_node("Sprite2D"):
		$Sprite2D.rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta

	if position.y < -1000 or position.y > 1000 or position.x < -1000 or position.x > 1000:
		queue_free()
