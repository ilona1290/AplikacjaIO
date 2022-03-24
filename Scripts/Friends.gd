extends Control

var friendCardScene = preload("res://Scenes/FriendCard.tscn")

onready var NameInput = $Background/NameInput
onready var SurnameInput = $Background/SurnameInput
onready var http : HTTPRequest = $HTTPRequest
onready var http2: HTTPRequest = $HTTPRequest2
onready var Notification = $Background/Notification
onready var FriendList = $Background/ScrollContainer/VBoxContainer

var newFriends := false
var isFound := false

var FriendsGroups := {
	"Friends": { "arrayValue": { "values": []}},
	"Groups": { "arrayValue": { "values": []}}
}

func _ready():
	Firebase.get_document("userFriendsGroups/%s" % Firebase.user_info.id, http2)

###################################
#	Adding to friends
###################################
func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			for i in range (result_body.documents.size()):
				if(result_body.documents[i].fields["Name"].stringValue == NameInput.text and result_body.documents[i].fields["Surname"].stringValue == SurnameInput.text):
					isFound = true
					
					# Problem: Adding same user multiple times
					# Fix below doesn't working
					
					#print(Firebase.prepareDataForFirebase(result_body.documents[i].name.substr(63)))
					#print(FriendsGroups["Friends"].arrayValue.values[0])
					#if(FriendsGroups["Friends"].arrayValue.values.has({"stringValue": result_body.documents[i].name.substr(63)})):
					#	Notification.text = "Masz już tego użykownika w znajomych"
					#	return
					
					# Replace 63 in substr with rfind("/") + 1
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

###################################
#	Saving to userFriendsGroups collection
###################################
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


func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_FindButton_pressed():
	Firebase.get_document("users", http)
