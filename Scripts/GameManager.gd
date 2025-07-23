extends Node2D

var current_level: int = 0
var level_scenes = []

var main_scene: Node = null
var current_stage: Node = null
var UI: Node = null

func _ready():
	var dir = DirAccess.open('res://Scenes/Levels')
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				level_scenes.append(load("res://Scenes/Levels/" + file_name))
			file_name = dir.get_next()
	else:
		level_scenes = [
			preload('res://Scenes/Levels/Level1_Tutorial.tscn'),
			preload('res://Scenes/Levels/Level2.tscn'),
			preload('res://Scenes/Levels/Level3.tscn'),
			preload('res://Scenes/Levels/Level4.tscn')
		]
	
func start_game(main_scene_ref: Node):
	main_scene = main_scene_ref
	load_level(current_level)
	
func load_level(level_index: int):
	if current_stage:
		current_stage.queue_free()
		
	if level_index >= level_scenes.size():
		print("All levels completed")
		show_level_complete_ui(true)
		return
	
	current_stage = level_scenes[current_level].instantiate()
	main_scene.call_deferred("add_child", current_stage)

func level_complete():
	var goal = main_scene.get_node('LevelScene').get_node('Goal')
	goal.level_complete_animate()
	
func show_level_complete_ui(game_complete: bool):
	if current_stage:
		current_stage.queue_free()
	var level_complete_scene = load("res://Scenes/LevelComplete.tscn").instantiate()
	UI = level_complete_scene
	main_scene.add_child(level_complete_scene)
	
func start_next_level():
	if UI:
		UI.queue_free()
	current_level += 1
	load_level(current_level)
	
