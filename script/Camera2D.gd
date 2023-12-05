extends Camera2D

@onready var player = $"../Player/Player"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = player.position
	$".".position = pos
