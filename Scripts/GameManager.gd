extends Node2D

var current_level: int = 0
var level_scenes = []
var level_completed: bool
var level_started: bool

var main_scene: Node = null
var current_stage: Node = null

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
			preload('res://Scenes/Levels/Level0_Tutorial.tscn'),
			preload('res://Scenes/Levels/Level1.tscn'),
			preload('res://Scenes/Levels/Level2.tscn'),
			preload('res://Scenes/Levels/Level3.tscn')
		]
	
func start_game(main_scene_ref: Node):
	main_scene = main_scene_ref
	current_level = 0
	load_level(current_level)
	
func load_level(level_index: int):
	if current_stage:
		current_stage.queue_free()
		
	if level_index >= level_scenes.size():
		print("All levels completed")
		return
	
	current_stage = level_scenes[current_level].instantiate()
	main_scene.call_deferred("add_child", current_stage)

func level_complete():
	#TODO: Trigger animation, level up sound etc.
	#TODO: Add victory music while the LevelComplete UI is showing
	#goal.level_complete_animate()
	current_level += 1
	load_level(current_level)
	pass
	
