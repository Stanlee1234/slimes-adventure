extends CharacterBody2D
const SPEED = 200.0
const ACCELERATION = 1200.0
const FRICTION = 1000.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_PUSH = 200.0
const WALL_SLIDE_MAX_SPEED = 150.0

const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.15

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("up"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if not is_on_floor():
		if is_on_wall() and velocity.y > 0:
			velocity.y = min(velocity.y + gravity * delta, WALL_SLIDE_MAX_SPEED)
		else:
			velocity.y += gravity * delta
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
		elif is_on_wall():
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * WALL_JUMP_PUSH
			jump_buffer_timer = 0

	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()
	update_animations(direction)

func update_animations(direction):
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func _on_death_zone_body_entered(_body):
	call_deferred("die")

func die():
	get_tree().reload_current_scene()
