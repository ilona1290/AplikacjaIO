extends Control


func _ready():
	print("Register scene")
	pass


func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
	pass # Replace with function body.
