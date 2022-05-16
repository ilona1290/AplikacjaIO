extends Control

# Formula for copying
#onready var XXXLabel = $Background/Informations/XXX/XXXLabel
#onready var XXXInput = $Background/Informations/XXX/XXXInput
#onready var XXXValue = $Background/Informations/XXX/XXXValue

onready var NameLabel = $Background/Informations/Name/NameInput
onready var NameInput = $Background/Informations/Name/NameInput
onready var NameValue = $Background/Informations/Name/NameValue

onready var SurnameLabel = $Background/Informations/Surname/SurnameLabel
onready var SurnameInput = $Background/Informations/Surname/SurnameInput
onready var SurnameValue = $Background/Informations/Surname/SurnameValue

onready var BankAccountLabel = $Background/Informations/BankAccount/BankAccountLabel
onready var BankAccountInput = $Background/Informations/BankAccount/BankAccountInput
onready var BankAccountValue = $Background/Informations/BankAccount/BankAccountValue

onready var TelephoneLabel = $Background/Informations/Telephone/TelephoneLabel
onready var TelephoneInput = $Background/Informations/Telephone/TelephoneInput
onready var TelephoneValue = $Background/Informations/Telephone/TelephoneValue

onready var EditButton = $Background/EditButton
onready var Notification = $Background/Notification

onready var Avatar = $Background/Avatar
onready var AvatarFileDialog = $AvatarFileDialog

var new_profile := false
var EditMode : bool = false
var information_sent = false

var UserAccount : UserProfile = UserProfile.new()

const bankRegex = "^[a-zA-Z]{2}[0-9]{26}$"
const phoneRegex = "^(\\+[0-9]{2})?[0-9]{9}$"

func isBankValid(bank) -> bool:
	var regex = RegEx.new()
	regex.compile(bankRegex)
	return regex.search(bank) != null

func isPhoneValid(phone) -> bool:
	var regex = RegEx.new()
	regex.compile(phoneRegex)
	return regex.search(phone) != null

func _ready():
	# Loading data from database to UserAccount variable
	UserAccount.loadFromDictionary(yield(Database.getProfiles([Database.userID]), "completed").Result[Database.userID])
	# Setting all data from UserAccount variable to scene
	loadProfile()
	
	UserAccount.loadAvatar(yield(Database.getAvatar(Database.userID), "completed"))

	var AvatarTex : ImageTexture = ImageTexture.new()
	AvatarTex.create_from_image(UserAccount.Avatar)
	Avatar.texture = AvatarTex

func loadProfile():
	NameValue.text = UserAccount.Name
	SurnameValue.text = UserAccount.Surname
	BankAccountValue.text = UserAccount.BankAccount
	TelephoneValue.text = UserAccount.Telephone
	
	NameInput.text = UserAccount.Name
	SurnameInput.text = UserAccount.Surname
	BankAccountInput.text = UserAccount.BankAccount
	TelephoneInput.text = UserAccount.Telephone

func saveProfile():
	UserAccount.Name = NameInput.text
	UserAccount.Surname = SurnameInput.text
	UserAccount.BankAccount = BankAccountInput.text
	UserAccount.Telephone = TelephoneInput.text

func _on_EditButton_pressed():
	if EditMode == false:
		NameInput.visible = true
		SurnameInput.visible = true
		BankAccountInput.visible = true
		TelephoneInput.visible = true
		
		NameValue.visible = false
		SurnameValue.visible = false
		BankAccountValue.visible = false
		TelephoneValue.visible = false
		
		EditMode = true
		EditButton.text = "Zapisz"
	else:
		if !isPhoneValid(TelephoneInput.text):
			Notification.text = "Błedny numer telefonu"
			return
		if !isBankValid(BankAccountInput.text):
			Notification.text = "Błędny numer konta"
			return
			
		NameInput.visible = false
		SurnameInput.visible = false
		BankAccountInput.visible = false
		TelephoneInput.visible = false
		
		NameValue.visible = true
		SurnameValue.visible = true
		BankAccountValue.visible = true
		TelephoneValue.visible = true
		#Saving changes
		saveProfile()
		loadProfile()
		
		yield(Database.updateProfile(Database.userID, UserAccount.saveToDictionary()), "completed")
		
		Notification.text = "Zapisano zmiany"
		
		information_sent = true
		EditMode = false
		EditButton.text = "Edytuj"

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_Avatar_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			AvatarFileDialog.visible = true

func _on_AvatarFileDialog_confirmed():
	var NewFilePath = AvatarFileDialog.current_path
	var NewAvatarImage : Image = Image.new()
	NewAvatarImage.load(NewFilePath)
	NewAvatarImage.resize(256, 256)
	var NewAvatarTexture : ImageTexture = ImageTexture.new()
	NewAvatarTexture.create_from_image(NewAvatarImage)
	Avatar.texture = NewAvatarTexture
	
	Database.uploadAvatar(NewAvatarImage)
