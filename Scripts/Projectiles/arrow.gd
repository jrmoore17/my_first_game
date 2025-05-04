extends Area2D

@export var speed := 400
@export var direction := Vector2.RIGHT  # Or set from Player.gd when shooting

func _process(delta):
	position += direction * speed * delta
	
func _ready():
	$Sprite2D.flip_h = direction.x < 0
