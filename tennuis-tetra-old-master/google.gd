extends Button


@onready var rich_text_label = $RichTextLabel

var oauth2 : Oauth2
var signed_in : bool = false

func _ready():
	var oauth_credentials = {
		"oauth_port":54140,
		"oauth_binding":"127.0.0.1",
		"oauth_client_id":"1046377611193-931ppv76gmmcm75khkfqc136vrqsvqtb.apps.googleusercontent.com",
		"oauth_client_secret":"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",
		"oauth_auth_server":"https://accounts.google.com/o/oauth2/v2/auth",
		"oauth_token_req":"https://oauth2.googleapis.com/token",
		"oauth_token_key":"password"
	}
	oauth2 = Oauth2.new(oauth_credentials)
	add_child(oauth2)
	oauth2.connect("token_authorized", _on_token_authorized)
	oauth2.connect("token_error", _on_token_error)
	oauth2.connect("working", func(): rich_text_label.text= "[wave amp=50.0 freq=5.0 connected=1]...[/wave]" )
	oauth2.connect("logged_out", func(): rich_text_label.text= "Sign in with Google" )

func _on_pressed():
	if signed_in:
		oauth2.clear_tokens()
		signed_in = false
	else:
		oauth2.authorize()
	
func _on_token_authorized():
	rich_text_label.text = "%s" % oauth2.user_info.get("name")
	rich_text_label.tooltip_text = "sign out"
	signed_in = true
	pass
	
func _on_token_error(error : String):
	rich_text_label.text = "[color=red]error! %s[/color]" % error
	signed_in = false
	pass



func _on_mouse_entered():
	if signed_in:
		rich_text_label.text = "[color=red]sign out?[/color]"



func _on_mouse_exited():
	if signed_in:
		rich_text_label.text = "%s" % oauth2.user_info.get("name")
