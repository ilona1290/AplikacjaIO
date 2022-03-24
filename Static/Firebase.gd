extends Node

const API_KEY := "AIzaSyAa4UoxAWIu6aYYwgBLYalZuPvC3jsLCVI"
const PROJECT_ID := "aplikacjaio-5bde4"

const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
const FIRESTORE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID

var user_info := {}

func _get_user_info(result: Array) -> Dictionary:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	
	return {
		"token": result_body.idToken,
		"id": result_body.localId
	}

func _get_request_headers() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % user_info.token
	])

func register(email: String, password: String, http: HTTPRequest) -> void:
	var body := {
		"email": email,
		"password": password,
	}
	http.request(REGISTER_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)

func login(email: String, password: String, http: HTTPRequest) -> void:
	var body := {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)


func save_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_POST, body)


func get_document(path: String, http: HTTPRequest) -> void:
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_GET)

func update_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_PATCH, body)

func delete_document(path: String, http: HTTPRequest) -> void:
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_DELETE)


###################################
#	Need testing
#	Examples:
#	data:			returned value:
#	"Name"			{stringValue:Name}
#	["a","b"]		{arrayValue:{values:[{stringValue:a}, {stringValue:b}]}}
###################################
func prepareDataForFirebase(data):
	match typeof(data):
		TYPE_STRING:
			return { "stringValue": data}
		TYPE_ARRAY:
			var tmpArray : Array = []
			for i in data:
				tmpArray.append(prepareDataForFirebase(i))
			return {"arrayValue": {"values": String(tmpArray)}}
		_:
			print("'prepareDataForFirebase' Type with number: ", typeof(data), " is unsupported")
	
	
###################################
#	Need testing
#	Examples:
#	data:																	returned value:
#	{stringValue:Name}														"Name"
#	{arrayValue:{values:[{stringValue:a}, {stringValue:b}]}}				["a", "b"]
###################################
func formatDataFromFirebase(data):
	var results
	match typeof(data):
		TYPE_DICTIONARY:
			results = {}
			for key in data.keys():
				var dataKey = data.get(key)
				if dataKey is Dictionary:
					if dataKey.get("stringValue") != null:
						results[key] = dataKey.stringValue
					elif dataKey.get("arrayValue") != null:
						var arrayValues = dataKey.arrayValue.values
						#print(key," ", arrayValues)
						results[key] = String(formatDataFromFirebase(arrayValues))
				else:
					#print("Check: ", dataKey)
					return dataKey
			return results
		TYPE_ARRAY:
			var tmpArray = []
			for i in data:
				tmpArray.append(formatDataFromFirebase(i))
			#print("tmpArray: ", tmpArray)
			return tmpArray
		_:
			print("'formatDataFromFirebase' Type with number: ", typeof(data), " might occur bugs")
	#print(results)
	return results
