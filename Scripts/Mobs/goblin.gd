extends CharacterBody2D

@export var max_health := 3
@export var move_speed := 50
@export var target_path: NodePath  # Optional: player or patrol target

var current_health := max_health
var is_dead := false
var target: Node2D = null  # Typed properly to avoid warning

func _ready():
	update_health_bar()
	if target_path != null:
		target = get_node(target_path)

func _physics_process(delta):
	if is_dead:
		return

	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

		if velocity.length() > 0:
			play_animation("run")
			$AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			play_animation("idle")
	else:
		velocity = Vector2.ZERO
		play_animation("idle")

func take_damage(amount: int = 1):
	if is_dead:
		return

	current_health -= amount
	print("Goblin hit! HP left: ", current_health)

	modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if current_health <= 0:
		die()
	else:
		update_health_bar()

func die():
	is_dead = true
	play_animation("die")
	velocity = Vector2.ZERO
	await $AnimatedSprite2D.animation_finished
	queue_free()

func update_health_bar():
	if has_node("HealthBar"):
		$HealthBar.value = current_health

func play_animation(name: String):
	if $AnimatedSprite2D.animation != name:
		$AnimatedSprite2D.play(name)

func attack():
	if is_dead:
		return

	play_animation("attack")
	await $AnimatedSprite2D.animation_finished
