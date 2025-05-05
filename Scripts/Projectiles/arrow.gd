extends Area2D

@export var speed := 400
@export var direction: Vector2 = Vector2.RIGHT
var shooter: Node = null  # Avoid name conflict with Area2D's built-in 'owner'

func _ready():
	# Rotate arrow to face movement direction
	if has_node("Sprite2D"):
		$Sprite2D.rotation = direction.angle()

	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position += direction * speed * delta

	if position.y < -1000 or position.y > 1000 or position.x < -1000 or position.x > 1000:
		queue_free()

func _on_body_entered(body):
	# Ignore hitting self or the player who fired it
	if body == self or body == shooter:
		return

	if body.has_method("take_damage"):
		body.take_damage(1)

	queue_free()
