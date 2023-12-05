extends CharacterBody2D
@onready var player = $"../../Player/Player"
@onready var emeny_sprite = $Enemy
@export var chase_speed: int = 150
@export var walk_speed: int = 50
@export var nomal_attack = 10
@export var health = 100
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gold = preload("res://scn/gold/gold.tscn")
var isAlive = true
var state = IDLE
var attack_cool = false
var is_hurt = false
var patrol_range = []
enum{
	IDLE,
	ATTACK,
	PATROL,
	CHASE,
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if(isAlive):
		match state:
			IDLE:
				if(!attack_cool and !is_hurt):
					velocity.x = 0
					$AnimationPlayer.play('idle')
					if(!has_node("b")):
						var timer = Timer.new();
						timer.name = "b"
						add_child(timer)
						timer.one_shot = true
						timer.wait_time = 2
						timer.timeout.connect(enter_patrol)
						timer.start()
			ATTACK:
				remove_timer()
				if(!attack_cool and !is_hurt):
					velocity.x = 0
					var dir = (  player.position - position ).normalized()
					if dir.x < 0 :
						emeny_sprite.flip_h = true
						$Attack.scale.x =  absf(scale.x)
					elif  dir.x > 0 :
						$Attack.scale.x = 0 - absf(scale.x)
						emeny_sprite.flip_h = false
					$AnimationPlayer.play("attack")
					attack_cool = true
			PATROL:
					$AnimationPlayer.play('walk')
					partol()
			CHASE:
				remove_timer()
				if(!attack_cool and !is_hurt):
					var dir = (  player.position - position ).normalized()
					velocity.x = dir.x * chase_speed
					$AnimationPlayer.play('run')
					if velocity.x < 0 :
						emeny_sprite.flip_h = true
						$Attack.scale.x = absf(scale.x)
					elif  velocity.x > 0 :
						$Attack.scale.x = 0 - absf(scale.x)
						emeny_sprite.flip_h = false
	move_and_slide()


func _on_chase_detector_body_entered(body):
	if body.name == 'Player':
		state = CHASE


func _on_chase_detector_body_exited(body):
	if body.name == 'Player':
		state = IDLE


func _on_hit_detector_body_entered(body):
	if body.name == 'Player':
		death()


func death():
	isAlive = false
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_attack_range_body_entered(body):
	if body.name == 'Player':
		state = ATTACK


func attack_end():
	await get_tree().create_timer(0.5).timeout
	attack_cool = false


func _on_attack_range_body_exited(body):
	if body.name == 'Player':
		state = CHASE


func _on_damage_range_body_entered(body):
	if body.name == 'Player' && isAlive:
		var dir = body.position - position
		body.normal_hurt(nomal_attack,dir.normalized())


func remove_timer():
	if(has_node("b")):
		var timer = find_child("b",false,false)
		remove_child(timer)


func enter_patrol():
	emeny_sprite.flip_h = !emeny_sprite.flip_h
	if(!emeny_sprite.flip_h):
		patrol_range = [position.x ,position.x + walk_speed * 5 ]
	else:
		patrol_range = [position.x - walk_speed * 5 ,position.x  ]
		if(patrol_range[0] <= 100):
			patrol_range = [100 ,100 + walk_speed * 5  ]
	$Attack.scale.x = 0 - scale.x
	state = PATROL
	var timer = find_child("b",false,false)
	remove_child(timer)


func partol():
	if(!emeny_sprite.flip_h):
		velocity.x =  walk_speed
	else:
		velocity.x = 0 - walk_speed
	var is_turn =  position.x >= patrol_range[1] and !emeny_sprite.flip_h  or position.x <= patrol_range[0] and emeny_sprite.flip_h
	if is_turn :
		emeny_sprite.flip_h = !emeny_sprite.flip_h
		$Attack.scale.x = 0 - scale.x


func hurt(damage):
	health -= damage
	remove_timer()
	if(health <= 0):
		isAlive = false
		var new_health = Global.player_health + 5
		Global.player_health = new_health if new_health <= Global.player_max_health else  Global.player_max_health
		$AnimationPlayer.play("die")
		$".".set_collision_mask_value(1,false)
		$".".set_collision_layer_value(3,false)
		var goldTemp = gold.instantiate()
		goldTemp.position = position
		var main = get_node("/root/Main/prop")
		main.add_child(goldTemp)
		goldTemp.owner = main
		await  $AnimationPlayer.animation_finished
		queue_free()
		return
	if(is_hurt):
		$AnimationPlayer.stop()
	$AnimationPlayer.play("hurt")
	attack_cool = false
	is_hurt = true
	$Attack/Normal/AttackRange/CollisionShape2D.disabled = true
	$ChaseDetector/CollisionShape2D.disabled = true


func hurt_end():
	is_hurt = false
	$ChaseDetector/CollisionShape2D.disabled = false
	$Attack/Normal/AttackRange/CollisionShape2D.disabled = false
	
