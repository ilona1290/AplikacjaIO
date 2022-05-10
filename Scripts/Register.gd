extends Control

onready var registerEmail : LineEdit = $Background/RegisterForm/Email/EmailInput
onready var registerPassword : LineEdit = $Background/RegisterForm/Password/PasswordInput
onready var registerConfirm : LineEdit = $Background/RegisterForm/ConfirmPassword/ConfirmPasswordInput
onready var notification : RichTextLabel = $Background/Notification

func _ready():
	pass

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_RegisterButton_pressed() -> void:
	if registerPassword.text != registerConfirm.text:
		notification.text = "Hasła nie są identyczne"
		return
	elif registerEmail.text.empty() or registerPassword.text.empty():
		notification.text = "Nieprawidłowy e-mail lub hasło"
		return
	yield(Database.register(registerEmail.text, registerPassword.text), "completed")
	get_tree().change_scene("res://Scenes/Login.tscn")
	
