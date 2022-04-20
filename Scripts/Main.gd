extends Control

func _ready():
	if Database.userID == "":
		$Background/LoginButton.visible = true
		$Background/RegisterButton.visible = true
		$Background/ProfileButton.visible = false
		$Background/FriendsButton.visible = false
		$Background/GroupButton.visible = false
	else:
		$Background/LoginButton.visible = false
		$Background/RegisterButton.visible = false
		$Background/ProfileButton.visible = true
		$Background/FriendsButton.visible = true
		$Background/GroupButton.visible = true	
	pass 

func _on_RegisterButton_pressed():
	get_tree().change_scene("res://Scenes/Register.tscn")

func _on_LoginButton_pressed():
	get_tree().change_scene("res://Scenes/Login.tscn")

func _on_ProfileButton_pressed():
	get_tree().change_scene("res://Scenes/Profile.tscn")

func _on_FriendsButton_pressed():
	get_tree().change_scene("res://Scenes/Friends.tscn")

func _on_GroupButton_pressed():
	get_tree().change_scene("res://Scenes/Groups.tscn")
