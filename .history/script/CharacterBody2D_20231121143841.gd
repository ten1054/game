extends CharacterBody2D


const SPEED = 6000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var horizontal = Input.get_axis("my_left",'my_right')
	var vertical = Input.get_axis('my_up','my_bottom')
	var dir = Vector2(horizontal,vertical).normalized()
	if(horizontal < 0):
		transform.scale.x = -1
	elif(horizontal > 0)
		transform.scale.x = 1
	velocity = dir * delta * SPEED
	animation_handler()
	move_and_slide()

func animation_handler():
	if(velocity.x == 0 || velocity.y == 0):
		$AnimationPlayer.play("default")
