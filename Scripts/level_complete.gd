extends Control

@onready var label = $Label
@onready var nextBtn = $VBoxContainer/NextBtn
@onready var homeBtn = $VBoxContainer/HomeBtn

func _ready():
	if GameManager.current_level >= GameManager.level_scenes.size() - 1:
		label.text = "Thanks for playing!"
		nextBtn.disabled = true
	# TODO: Play victory music from assets
	pass
	
func _on_next_btn_pressed() -> void:
	GameManager.start_next_level()

func _on_home_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
