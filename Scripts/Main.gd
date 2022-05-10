extends Control

onready var loginEmail : LineEdit = $Background/LoginForm/Email/EmailInput
onready var loginPassword : LineEdit = $Background/LoginForm/Password/PasswordInput

onready var registerEmail : LineEdit = $Background/RegisterForm/Email/EmailInput
onready var registerPassword : LineEdit = $Background/RegisterForm/Password/PasswordInput
onready var registerConfirm : LineEdit = $Background/RegisterForm/ConfirmPassword/ConfirmPasswordInput

func _ready():
	if Database.userID == "":
		$Background/LoginForm.visible = true
		$Background/LoginButton.visible = true
		$Background/RegisterForm.visible = true
		$Background/RegisterButton.visible = true
		$Background/ProfileButton.visible = false
		$Background/FriendsButton.visible = false
		$Background/GroupButton.visible = false
		$Background/NotificationButton.visible = false
		$Background/LogoutButton.visible = false
	else:
		$Background/LoginForm.visible = false
		$Background/LoginButton.visible = false
		$Background/RegisterForm.visible = false
		$Background/RegisterButton.visible = false
		$Background/ProfileButton.visible = true
		$Background/FriendsButton.visible = true
		$Background/GroupButton.visible = true
		$Background/NotificationButton.visible = true
		$Background/LogoutButton.visible = true
		$Background/Label.visible = true
		$AnimationPlayer.play("New Anim")

func _on_RegisterButton_pressed():
	if registerPassword.text != registerConfirm.text:
		#notification.text = "Hasła nie są identyczne"
		return
	elif registerEmail.text.empty() or registerPassword.text.empty():
		#notification.text = "Nieprawidłowy e-mail lub hasło"
		return
	yield(Database.register(registerEmail.text, registerPassword.text), "completed")
	get_tree().change_scene("res://Scenes/Login.tscn")

func _on_LoginButton_pressed():
	if loginEmail.text.empty() or loginPassword.text.empty():
		#notification.text = "Nieprawidłowy e-mail lub hasło"
		return
	yield(Database.login(loginEmail.text, loginPassword.text), "completed")
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_ProfileButton_pressed():
	get_tree().change_scene("res://Scenes/Profile.tscn")

func _on_FriendsButton_pressed():
	get_tree().change_scene("res://Scenes/Friends.tscn")

func _on_GroupButton_pressed():
	get_tree().change_scene("res://Scenes/Groups.tscn")

func _on_LogoutButton_pressed():
	Database.userID = ""
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_NotificationButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Notifications.tscn")
