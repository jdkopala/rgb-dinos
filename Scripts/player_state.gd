extends Node

@onready var red_dino: PackedScene = preload('res://Scenes/Dinos/red_dino.tscn')
@onready var blue_dino: PackedScene = preload('res://Scenes/Dinos/blue_dino.tscn')
@onready var green_dino: PackedScene = preload('res://Scenes/Dinos/green_dino.tscn')
var dinos: Array[PackedScene]

@export_enum('red', 'green', 'blue') var current_color: int = 0
enum CurrentColor {red, green, blue}

var current_character: Area2D

func _ready():
	current_character = red_dino.instantiate()
	$Character.add_child(current_character)
	dinos.append(red_dino)
	dinos.append(green_dino)
	dinos.append(blue_dino)
	
func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_E):
		toggle_dino_color()
		
	if Input.is_physical_key_pressed(KEY_W):
		pass
	if Input.is_physical_key_pressed(KEY_A):
		pass
	if Input.is_physical_key_pressed(KEY_S):
		pass
	if Input.is_physical_key_pressed(KEY_D):
		pass
	
func toggle_dino_color():
	var next_color = current_color + 1
	if next_color > 2:
		next_color = 0
	$Character.remove_child(current_character)
	var next_dino = dinos[next_color].instantiate()
	$Character.call_deferred("add_child", next_dino)
	current_character = next_dino
	current_color = next_color
