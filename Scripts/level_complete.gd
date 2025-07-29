extends Control

@onready var label = $Label
# TODO: Solve the error caused by this button being absent from GameOver screen
@onready var nextBtn = $VBoxContainer/NextBtn
@onready var victory_music = preload("res://Assets/Sounds/Victory.ogg")

func _ready():
	if GameManager.current_level >= GameManager.level_scenes.size() - 1:
		label.text = "Thanks for playing!"
		if nextBtn:
			nextBtn.disabled = true
	GameManager.play_audio(victory_music)
	pass
	
func _on_next_btn_pressed() -> void:
	GameManager.start_next_level()

func _on_home_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_restart_btn_pressed() -> void:
	GameManager.restart_level()
