extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var victory_sound: AudioStream = preload("res://Assets/Sounds/Level Up 2 (miniclip).ogg")

func level_complete_animate():
	play_audio(victory_sound)
	sprite.animation = "Hatch"

func play_audio(stream: AudioStream):
	audio.stream = stream
	audio.play()

func _on_sprite_animation_finished() -> void:
	GameManager.show_level_complete_ui()
	pass # Replace with function body.
