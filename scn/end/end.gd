extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	Global.player_health = 100
	Global.gold = 0
	Global.day = 0
	get_tree().change_scene_to_file("res://scn/main/main.tscn")


func _on_home_pressed():
	get_tree().change_scene_to_file("res://scn/menu/start_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()
