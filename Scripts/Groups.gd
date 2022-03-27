extends Control

var GroupCardScene = preload("res://Scenes/GroupCard.tscn")

onready var http : HTTPRequest = $HTTPRequest
onready var http2 : HTTPRequest = $HTTPRequest2
onready var http3 : HTTPRequest = $HTTPRequest3
onready var NameInput = $Background/NameInput 
onready var Notification = $Background/Notification

onready var GroupList = $Background/ScrollContainer/VBoxContainer



var counterGroups = 0
var counterMembers = 0

var UserGroups : Array = []
var Members = []

var Group := {
	"Name" : {},
	"Members": []
}

func _ready():
	Firebase.get_document("userFriendsGroups/%s" % Firebase.user_info.id, http)

func generateGroupList(name, members):
	var tmpGroupCard = GroupCardScene.instance()
	tmpGroupCard.get_node("Background/Name").text = name
	for m in members:
		if(tmpGroupCard.get_node("Background/Members").text == ""):
			tmpGroupCard.get_node("Background/Members").text = "Członkowie: " + m
		else:
			tmpGroupCard.get_node("Background/Members").text = tmpGroupCard.get_node("Background/Members").text + ", " + m
	tmpGroupCard.get_node("Background").connect("gui_input", self, "_onPressGroupCard", [name, members])
	tmpGroupCard.name = name
	GroupList.add_child(tmpGroupCard)

func _onPressGroupCard(event, name, members):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				ChosenGroup.Name = name
				ChosenGroup.Members = members
				get_tree().change_scene("res://Scenes/Bills.tscn")
				#if NewGroupFriends.has(id):
					#NewGroupFriends.erase(id)
					#FriendList.get_node(id).modulate = Color("#ffffff")
				#else:
					#NewGroupFriends.append(id)
					#FriendList.get_node(id).modulate = Color("#aaaaaa")
					

func _on_AddGroupButton_pressed():
	get_tree().change_scene("res://Scenes/AddGroup.tscn")


###################################
#	Get User Groups
###################################
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			if(result_body.fields["Groups"].arrayValue.size() != 0):
				UserGroups = result_body.fields["Groups"].arrayValue.values
				Firebase.get_document("groups/%s" % UserGroups[counterGroups].stringValue, http2)
			else:
				Notification.text = "Użytkownik nie posiada żadnych grup."


###################################
#	Get group and name of group
###################################
func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			Group["Name"] = result_body.fields["Name"].stringValue
			Members = result_body.fields["Members"].arrayValue.values
			
			Firebase.get_document("users/%s" % Members[counterMembers].stringValue, http3)
			


###################################
#	Get group members
###################################
func _on_HTTPRequest3_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			var Member = result_body.fields["Name"].stringValue + " " + result_body.fields["Surname"].stringValue
			Group["Members"].append(Member)
			counterMembers += 1
			if(counterMembers < Members.size()): 
				Firebase.get_document("users/%s" % Members[counterMembers].stringValue, http3)
			else:
				generateGroupList(Group["Name"], Group["Members"])
				Group["Members"] = []
				counterGroups += 1
				counterMembers = 0
				
				if(counterGroups < UserGroups.size()): 
					Firebase.get_document("groups/%s" % UserGroups[counterGroups].stringValue, http2)
				else:
					print("Koniec")
			
func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")
