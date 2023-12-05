extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if(not is_on_floor()):
		velocity.y += gravity * delta
	move_and_slide()

func _on_area_body_entered(body):
	if(body.name == 'Player'):
		$Music.play()
		var tween = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween.tween_property(self,'position',position - Vector2(0,25),0.3)
		tween2.tween_property(self,'modulate:a',0,0.3)
		Global.gold += 1 
		await get_tree().create_timer(1.3).timeout
		queue_free()
