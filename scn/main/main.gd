extends Node2D

var is_esc = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("11")
	if(Input.is_action_just_pressed("my_esc")):
		print("按了")
		is_esc = !is_esc
		if(is_esc):
			print("开启")
			get_tree().paused = true
			$Pause_menu.show()
		else:
			print("关闭")
			get_tree().paused = false
			$Pause_menu.hide()

