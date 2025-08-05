extends Node2D

var current_level: int = 0
var level_scenes = []
var completed_levels: Array[int] = []

var main_scene: Node = null
var audio_stream: AudioStreamPlayer = null
var current_stage: Node = null
var UI: Node = null

@onready var level_music: AudioStream = preload("res://Assets/Sounds/Puzzles.ogg")

func _ready():
	var dir = DirAccess.open('res://Scenes/Levels')
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# This is added to scene files when exported - best practice is to strip it out in these situations
			if file_name.ends_with(".remap"):
				file_name = file_name.split('.remap')[0]
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
	audio_stream = main_scene.get_node("AudioStreamPlayer")
	load_level(current_level)
	
func load_level(level_index: int):
	if current_stage:
		current_stage.queue_free()
		
	if level_index >= level_scenes.size():
		show_level_complete_ui()
		return
	
	current_stage = level_scenes[current_level].instantiate()
	main_scene.call_deferred("add_child", current_stage)
	play_audio(level_music)

func level_complete():
	stop_audio()
	#TODO: Create Level Select
	if !completed_levels.find(current_level, 0):
		completed_levels.append(current_level)
	var goal = main_scene.get_node('LevelScene').get_node('Goal')
	goal.level_complete_animate()
	
func show_level_complete_ui():
	stop_audio()
	if current_stage:
		current_stage.queue_free()
	var level_complete_scene = load("res://Scenes/LevelComplete.tscn").instantiate()
	UI = level_complete_scene
	main_scene.add_child(UI)
	
func show_game_over_ui():
	stop_audio()
	if current_stage:
		current_stage.queue_free()
	var game_over_scene = load('res://Scenes/GameOver.tscn').instantiate()
	UI = game_over_scene
	main_scene.add_child(UI)
	
func restart_level():
	if UI:
		UI.queue_free()
	load_level(current_level)
	
func start_next_level():
	if UI:
		UI.queue_free()
	current_level += 1
	load_level(current_level)
	
func play_audio(audio: AudioStream):
	audio_stream.stream = audio
	audio_stream.play()
	
func stop_audio():
	if audio_stream:
		audio_stream.stop()
