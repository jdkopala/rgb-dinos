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
var jump_speed: int = -500

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
		current_character.velocity.y = jump_speed
	var speed
	if Input.is_action_pressed('dash'):
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
	add_child(next_dino)
	current_character = next_dino
	current_color = next_color
