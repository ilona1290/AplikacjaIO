extends Control

var GroupCardScene = preload("res://Scenes/GroupCard.tscn")

onready var Notification = $Background/Notification

onready var GroupList = $Background/ScrollContainer/VBoxContainer

var UserGroups : Array = []
var Members = []

func _ready():
	UserGroups = yield(Database.getUserGroups(Database.userID), "completed").Result
	generateGroupList()

func generateGroupList():
	for group in UserGroups:
		var groupName = yield(Database.getGroupName(group), "completed").Result
		var groupMembers = yield(Database.getGroupMembers(group), "completed").Result
		var groupData = {
			"Name":groupName,
			"Members":groupMembers
		}
		var tmpGroupCard = GroupCardScene.instance()
		tmpGroupCard.get_node("Background/Name").text = groupData["Name"]
		tmpGroupCard.get_node("Background/Members").text = "Członkowie: "
		for member in groupData["Members"]:
			tmpGroupCard.get_node("Background/Members").text += String(member) + " "
			var x = ImageTexture.new()
			x.create_from_image(yield(Database.getAvatar(member), "completed"))
			var y = TextureRect.new()
			y.rect_min_size = Vector2(96, 96)
			y.expand = true
			y.texture = x
			tmpGroupCard.get_node("Background/HBoxContainer").add_child(y)
		tmpGroupCard.get_node("Background").connect("gui_input", self, "_onPressGroupCard", [groupData["Name"], groupData["Members"]])
		GroupList.add_child(tmpGroupCard)

func _onPressGroupCard(event, name, members):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				ChosenGroup.Name = name
				ChosenGroup.Members = members
				get_tree().change_scene("res://Scenes/Bills.tscn")

func _on_AddGroupButton_pressed():
	get_tree().change_scene("res://Scenes/AddGroup.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")
