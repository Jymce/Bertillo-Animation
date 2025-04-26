extends Area2D

@export var speed = 400
var screen_size
var idle_timer = 0.0
var is_idle_playing = false
var is_attacking = false  
var is_facing_right = true 
var is_facing_up = false  
var is_facing_down = false 

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2.ZERO

	
	var move_x = 0
	var move_y = 0
	if Input.is_action_pressed("move_right"):
		move_x += 1
		is_facing_right = true
		is_facing_up = false
		is_facing_down = false
	if Input.is_action_pressed("move_left"):
		move_x -= 1
		is_facing_right = false
		is_facing_up = false
		is_facing_down = false
	if Input.is_action_pressed("move_down"):
		move_y += 1
		is_facing_down = true
		is_facing_right = false
		is_facing_up = false
	if Input.is_action_pressed("move_up"):
		move_y -= 1
		is_facing_up = true
		is_facing_right = false
		is_facing_down = false


	if move_x != 0 and move_y != 0:
		move_x = 0
		move_y = 0

	velocity = Vector2(move_x, move_y)

	if Input.is_action_just_pressed("strike") and not is_attacking:
		is_attacking = true
		
		$SwordSwing.play()

		if is_facing_right:
			$AnimatedSprite2D.animation = "Strike Side"
			$AnimatedSprite2D.flip_h = false
		elif is_facing_up:
			$AnimatedSprite2D.animation = "Strike Up"
			$AnimatedSprite2D.flip_h = false
		elif is_facing_down:
			$AnimatedSprite2D.animation = "Strike Down"
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.animation = "Strike Side"
			$AnimatedSprite2D.flip_h = true

		$AnimatedSprite2D.play()

	elif velocity.length() > 0:
		idle_timer = 0.0
		is_idle_playing = false

		velocity = velocity.normalized() * speed
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)

		if not $FootstepSound.playing:
			$FootstepSound.play()

		if velocity.x != 0:
			$AnimatedSprite2D.animation = "Walking Side"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			if velocity.y < 0:
				$AnimatedSprite2D.animation = "Walking Up"
			else:
				$AnimatedSprite2D.animation = "Walking Down"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = false

		$AnimatedSprite2D.play()

	else:
		idle_timer += delta
		if idle_timer >= 1 and not is_idle_playing:
			$AnimatedSprite2D.animation = "Idle"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play()
			is_idle_playing = true
		
		if $FootstepSound.playing:
			$FootstepSound.stop()

	if $AnimatedSprite2D.animation == "Strike Side" or $AnimatedSprite2D.animation == "Strike Up" or $AnimatedSprite2D.animation == "Strike Down":
		is_attacking = false
