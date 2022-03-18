extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_registerButton_pressed():
	get_tree().change_scene("res://Scenes/register.tscn")
	pass # Replace with function body.


func _on_loginButton_pressed():
	get_tree().change_scene("res://Scenes/login.tscn")
	pass # Replace with function body.


func _on_profileButton_pressed():
	get_tree().change_scene("res://Scenes/profile.tscn")
	pass # Replace with function body.
