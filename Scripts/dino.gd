extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == 'Die':
		GameManager.show_game_over_ui()
