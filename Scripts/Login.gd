extends Control

onready var http : HTTPRequest = $HTTPRequest
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
	Firebase.login(email.text, password.text, http)

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var response_body := JSON.parse(body.get_string_from_ascii())
	#print(response_body.result)
	if response_code != 200:
		notification.text = response_body.result.error.message.capitalize()
	else:
		notification.text = "Logowanie przebiegło prawidłowo!"
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://Scenes/Main.tscn")
