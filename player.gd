extends Area2D

@export var speed = 400
var screen_size
var idle_timer = 0.0
var is_idle_playing = false
var is_attacking = false  # Track if the player is currently attacking
var is_facing_right = true  # Track the direction the player is facing (default to right)
var is_facing_up = false  # Track if the player is facing up
var is_facing_down = false  # Track if the player is facing down

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):

	var velocity = Vector2.ZERO

	# Gather input
	var move_x = 0
	var move_y = 0
	if Input.is_action_pressed("move_right"):
		move_x += 1
		is_facing_right = true  # Player is facing right
		is_facing_up = false
		is_facing_down = false
	if Input.is_action_pressed("move_left"):
		move_x -= 1
		is_facing_right = false  # Player is facing left
		is_facing_up = false
		is_facing_down = false
	if Input.is_action_pressed("move_down"):
		move_y += 1
		is_facing_down = true  # Player is facing down
		is_facing_right = false
		is_facing_up = false
	if Input.is_action_pressed("move_up"):
		move_y -= 1
		is_facing_up = true  # Player is facing up
		is_facing_right = false
		is_facing_down = false

	# Block diagonal movement
	if move_x != 0 and move_y != 0:
		move_x = 0
		move_y = 0

	velocity = Vector2(move_x, move_y)

	# Check for strike input, only if not already attacking
	if Input.is_action_just_pressed("strike") and not is_attacking:
		is_attacking = true  # Start attacking
		
		$SwordSwing.play()

		# Use the player's facing direction to decide the attack animation
		if is_facing_right:
			$AnimatedSprite2D.animation = "Strike Side"
			$AnimatedSprite2D.flip_h = false  # No flip (strike right)
		elif is_facing_up:
			$AnimatedSprite2D.animation = "Strike Up"
			$AnimatedSprite2D.flip_h = false  # No flip (strike up)
		elif is_facing_down:
			$AnimatedSprite2D.animation = "Strike Down"
			$AnimatedSprite2D.flip_h = false  # No flip (strike down)
		else:
			# If the player is facing left
			$AnimatedSprite2D.animation = "Strike Side"
			$AnimatedSprite2D.flip_h = true   # Flip sprite (strike left)

		$AnimatedSprite2D.play()  # Play the strike animation (once)

	elif velocity.length() > 0:
		idle_timer = 0.0
		is_idle_playing = false

		velocity = velocity.normalized() * speed
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)

		# Set walking animations
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

	# Reset attacking state after animation finishes
	if $AnimatedSprite2D.animation == "Strike Side" or $AnimatedSprite2D.animation == "Strike Up" or $AnimatedSprite2D.animation == "Strike Down":
		is_attacking = false
