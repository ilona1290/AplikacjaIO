extends Node

var HTTP : HTTPRequest = HTTPRequest.new()
const API_URL = "http://localhost/api.php"

var httpResult : Dictionary = {}
var userID = ""

func _ready() -> void:
	HTTP.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	add_child(HTTP)

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var result_body = JSON.parse(body.get_string_from_utf8())
	#print(response_code)
	#print("HTTP r_b.r: ", result_body.result)
	httpResult = result_body.result

func login(var email, var password):
	var query = {
		"Action":"Login",
		"Email": email,
		"Password": password.sha256_text()
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	userID = httpResult.Result
	httpResult.clear()

func register(var email, var password):
	var query = {
		"Action":"Register",
		"Email": email,
		"Password": password.sha256_text()
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	httpResult.clear()

func getProfiles(var ids):
	var query = {
		"Action":"GetProfiles",
		"Ids":ids
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	var result : Dictionary
	result = httpResult.duplicate()
	httpResult.clear()
	return result

func uploadImage(var image : Image, var path):
	var query = {
		"Action":"UploadImg",
		"Image":Marshalls.raw_to_base64(image.save_png_to_buffer()),
		"Path":path
	}
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	httpResult.clear()

func getFile(var path):
	var query = {
		"Action":"GetFile",
		"Path":path
	}
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	var result : Dictionary 
	result = httpResult.duplicate()
	
	httpResult.clear()
	return result

func getAvatar(var id) -> Image:
	var a : Image = Image.new()
	var avatarBuffer = yield(getFile("avatars/" + id + ".png"), "completed").Result
	if avatarBuffer == "":
		a.load("res://Images/AvatarPlaceholder.png")
	else:
		a.load_png_from_buffer(Marshalls.base64_to_raw(avatarBuffer))
	return a

func uploadAvatar(var image : Image):
	uploadImage(image, "avatars/" + userID + ".png")

func getUserGroups(var id) -> Dictionary:
	var query = {
		"Action":"GetUserGroups",
		"Id": id
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	var result : Dictionary 
	result = httpResult.duplicate()
	httpResult.clear()
	return result

func getGroupName(var groupId):
	var query = {
		"Action":"GetGroupName",
		"Id": groupId
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	var result : Dictionary 
	result = httpResult.duplicate()
	
	httpResult.clear()
	return result

func getGroupMembers(var groupId):
	var query = {
		"Action":"GetGroupMembers",
		"Id": groupId
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	var result : Dictionary 
	result = httpResult.duplicate()
	
	httpResult.clear()
	return result

func createNewGroup(var name, var members : Array):
	var query = {
		"Action":"CreateNewGroup",
		"Name": name,
		"Members":members
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	httpResult.clear()

func getUserFriends(var id):
	var query = {
		"Action":"GetUserFriends",
		"Id":id
	}

	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")

	var result : Dictionary
	result = httpResult.duplicate()
	httpResult.clear()
	return result

func addFriend(var to, var from = userID):
	var query = {
		"Action":"AddFriend",
		"From":from,
		"To":to
	}

	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")

	httpResult.clear()

func updateProfile(var id, var data : Dictionary):
	var query = {
		"Action":"UpdateProfile",
		"Id": id,
		"Data":data
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	httpResult.clear()

func searchForUsers(var pattern, var id = userID):
	var query = {
		"Action":"SearchForUsers",
		"Id":id,
		"Pattern":pattern
	}

	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	var result : Dictionary 
	result = httpResult.duplicate()
	
	httpResult.clear()
	return result

func addBills(var bills : Array):
	var query = {
		"Action":"AddBills",
		"Bills":bills
	}
	
	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")
	
	httpResult.clear()

func getBills(var id):
	var query = {
		"Action":"GetBills",
		"Id":id
	}

	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")

	var result : Dictionary
	result = httpResult.duplicate()
	httpResult.clear()
	return result

func updateBills(var id):
	var query = {
		"Action":"UpdateBills",
		"Id":id
	}

	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")

	var result : Dictionary
	result = httpResult.duplicate()
	httpResult.clear()
	return result


func test():
	var query = {
		"Action":"testt",
		"Arr":	["5", "6", "12"]
	}

	HTTP.request(API_URL, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(query))
	yield(HTTP, "request_completed")

	httpResult.clear()
