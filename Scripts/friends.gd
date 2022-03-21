extends Control

var friendCardScene = preload("res://Scenes/friendCard.tscn")

onready var NameInput = $background/NameInput
onready var SurnameInput = $background/SurnameInput
onready var http : HTTPRequest = $HTTPRequest
onready var http2: HTTPRequest = $HTTPRequest2
onready var Notification = $background/Notification
onready var FriendList = $background/ScrollContainer/VBoxContainer

var newFriends := false
var friends : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.get_document("userFriendsGroups/%s" % Firebase.user_info.id, http2)
	pass


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			Notification.text = "Nie ma użytkownika z podanymi"
			return
		200:
			
			for i in range (result_body.documents.size()):
				if(result_body.documents[i].fields["Name"].stringValue == NameInput.text and result_body.documents[i].fields["Surname"].stringValue == SurnameInput.text):
					friends.append({"stringValue": result_body.documents[i].name.substr(63)})
					if(newFriends):
						Firebase.save_document("userFriendsGroups?documentId=%s" % Firebase.user_info.id, {"Friends":{ "arrayValue": { "values": friends}}}, http2)
					else:
						Firebase.update_document("userFriendsGroups/%s" % Firebase.user_info.id, {"Friends":{ "arrayValue": { "values": friends}}}, http2)


func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			newFriends = true
			return
		200:
			friends = result_body.fields["Friends"].arrayValue.values
			
			#for i in range(friends.size()):
				#var tmp = friendCardScene.instance()
				#tmp.get_node("background/Name").text = friends[i].stringValue
				#FriendList.add_child(tmp)
	#Notification.text = "Wyslano zaproszenie"
	pass # Replace with function body.


func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
	pass # Replace with function body.


func _on_FindButton_pressed():
	Firebase.get_document("users", http)
	pass # Replace with function body.
