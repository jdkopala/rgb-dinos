extends Node

enum DinoColor { RED, GREEN, BLUE }
@export_enum("RED", "GREEN", "BLUE") 
var current_color: int = DinoColor.RED
var previous_color: int = DinoColor.RED
@onready var dino_scenes = {
	DinoColor.RED: preload('res://Scenes/Dinos/red_dino.tscn'),
	DinoColor.GREEN: preload('res://Scenes/Dinos/green_dino.tscn'),
	DinoColor.BLUE: preload('res://Scenes/Dinos/blue_dino.tscn')
}

@onready var camera: Camera2D = $Camera2D
var current_character: CharacterBody2D
var player_audio_stream: AudioStreamPlayer2D

@onready var jump_sound: AudioStream = preload("res://Assets/Sounds/Jump_6.wav")
@onready var die_sound: AudioStream = preload("res://Assets/Sounds/Hit_long.wav")
@onready var dash_sound: AudioStream = preload("res://Assets/Sounds/Laser_4.wav")
@onready var toggle_color_sound: AudioStream = preload("res://Assets/Sounds/color_change.wav")

var gravity: float = 980
@export var walk_speed: int = 250
@export var run_speed: int = 350
@export_range(0, 1) var deceleration = 0.6

var jump_force: int = -500
@export_range(0, 1) var decelerate_on_jump_release = 0.3

@export var dash_speed: float = 1000.0
@export var dash_max_distance: float = 60.0
@export var dash_curve: Curve
@export var dash_cooldown: float = 0.8
var is_dashing: bool = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

# need this because of the character swaps to maintain the facing state
var flip_sprite: bool = false
var is_dead: bool = false
# prevents the die sound from playing twice in _physics_process
var played_die_sound: bool = false
var freeze_controls: bool = false

func _ready():
	current_character = dino_scenes[DinoColor.RED].instantiate()
	player_audio_stream = current_character.get_node("AudioStreamPlayer")
	player_audio_stream.connect("finished", on_audio_finished)
	add_child(current_character)
	# TODO: Remove this camera offset if it sucks when levels start to come together
	camera.global_position.y = clamp(camera.global_position.y, -100000, 340)
	
func _physics_process(delta: float) -> void:
	var sprite = current_character.get_node("AnimatedSprite2D")
	
	if !freeze_controls:
		# if the character falls off the screend
		if current_character.global_position.y > 750:
			is_dead = true
		
		if current_character:
			var target_position = current_character.global_position
			# TODO: Remove this camera offset if it sucks when levels start to come together
			target_position.y = clamp(target_position.y, -100000, 340)
			camera.global_position = camera.global_position.lerp(target_position, camera.position_smoothing_speed * delta)
		
		if not current_character.is_on_floor():
			current_character.velocity.y += gravity * delta
			
		if Input.is_action_just_pressed('toggle_color'):
			toggle_dino_color()
			
		if Input.is_action_just_pressed("jump") and current_character.is_on_floor():
			set_animation('Jump')
			play_audio(jump_sound)
			current_character.velocity.y = jump_force
		if Input.is_action_just_released("jump") and current_character.velocity.y < 0:
			current_character.velocity.y *= decelerate_on_jump_release
		
		var speed
		if Input.is_action_pressed('run'):
			speed = run_speed
		else:
			speed = walk_speed
		
		var direction = Input.get_axis("left", "right")
		if direction:
			if direction < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			if speed == run_speed:
				set_animation('Dash')
			else:
				set_animation('Walk')
			current_character.velocity.x = direction * speed
		else:
			set_animation('Idle')
			current_character.velocity.x = move_toward(current_character.velocity.x, 0, walk_speed * deceleration)
			
		if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
			is_dashing = true
			dash_start_position = current_character.position.x
			dash_direction = direction
			dash_timer = dash_cooldown
		
		if is_dashing:
			var current_distance = abs(current_character.position.x - dash_start_position)
			if current_distance >= dash_max_distance or current_character.is_on_wall():
				is_dashing = false
			else:
				set_animation("Dash")
				play_audio(dash_sound)
				current_character.velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
				current_character.velocity.y = 0
		
		if dash_timer > 0:
			dash_timer -= delta
	elif freeze_controls and !is_dead:
		current_character.velocity = Vector2(0,0)
		set_animation('Idle')
		
	if is_dead:
		GameManager.stop_audio()
		current_character.velocity = Vector2(0,0)
		freeze_controls = true
		set_animation('Die')
		if (!played_die_sound):
			played_die_sound = true
			play_audio(die_sound)
		
	current_character.move_and_slide()
	flip_sprite = sprite.flip_h
	
func toggle_dino_color():
	# TODO: Add a sound for changing dino color
	previous_color = current_color
	current_color = (current_color + 1) % len(dino_scenes)
	
	remove_child(current_character)
	var next_dino = dino_scenes[current_color].instantiate()
	next_dino.get_node("AnimatedSprite2D").flip_h = flip_sprite
	next_dino.position = current_character.position
	current_character = next_dino
	player_audio_stream = current_character.get_node("AudioStreamPlayer")
	add_child(next_dino)
	play_audio(toggle_color_sound)
	
func set_animation(animation: String) -> void:
	var sprite = current_character.get_node("AnimatedSprite2D")
	if sprite.animation != animation:
		sprite.animation = animation
		
func play_audio(audio: AudioStream):
	if player_audio_stream.stream != audio or not player_audio_stream.playing:
		player_audio_stream.stream = audio
		player_audio_stream.play()
		
func on_audio_finished():
	player_audio_stream.stream = null

func _on_goal_body_entered(body: Node2D) -> void:
	if body.is_in_group("Dino"):
		freeze_controls = true
		GameManager.level_complete()

func _on_hazard_body_entered(body: Node2D) -> void:
	if body.is_in_group("Dino"):
		is_dead = true
