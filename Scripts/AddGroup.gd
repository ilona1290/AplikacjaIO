extends Control

var friendCardScene = preload("res://Scenes/FriendCard.tscn")

onready var NameInput = $Background/NameInput 
onready var Notification = $Background/Notification

onready var FriendList = $PanelContainer/ScrollContainer/VBoxContainer

var FriendsToShow : Array = []
var NewGroupFriends : Array = []

func _ready():
	FriendsToShow = yield(Database.getUserFriends(Database.userID), "completed").Result
	generateFriendList()

func generateFriendList():
	var FriendProfile = UserProfile.new()
	var allFriendsProfiles = yield(Database.getProfiles(FriendsToShow), "completed").Result
	for f in FriendsToShow:
		FriendProfile.loadFromDictionary(allFriendsProfiles[f])
		FriendProfile.loadAvatar(yield(Database.getAvatar(f), "completed"))
		var tmpFriendCard = FriendProfile.createProfileCard()
		tmpFriendCard.name = f
		tmpFriendCard.get_node("Background").connect("gui_input", self, "_onPressFriendCard", [f])
		FriendList.add_child(tmpFriendCard)

func _on_AddGroupButton_pressed():
	# Visual deselecting cards
	for card in NewGroupFriends:
		FriendList.get_node(card).modulate = Color("#ffffff")
	
	NewGroupFriends.append(Database.userID)
	yield(Database.createNewGroup(NameInput.text, NewGroupFriends), "completed")
	NameInput.text = ""
	NewGroupFriends.clear()


###################################
#	Selecting friends
###################################
func _onPressFriendCard(event, id):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if NewGroupFriends.has(id):
					NewGroupFriends.erase(id)
					FriendList.get_node(id).modulate = Color("#ffffff")
				else:
					NewGroupFriends.append(id)
					FriendList.get_node(id).modulate = Color("#aaaaaa")
					

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Groups.tscn")
