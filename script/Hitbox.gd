class_name  Hitbox
extends Area2D

signal hit(hurtbox)

func  _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurtbox):
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
