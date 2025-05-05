extends CharacterBody2D

@export var speed := 200
@export var sword_scene: PackedScene
@export var arrow_scene: PackedScene

var facing_direction := Vector2.RIGHT
var is_attacking := false  # prevent animation conflicts

var shadow_offset_right = -3
var shadow_offset_left = -4

var hitbox_offset_right = -8
var hitbox_offset_left = 8

func _ready():
	# Scale only the visual portion (not physics)
	$Visual.scale = Vector2(2, 2)
	$Visual/Shadow.scale = Vector2(0.4, 0.2)  # base idle shadow scale

func _physics_process(delta):
	if is_attacking:
		return  # don't move or animate during attack

	var direction = Vector2.ZERO

	# Movement input
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1

	# Set facing direction and flip the visuals (not the physics)
	if direction.x != 0:
		facing_direction = Vector2(direction.x, 0).normalized()
		$Visual.scale.x = -2 if facing_direction.x < 0 else 2

		$Visual/Shadow.position.x = shadow_offset_left if facing_direction.x < 0 else shadow_offset_right
		$CollisionShape2D.position.x = hitbox_offset_left if facing_direction.x < 0 else hitbox_offset_right

	# Animate and squash shadow while moving
	if direction.length() > 0:
		$Visual/PlayerAnimation.play("run")
		$Visual/Shadow.scale = Vector2(0.0375, 0.02)  # squash
	else:
		$Visual/PlayerAnimation.play("idle")
		$Visual/Shadow.scale = Vector2(0.05, 0.025)  # idle scale

	# Move the player
	velocity = direction.normalized() * speed
	move_and_slide()
	position = position.round()

func _input(event):
	if event.is_action_pressed("swing_sword") and not is_attacking:
		sword_attack()
	elif event.is_action_pressed("shoot_arrow"):
		shoot_arrow()

func sword_attack():
	if sword_scene:
		var sword = sword_scene.instantiate()
		sword.position = global_position

		# Match player visual scale for consistency
		sword.scale = Vector2(2, 2)
		sword.scale.x *= -1 if facing_direction.x < 0 else 1

		get_tree().current_scene.add_child(sword)

	# Play attack animation
	is_attacking = true
	$Visual/PlayerAnimation.play("attack")

	await get_tree().create_timer(0.3).timeout
	is_attacking = false
	$Visual/PlayerAnimation.play("idle")

func shoot_arrow():
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		arrow.position = global_position + facing_direction
		arrow.direction = facing_direction
		get_tree().current_scene.add_child(arrow)
