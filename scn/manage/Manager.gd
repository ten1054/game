extends Node

var is_esc = false
const save_dir = "user://saves/"
var file_path = save_dir + "savegame.dat"
# Called when the node enters the scene tree for the first time.
func _ready():
	$"../Pause_menu".hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("my_esc")):
		is_esc = !is_esc
		if(is_esc):
			get_tree().paused = true
			$"../Pause_menu".show()
		else:
			get_tree().paused = false
			$"../Pause_menu".hide()



func _on_menu_pressed():
	print("主页")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scn/menu/start_menu.tscn")


func _on_continue_pressed():
	print("继续")
	get_tree().paused = false
	is_esc = !is_esc
	$"../Pause_menu".hide()


func _on_quit_pressed():
	print("退出")
	get_tree().quit()


func _on_save_pressed():
	if(!DirAccess.dir_exists_absolute(save_dir)):
		DirAccess.make_dir_recursive_absolute(save_dir)
	var file = FileAccess.open(file_path,FileAccess.WRITE)
	if(file):
		var data = {
			"player_max_health" : Global.player_max_health,
 			"player_health" : Global.player_health,
			"player_energy" : Global.player_energy,
 			"player_max_energy" : Global.player_max_energy,
 			"gold" : Global.gold,
			"day" : Global.day
		}
		print(data)
		file.store_var(data)
	file.close()

func _on_load_pressed():
	var file = FileAccess.open(file_path,FileAccess.READ)
	var data = file.get_var()
	file.close()
	print(data)
	for key in data:
		print(key,data[key])
		Global[key] = data[key]
	get_tree().paused = false
	$"../Pause_menu".hide()
	is_esc = !is_esc
