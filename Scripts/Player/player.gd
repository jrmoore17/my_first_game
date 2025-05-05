extends CharacterBody2D

@export var speed := 300
@export var sword_scene: PackedScene
@export var arrow_scene: PackedScene

var facing_direction := Vector2.RIGHT
var is_attacking := false

var shadow_offset_right = -3
var shadow_offset_left = -4

var hitbox_offset_right = -5
var hitbox_offset_left = 5

func _ready():
	$Visual.scale = Vector2(2, 2)
	$Visual/Shadow.scale = Vector2(0.4, 0.2)

func _process(_delta):
	pass

func _physics_process(_delta):
	if is_attacking:
		return

	var direction = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if direction.x != 0:
		facing_direction = Vector2(direction.x, 0).normalized()
		$Visual.scale.x = -2 if facing_direction.x < 0 else 2
		$Visual/Shadow.position.x = shadow_offset_left if facing_direction.x < 0 else shadow_offset_right
		$Hitbox.position.x = hitbox_offset_left if facing_direction.x < 0 else hitbox_offset_right

	if direction.length() > 0:
		$Visual/PlayerAnimation.play("run")
		$Visual/Shadow.scale = Vector2(0.0375, 0.02)
	else:
		$Visual/PlayerAnimation.play("idle")
		$Visual/Shadow.scale = Vector2(0.05, 0.025)

	velocity = direction.normalized() * speed
	move_and_slide()
	position = position.round()

func _input(event):
	if event.is_action_pressed("swing_sword") and not is_attacking:
		sword_attack()
	elif event.is_action_pressed("shoot_arrow"):
		shoot_arrow()

func sword_attack():
	var attack_dir = get_mouse_direction().normalized()
	var is_left = attack_dir.x < 0

	if sword_scene:
		var sword = sword_scene.instantiate()
		var offset = Vector2.LEFT if is_left else Vector2.RIGHT
		sword.global_position = global_position + offset * 10
		sword.scale = Vector2(-1, 1) if is_left else Vector2(1, 1)
		get_tree().current_scene.add_child(sword)

	is_attacking = true
	$Visual.scale.x = -2 if is_left else 2
	$Visual/PlayerAnimation.play("attack")

	await get_tree().create_timer(0.3).timeout
	is_attacking = false
	$Visual/PlayerAnimation.play("idle")

func shoot_arrow():
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		var attack_dir = get_mouse_direction().normalized()
		arrow.position = global_position + attack_dir * 10
		arrow.direction = attack_dir  # rotation handled inside Arrow.gd
		get_tree().current_scene.add_child(arrow)


func get_mouse_direction() -> Vector2:
	return get_global_mouse_position() - global_position
