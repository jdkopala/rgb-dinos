extends Node

enum DinoColor { RED, GREEN, BLUE }
@export_enum("RED", "GREEN", "BLUE") var current_color: int = DinoColor.RED
var previous_color: int = DinoColor.RED
@onready var dino_scenes = {
	DinoColor.RED: preload('res://Scenes/Dinos/red_dino.tscn'),
	DinoColor.GREEN: preload('res://Scenes/Dinos/green_dino.tscn'),
	DinoColor.BLUE: preload('res://Scenes/Dinos/blue_dino.tscn')
}

@onready var camera: Camera2D = $Camera2D
var current_character: CharacterBody2D

var gravity: float = 980
@export var walk_speed: int = 250
@export var run_speed: int = 350
@export_range(0, 1) var deceleration = 0.6

var jump_force: int = -500
@export_range(0, 1) var decelerate_on_jump_release = 0.3

@export var dash_speed: float = 1200.0
@export var dash_max_distance: float = 60.0
@export var dash_curve: Curve
@export var dash_cooldown: float = 0.8
var is_dashing: bool = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

# need this because of the character swaps to maintain the facing state
var flip_sprite: bool = false
var freeze_controls: bool = false

func _ready():
	current_character = dino_scenes[DinoColor.RED].instantiate()
	add_child(current_character)
	
func _physics_process(delta: float) -> void:
	var sprite = current_character.get_node("AnimatedSprite2D")
	
	if !freeze_controls:
		if current_character:
			var target_position = current_character.global_position
			camera.global_position = camera.global_position.lerp(target_position, camera.position_smoothing_speed * delta)
		
		if not current_character.is_on_floor():
			current_character.velocity.y += gravity * delta
			
		if Input.is_action_just_pressed('toggle_color'):
			toggle_dino_color()
			
		if Input.is_action_just_pressed("jump") and current_character.is_on_floor():
			set_animation('Jump')
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
				current_character.velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
				current_character.velocity.y = 0
		
		if dash_timer > 0:
			dash_timer -= delta
	else:
		current_character.velocity = Vector2(0,0)
		set_animation('Idle')
		
	current_character.move_and_slide()
	flip_sprite = sprite.flip_h
	
func toggle_dino_color():
	previous_color = current_color
	current_color = (current_color + 1) % len(dino_scenes)
	
	remove_child(current_character)
	var next_dino = dino_scenes[current_color].instantiate()
	next_dino.get_child(0).flip_h = flip_sprite
	next_dino.position = current_character.position
	current_character = next_dino
	add_child(next_dino)
	
func set_animation(animation: String) -> void:
	var sprite = current_character.get_node("AnimatedSprite2D")
	if sprite.animation != animation:
		sprite.animation = animation

func _on_goal_body_entered(body: Node2D) -> void:
	if body.is_in_group("Dino"):
		freeze_controls = true
		GameManager.level_complete()

func _on_spikes_body_entered(body: Node2D) -> void:
	if body.is_in_group("Dino"):
		print('Touched the spikes, you die now')
		#TODO: Kill the player, add death animation/sound/game over screen
		pass # Replace with function body.
