extends Node2D

var gold = preload("res://scn/gold/gold.tscn")

func _on_timer_timeout():
	var num = find_children("","Area2D",false).size()
	if(num < 5) :
		var goldTemp = gold.instantiate()
		var rng = RandomNumberGenerator.new()
		var x = rng.randf_range(50,500)
		goldTemp.position = Vector2(x,475)
		add_child(goldTemp)
		goldTemp.owner = owner
	
