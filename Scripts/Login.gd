extends Control

onready var email : LineEdit = $Background/Form/Email/EmailInput
onready var password : LineEdit = $Background/Form/Password/PasswordInput
onready var notification : RichTextLabel = $Background/Notification

func _ready():
	pass

func _on_LoginButton_pressed():

