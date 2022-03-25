extends Control

var friendCardScene = preload("res://Scenes/FriendCard.tscn")

const MODULO_8_BIT = 256
onready var http : HTTPRequest = $HTTPRequest
onready var http2 : HTTPRequest = $HTTPRequest2
onready var http3 : HTTPRequest = $HTTPRequest3
onready var http4 : HTTPRequest = $HTTPRequest4 # Downloading friends
onready var NameInput = $Background/NameInput 
onready var Notification = $Background/Notification

onready var FriendList = $Background/ScrollContainer/VBoxContainer

var newGroup := false
var groupId
var counter = 0

var FriendsGroups := {
	"Friends": { "arrayValue": { "values": []}},
	"Groups": { "arrayValue": { "values": []}}
}

var Group := {
	"Name" : {},
	"Members": { "arrayValue": { "values": []}}
}
	
var FriendsToShow : Array = []
var NewGroupFriends : Array = []

func _ready():
	Firebase.get_document("userFriendsGroups/%s" % Firebase.user_info.id, http4)
	yield(http4, "request_completed")
	generateFriendList()

func generateFriendList():
	for f in FriendsToShow:
		var tmpFriendCard = friendCardScene.instance()
		tmpFriendCard.get_node("Background/Name").text = f
		tmpFriendCard.get_node("Background").connect("gui_input", self, "_onPressFriendCard", [f])
		tmpFriendCard.name = f
		FriendList.add_child(tmpFriendCard)

func _on_AddGroupButton_pressed():
	Group["Name"] = {}
	Group["Members"].arrayValue.values = []
	counter = 0
	FriendsGroups["Friends"].arrayValue.values = []
	FriendsGroups["Groups"].arrayValue.values = []
	
	groupId = v4()
	
	Group["Name"] = {"stringValue" : NameInput.text}
	Group["Members"].arrayValue.values.append({"stringValue": Firebase.user_info.id})
	
	for f in NewGroupFriends:
		Group["Members"].arrayValue.values.append({"stringValue": f})
	
	Firebase.save_document("groups?documentId=%s" % groupId, Group, http)


###################################
#	Saving to groups collection
###################################
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			FriendsGroups["Friends"].arrayValue.values = []
			FriendsGroups["Groups"].arrayValue.values = []
			Firebase.get_document("userFriendsGroups/%s" % Group["Members"].arrayValue.values[counter].stringValue, http2)
				
			print("Utworzono grupę")


###################################
#	
###################################
func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			FriendsGroups["Groups"].arrayValue.values.append({"stringValue": groupId})
			Firebase.save_document("userFriendsGroups/?documentId=%s" % Group["Members"].arrayValue.values[counter].stringValue, FriendsGroups, http3)
			return
		200:
			FriendsGroups["Friends"] = result_body.fields["Friends"]
				
			if(result_body.fields["Groups"].arrayValue.size() != 0):
				FriendsGroups["Groups"] = result_body.fields["Groups"]
			FriendsGroups["Groups"].arrayValue.values.append({"stringValue": groupId})
			Firebase.update_document("userFriendsGroups/%s" % Group["Members"].arrayValue.values[counter].stringValue, FriendsGroups, http3)


func _on_HTTPRequest3_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			FriendsGroups["Friends"].arrayValue.values = []
			FriendsGroups["Groups"].arrayValue.values = []
			counter += 1
			if(counter < NewGroupFriends.size() + 1):
				Firebase.get_document("userFriendsGroups/%s" % Group["Members"].arrayValue.values[counter].stringValue, http2)
			else:
				Notification.text = "Utworzono grupę"
			print("Dodano użytkownika do grupy")


###################################
#	Downloading all friends
###################################
func _on_HTTPRequest4_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			FriendsGroups["Friends"] = result_body.fields["Friends"]
			
			for id in FriendsGroups["Friends"].arrayValue.values:
				FriendsToShow.append(id.stringValue)
				
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
					
static func getRandomInt():
  # Randomize every time to minimize the risk of collisions
  randomize()

  return randi() % MODULO_8_BIT

static func uuidbin():
  # 16 random bytes with the bytes on index 6 and 8 modified
  return [
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), ((getRandomInt()) & 0x0f) | 0x40, getRandomInt(),
	((getRandomInt()) & 0x3f) | 0x80, getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
  ]

static func v4():
  # 16 random bytes with the bytes on index 6 and 8 modified
  var b = uuidbin()

  return '%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x' % [
	# low
	b[0], b[1], b[2], b[3],

	# mid
	b[4], b[5],

	# hi
	b[6], b[7],

	# clock
	b[8], b[9],

	# clock
	b[10], b[11], b[12], b[13], b[14], b[15]
  ]

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Groups.tscn")
