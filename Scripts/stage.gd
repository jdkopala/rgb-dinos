extends Node2D

@onready var red_blocks = $RedBlocks.get_children()
@onready var green_blocks = $GreenBlocks.get_children()
@onready var blue_blocks = $BlueBlocks.get_children()

@onready var block_groups = {
	0: $RedBlocks.get_children(),
	1: $GreenBlocks.get_children(),
	2: $BlueBlocks.get_children()
}

@onready var player: Node2D = $"../Player"

func _ready():
	# We will always start on red
	for block in block_groups[0]:
		enable_block(block)
	for block in block_groups[1]:
		disable_block(block)
	for block in block_groups[2]:
		disable_block(block)
		
# When the current dino is removed
func _on_player_child_exiting_tree(_dnode: Node) -> void:
	for block in block_groups[player.previous_color]:
		disable_block(block)

# When the dino is replaced
func _on_player_child_entered_tree(_node: Node) -> void:
	if player:
		for block in block_groups[player.current_color]:
			enable_block(block)

func disable_block(block: RigidBody2D):
	# Disable collision box
	block.get_child(1).disabled = true
	# Animate block fade out
	block.get_child(2).play("block_fade_out")
	pass
	
func enable_block(block: RigidBody2D):
	# Enable the collision box
	block.get_child(1).disabled = false
	# Animate block fade in
	block.get_child(2).play("block_fade_in")
	pass
