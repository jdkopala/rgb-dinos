extends Node2D

@onready var red_blocks = $RedBlocks.get_children()
@onready var green_blocks = $GreenBlocks.get_children()
@onready var blue_blocks = $BlueBlocks.get_children()

@onready var player: Node2D = $"../Player"

func _ready():
	# We will always start on red
	for block in red_blocks:
		enable_block(block)
	for block in green_blocks:
		disable_block(block)
	for block in blue_blocks:
		disable_block(block)
		
func _on_player_child_exiting_tree(_dnode: Node) -> void:
	if player:
		if player.current_color == 0:
			for block in red_blocks:
				disable_block(block)
		if player.current_color == 1:
			for block in green_blocks:
				disable_block(block)
		if player.current_color == 2:
			for block in blue_blocks:
				disable_block(block)

# When the dino is replaced
func _on_player_child_entered_tree(_node: Node) -> void:
	if player:
		# Changed to Red dino
		if player.current_color == 0:
			for block in red_blocks:
				enable_block(block)
		# Changed to Green dino
		if player.current_color == 1:
			for block in green_blocks:
				enable_block(block)
		# Changed to Blue Dino
		if player.current_color == 2:
			for block in blue_blocks:
				enable_block(block)

func disable_block(block: RigidBody2D):
#	Ideally we disable collisions and fade out the blocks opacity a little bit here
	block.get_child(1).disabled = true
	block.get_child(2).play("block_fade_out")
	pass
	
func enable_block(block: RigidBody2D):
	# here we will have 100% opacity and enable collisions
	block.get_child(1).disabled = false
	block.get_child(2).play("block_fade_in")
	pass
