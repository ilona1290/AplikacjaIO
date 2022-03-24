extends Control

onready var http : HTTPRequest = $HTTPRequest
onready var email : LineEdit = $Background/Form/Email/EmailInput
onready var password : LineEdit = $Background/Form/Password/PasswordInput
onready var confirm : LineEdit = $Background/Form/ConfirmPassword/ConfirmPasswordInput
onready var notification : RichTextLabel = $Background/Notification

func _ready():
	pass


func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		notification.text = response_body.result.error.message.capitalize()
	else:
		notification.text = "Rejestracja przebiegła prawidłowo!"
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://Scenes/Login.tscn")


func _on_RegisterButton_pressed() -> void:
	if password.text != confirm.text:
		notification.text = "Hasła nie są identyczne"
		return
	elif email.text.empty() or password.text.empty():
		notification.text = "Nieprawidłowy e-mail lub hasło"
		return
	Firebase.register(email.text, password.text, http)
