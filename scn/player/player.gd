extends CharacterBody2D

enum{
	AIR,
	MOVE,
	ROLL,
	ATTACK1,
	ATTACK2,
	ATTACK3,
	HURT
}
@export var player_attack_num = 200
@export var player_attack2_num = 500
@export var player_attack3_num = 100
const SPEED = 200.0
var roll_speed = 150
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state = MOVE
var combo = false
var attack_cooldown = false
var attacking = false
var invincible = false
var is_recover = false

func _physics_process(delta):
	if(Global.player_health > 0):
		recover(delta)
		player_control(delta)
	if(Global.player_health <= 0):
		$AnimationPlayer.play("die")
		await $AnimationPlayer.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://scn/end/end.tscn")
	move_and_slide()


func player_control(delta):
	if(not is_on_floor()):
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("my_jump") and is_on_floor():
		state = AIR
		$AnimationPlayer.play("jump")
		velocity.y = JUMP_VELOCITY
	if(state != ROLL and Input.is_action_just_pressed("my_roll") and is_on_floor() and Global.player_energy >= 10):
		combo = false
		Global.player_energy -= 10
		state = ROLL
	if !attacking and Input.is_action_just_pressed("my_attack" ) and !attack_cooldown and state != ROLL:
		velocity.x = 0
		state = ATTACK1
		attacking = true
	match state:
		AIR:
			air_state(delta)
		MOVE:
			move_state()
		ROLL:
			roll_state()
		ATTACK1:
			attack1_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		HURT:
			if(is_on_floor() and velocity.y == 0 ):
				state = MOVE


func air_state(delta):
	var h = Input.get_axis('my_left','my_right')
	velocity.x =  h * SPEED;
	if(h != 0) :
		$AnimatedSprite2D.flip_h = h < 0
		$Attack1/Attack.scale.x = abs($Attack1/Attack.scale.x) if h > 0 else 0 - abs($Attack1/Attack.scale.x)
	if(is_on_floor() and velocity.y == 0):
		state = MOVE


func move_state():
	var h = Input.get_axis('my_left','my_right')
	if(h != 0) :
		$AnimatedSprite2D.flip_h = h < 0
		$Attack1/Attack.scale.x = abs($Attack1/Attack.scale.x) if h > 0 else 0 - abs($Attack1/Attack.scale.x)
	velocity.x =  h * SPEED;
	if h!= 0 and velocity.y == 0: 
		$AnimationPlayer.play("run")
	elif velocity == Vector2.ZERO:
		$AnimationPlayer.play("idle")


func roll_state():
	var h = Input.get_axis('my_left','my_right')
	if($AnimatedSprite2D.flip_h):
		velocity.x = 0 - roll_speed
	else:
		velocity.x =  roll_speed
	$".".set_collision_mask_value(3,false)
	$".".set_collision_layer_value(1,false)
	attacking = false
	$AnimationPlayer.play("roll")


func roll_end():
	$".".set_collision_layer_value(1,true)
	$".".set_collision_mask_value(3,true)
	state = MOVE


func attack1_state():
	$AnimationPlayer.play("attack")
	check_combo(0.7)


func attack1_end():
	if(combo):
		state = ATTACK2
		combo = false
	else:
		attack_end()


func attack2_end():
	if(combo):
		state = ATTACK3
		combo = false
	else:
		attack_end()


func attack2_state():
	$AnimationPlayer.play("attack2")
	check_combo(0.6)


func attack3_state():
	$AnimationPlayer.play("attack3")


func attack_end():
	state = MOVE
	combo = false
	attacking = false
	attack_freeze()


func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.1).timeout
	attack_cooldown = false


func check_combo(time):
	var left_time = $AnimationPlayer.current_animation_length - $AnimationPlayer.current_animation_position
	var left_percentage = left_time / $AnimationPlayer.current_animation_length
	if(left_percentage < time and !combo):
		combo = Input.is_action_just_pressed("my_attack") 

func hurt(damage,dir):
	Global.player_health -= damage
	invincible = true
	combo = false
	attacking = false
	$AnimationPlayer.play("hurt")
	velocity = dir * 400
	state = HURT
	


func normal_hurt(damage,dir):
	if(!invincible and Global.player_health > 0):
		hurt(damage,dir)
		await get_tree().create_timer(1).timeout
		invincible = false
		modulate = Color(1,1,1,1)


func _on_attack_body_entered(body):
	if(body.get_collision_layer_value(3)):
		if(state == ATTACK1):
			body.hurt(player_attack_num)
		elif (state == ATTACK2):
			body.hurt(player_attack2_num)
		elif (state == ATTACK3):
			body.hurt(player_attack3_num)


func recover(delta):
	if(Global.player_health < Global.player_max_health):
		Global.player_health += 0.2 * delta
	if(Global.player_energy < Global.player_max_energy):
		Global.player_energy += 5 * delta


