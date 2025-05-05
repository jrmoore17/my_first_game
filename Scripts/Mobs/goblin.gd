extends CharacterBody2D

@export var max_health := 3
@export var move_speed := 40
@export var attack_range := 32
@export var retreat_distance := 64
@export var target_path: NodePath

var current_health := max_health
var target: Node2D = null
var state := "chase"
var retreat_timer_default := 0.5
var retreat_timer := 0.0
var retreat_direction := Vector2.ZERO
var is_dead := false

func _ready():
	if target_path != null and has_node(target_path):
		target = get_node(target_path)

	if $AttackHitbox:
		$AttackHitbox.connect("body_entered", Callable(self, "_on_attack_hit"))
		$AttackHitbox.monitoring = false

	update_health_bar()

func _physics_process(delta):
	if is_dead or target == null:
		return

	match state:
		"chase":
			var dir = (target.global_position - global_position).normalized()
			velocity = dir * move_speed
			move_and_slide()

			$AnimatedSprite2D.flip_h = velocity.x < 0
			play_animation("run")

			if global_position.distance_to(target.global_position) < attack_range:
				velocity = Vector2.ZERO
				state = "attack"

		"attack":
			velocity = Vector2.ZERO
			play_animation("attack")
			$AttackHitbox.monitoring = true
			await $AnimatedSprite2D.animation_finished
			$AttackHitbox.monitoring = false

			retreat_direction = (global_position - target.global_position).normalized()
			retreat_timer = retreat_timer_default
			state = "retreat"

		"retreat":
			velocity = retreat_direction * move_speed
			move_and_slide()
			$AnimatedSprite2D.flip_h = velocity.x < 0
			play_animation("run")

			retreat_timer -= delta
			if retreat_timer <= 0:
				state = "chase"

func _on_attack_hit(body):
	if is_dead:
		return

	if body.has_method("take_damage"):
		body.take_damage(1)

func take_damage(amount: int = 1):
	if is_dead:
		return

	current_health -= amount
	update_health_bar()

	modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if current_health <= 0:
		die()

func update_health_bar():
	if has_node("HealthBar"):
		$HealthBar.value = current_health

func die():
	is_dead = true
	velocity = Vector2.ZERO

	$AnimatedSprite2D.play("die")

	if has_node("HealthBar"):
		$HealthBar.visible = false

	await $AnimatedSprite2D.animation_finished
	queue_free()


func play_animation(name: String):
	if $AnimatedSprite2D.animation != name:
		$AnimatedSprite2D.play(name)
