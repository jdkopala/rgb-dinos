extends Node

@onready var LevelComplete = $LevelComplete
@onready var GameOver = $GameOver

func _ready():
	LevelComplete.visible = false
	GameOver.visible = false
	GameManager.start_game(self)
