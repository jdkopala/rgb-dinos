extends Node

@onready var red_dino: PackedScene = preload('res://Scenes/Dinos/red_dino.tscn')
@onready var blue_dino: PackedScene = preload('res://Scenes/Dinos/blue_dino.tscn')
@onready var green_dino: PackedScene = preload('res://Scenes/Dinos/green_dino.tscn')
var dinos: Array[PackedScene]

@export_enum('red', 'green', 'blue') var current_color: int = 0
enum CurrentColor {red, green, blue}

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
@export var dash_cooldown: float = 1.0

var is_dashing: bool = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0
# need this because of the character swaps to maintain the facing state
var flip_sprite: bool = false

func _ready():
	current_character = red_dino.instantiate()
	add_child(current_character)
	dinos.append(red_dino)
	dinos.append(green_dino)
	dinos.append(blue_dino)
	
func _physics_process(delta: float) -> void:
	if not current_character.is_on_floor():
		current_character.velocity.y += gravity * delta
		
	var sprite = current_character.get_child(0)
	if Input.is_action_just_pressed('toggle_color'):
		toggle_dino_color()
		
	if Input.is_action_just_pressed("jump") and current_character.is_on_floor():
		sprite.animation = 'Jump'
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
			sprite.animation = 'Dash'
		else:
			sprite.animation = 'Walk'
		current_character.velocity.x = direction * speed
	else:
		sprite.animation = 'Idle'
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
			sprite.animation = "Dash"
			current_character.velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			current_character.velocity.y = 0
	
	if dash_timer > 0:
		dash_timer -= delta
	
	current_character.move_and_slide()
	flip_sprite = sprite.flip_h
	
func toggle_dino_color():
	var next_color = current_color + 1
	if next_color > 2:
		next_color = 0
	remove_child(current_character)
	var next_dino = dinos[next_color].instantiate()
	next_dino.get_child(0).flip_h = flip_sprite
	next_dino.position = current_character.position
	current_color = next_color
	current_character = next_dino
	add_child(next_dino)
