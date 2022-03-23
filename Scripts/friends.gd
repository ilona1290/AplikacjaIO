extends Control

var friendCardScene = preload("res://Scenes/friendCard.tscn")

onready var NameInput = $background/NameInput
onready var SurnameInput = $background/SurnameInput
onready var http : HTTPRequest = $HTTPRequest
onready var http2: HTTPRequest = $HTTPRequest2
onready var Notification = $background/Notification
onready var FriendList = $background/ScrollContainer/VBoxContainer

var newFriends := false
var isFound := false

var FriendsGroups := {
	"Friends": { "arrayValue": { "values": []}},
	"Groups": { "arrayValue": { "values": []}}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.get_document("userFriendsGroups/%s" % Firebase.user_info.id, http2)
	pass


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			for i in range (result_body.documents.size()):
				if(result_body.documents[i].fields["Name"].stringValue == NameInput.text and result_body.documents[i].fields["Surname"].stringValue == SurnameInput.text):
					isFound = true
					FriendsGroups["Friends"].arrayValue.values.append({"stringValue": result_body.documents[i].name.substr(63)})
					if(newFriends):
						Firebase.save_document("userFriendsGroups?documentId=%s" % Firebase.user_info.id, FriendsGroups, http2)
						newFriends = false
						break
					else:
						Firebase.update_document("userFriendsGroups/%s" % Firebase.user_info.id, FriendsGroups, http2)
						break
				else:
					isFound = false
			if(isFound):
				Notification.text = "Wysłano zaproszenie"
			else:
				Notification.text = "Nie ma takiego użytkownika"


func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			newFriends = true
			return
		200:
			newFriends = false
			if(result_body.fields["Friends"].arrayValue.size() != 0):
				FriendsGroups["Friends"] = result_body.fields["Friends"]
				
			FriendsGroups["Groups"] = result_body.fields["Groups"]
			
			#for i in range(friends.size()):
				#var tmp = friendCardScene.instance()
				#tmp.get_node("background/Name").text = friends[i].stringValue
				#FriendList.add_child(tmp)
	pass # Replace with function body.


func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
	pass # Replace with function body.


func _on_FindButton_pressed():
	Firebase.get_document("users", http)
	pass # Replace with function body.
