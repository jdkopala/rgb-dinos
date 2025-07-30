extends Control

@onready var audio_stream: AudioStreamPlayer = $AudioStreamPlayer
@onready var game_over_music: AudioStream = preload("res://Assets/Sounds/GameOver.ogg")

func _ready():
	play_audio(game_over_music)

func _on_home_btn_pressed() -> void:
	GameManager.current_level = 0
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_restart_btn_pressed() -> void:
	GameManager.restart_level()

func play_audio(audio: AudioStream):
	audio_stream.stream = audio
	audio_stream.play()
