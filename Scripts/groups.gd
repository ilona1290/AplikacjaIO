extends Control

var friendCardScene = preload("res://Scenes/friendCard.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const MODULO_8_BIT = 256
onready var http : HTTPRequest = $HTTPRequest
onready var http2 : HTTPRequest = $HTTPRequest2
onready var http3 : HTTPRequest = $HTTPRequest3
onready var http4 : HTTPRequest = $HTTPRequest4
onready var http5 : HTTPRequest = $HTTPRequest5

onready var FriendList = $background/ScrollContainer/VBoxContainer

var newGroup := false
var groupId
var counter = 0
var members = [{"stringValue": "Dh3MPZlLTQQlhHSp84vW4zQItHk2"}, 
	{"stringValue": "KzWufOjquUSqLyftrOWFA6ppde13"},
	{"stringValue": "nzq1rnHZyPZDKRb2Yl3jFexBxjj1"}]
	
var friends : Array = []
var groups : Array = []

var newGroupFriends : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.get_document("userFriendsGroups/%s" % Firebase.user_info.id, http5)
	yield(get_tree().create_timer(0.5), "timeout")
	print("friends: ", friends)
	for f in friends:
		var tmpFriendCard = friendCardScene.instance()
		tmpFriendCard.get_node("background/Name").text = f
		tmpFriendCard.get_node("background").connect("gui_input", self, "_onPressFriendCard", [f])
		tmpFriendCard.name = f
		FriendList.add_child(tmpFriendCard)
		
	pass # Replace with function body.

func _on_AddGroupButton_pressed():
	groupId = v4()
	print(groupId)
	members.append({"stringValue": Firebase.user_info.id})
	print(members)
	Firebase.get_document("groups/%s" % groupId, http)
	pass # Replace with function body.

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			Firebase.save_document("groups?documentId=%s" % groupId, {"Members":{ "arrayValue": { "values": members}}}, http2)
		200:
			return
			

func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			print("Utworzono grupę")
			#Firebase.get_document("userFriendsGroups/%s" % members[counter].stringValue, http3)
				#yield()

#func _on_HTTPRequest3_request_completed(result, response_code, headers, body):
#	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
#	print(result_body)
#	match response_code:
#		404:
#			Firebase.save_document("userFriendsGroups/?documentId=%s" % members[counter].stringValue, {"Groups":{ "arrayValue": { "values": {"stringValue": groupId}}}}, http3)
#			counter += 1
#			return
#		200:
#			Firebase.get_document("userFriendsGroups/%s" % members[counter].stringValue, http4)
#			print("Stworzono grupe")
			
#func _on_HTTPRequest4_request_completed(result, response_code, headers, body):
#	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
#	print(result_body)
#	match response_code:
#		404:
#			return
#		200:
#			if(result_body.fields["Friends"].arrayValue.values != null):
#				friends = result_body.fields["Friends"].arrayValue.values
#			if(result_body.fields["Groups"].arrayValue.values != null):
#				groups = result_body.fields["Groups"].arrayValue.values
#			groups.append({"stringValue": groupId})
#			Firebase.update_document("userFriendsGroups/%s" % members[counter].stringValue, {"Friends":{ "arrayValue": { "values": friends}}, "Groups": { "arrayValue": { "values": groups}}}, http3)
#			counter += 1
#			print("Stworzono grupe")
#			friends.clear()
#			groups.clear()

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
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HTTPRequest5_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			print(result_body.fields["Friends"].arrayValue.values)
			for id in result_body.fields["Friends"].arrayValue.values:
				friends.append(id.stringValue)
			#for i in range(friends.size()):
				#var tmp = friendCardScene.instance()
				#tmp.get_node("background/Name").text = friends[i].stringValue
				#FriendList.add_child(tmp)
	#Notification.text = "Wyslano zaproszenie"
	pass # Replace with function body.


func _onPressFriendCard(event, id):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if newGroupFriends.has(id):
					newGroupFriends.erase(id)
					FriendList.get_node(id).modulate = Color("#ffffff")
				else:
					newGroupFriends.append(id)
					FriendList.get_node(id).modulate = Color("#aaaaaa")
