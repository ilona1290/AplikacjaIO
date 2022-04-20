extends Control

onready var email : LineEdit = $Background/Form/Email/EmailInput
onready var password : LineEdit = $Background/Form/Password/PasswordInput
onready var notification : RichTextLabel = $Background/Notification

func _ready():
	pass

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_LoginButton_pressed():
	if email.text.empty() or password.text.empty():
		notification.text = "Nieprawidłowy e-mail lub hasło"
		return
	yield(Database.login(email.text, password.text), "completed")
	yield(get_tree().create_timer(2.0), "timeout")
	get_tree().change_scene("res://Scenes/Main.tscn")
