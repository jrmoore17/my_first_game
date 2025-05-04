extends CharacterBody2D

@export var speed := 200
@export var sword_scene: PackedScene
@export var arrow_scene: PackedScene

func _ready():
	$PlayerAnimation.scale = Vector2(2, 2)

var facing_direction := Vector2.RIGHT
var is_attacking := false  # prevent animation conflicts

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

	# Set facing direction
	if direction.x != 0:
		facing_direction = Vector2(direction.x, 0).normalized()
		$PlayerAnimation.flip_h = facing_direction.x < 0

	# Move
	velocity = direction.normalized() * speed
	move_and_slide()

	# Play idle or walk animation
	if direction.length() > 0:
		$PlayerAnimation.play("run")
	else:
		$PlayerAnimation.play("idle")
		
	position = position.round()

func _input(event):
	if event.is_action_pressed("swing_sword") and not is_attacking:
		sword_attack()
	elif event.is_action_pressed("shoot_arrow"):
		shoot_arrow()

func sword_attack():
	if sword_scene:
		var sword = sword_scene.instantiate()
		var offset = facing_direction * 20
		sword.position = global_position + offset
		get_tree().current_scene.add_child(sword)

	# Play attack animation
	is_attacking = true
	$PlayerAnimation.play("attack")

	# Wait for the attack animation to finish, then return to idle
	await get_tree().create_timer(0.3).timeout
	is_attacking = false
	$PlayerAnimation.play("idle")

func shoot_arrow():
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		arrow.position = global_position + facing_direction * 15 + Vector2(0, 30)
		arrow.direction = facing_direction
		get_tree().current_scene.add_child(arrow)
