extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite

func level_complete_animate():
	sprite.animation = "Crack"
	sprite.animation = "Hatch"
