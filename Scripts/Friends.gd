extends Control

var friendCardScene = preload("res://Scenes/FriendCard.tscn")

onready var PatternInput = $Background/HBoxContainer/PatternInput
onready var Notification = $Background/Notification
onready var UserList = $Background/ScrollContainer/VBoxContainer

var Friends : Array = []
var SearchList : Array = []
var SelectedCard  = "0"

func _ready():
	Friends = yield(Database.getUserFriends(Database.userID), "completed").Result
	print(Friends)

func generateSearchList():
	for i in UserList.get_children():
		i.queue_free()
	var userProfile = UserProfile.new()
	var allFriendsProfiles = yield(Database.getProfiles(SearchList), "completed").Result
	for user in SearchList:
		if !Friends.has(user) and user != Database.userID:
			userProfile.loadFromDictionary(allFriendsProfiles[user])
			userProfile.loadAvatar(yield(Database.getAvatar(user), "completed"))
			var tmpUserCard = userProfile.createProfileCard()
			tmpUserCard.get_node("Background").connect("gui_input", self, "_onPressFriendCard", [user])
			tmpUserCard.name = user
			UserList.add_child(tmpUserCard)
	
func _onPressFriendCard(event, id):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if SelectedCard == "0":
					$Background/AddButton.visible = true
				else:
					UserList.get_node(SelectedCard).modulate = Color("#ffffff")
				SelectedCard = id
				UserList.get_node(id).modulate = Color("#aaaaaa")

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_FindButton_pressed():
	SearchList = yield(Database.searchForUsers(PatternInput.text), "completed").Result
	generateSearchList()

func _on_AddButton_pressed() -> void:
	$Background/AddButton.visible = false
	yield(Database.addFriend(SelectedCard), "completed")
	UserList.get_node(SelectedCard).queue_free()
	SelectedCard = "0"
	Notification.text = "Wysłano zaproszenie"
