class_name UserProfile
extends Node

var FriendCardScene = preload("res://Scenes/FriendCard.tscn")

var Name : String = ""
var Surname : String = ""
var BankAccount : String = ""
var Telephone : String = ""
var Avatar : Image

func saveToDictionary() -> Dictionary:
	return {
		"name":Name,
		"surname":Surname,
		"bank":BankAccount,
		"phone":Telephone
	}

func loadFromDictionary(var profileData : Dictionary):
	Name = profileData["Name"]
	Surname = profileData["Surname"]
	BankAccount = profileData["Bank"]
	Telephone = profileData["Phone"]

func loadAvatar(var image : Image):
	Avatar = image

func createProfileCard() -> MarginContainer:
	var card = FriendCardScene.instance()
	card.get_node("Background/HBoxContainer/VBoxContainer/Name").text = Name
	card.get_node("Background/HBoxContainer/VBoxContainer/Surname").text = Surname
	var avatarTex = ImageTexture.new()
	avatarTex.create_from_image(Avatar)
	card.get_node("Background/HBoxContainer/Avatar").texture = avatarTex
	return card
