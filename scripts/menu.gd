extends Node

func _on_ButtonWhite_pressed():
	Global.player = "white"
	Global.bot = "black"
	get_tree().change_scene("res://main.tscn")
	pass # Replace with function body.


func _on_ButtonBlack_pressed():
	Global.player = "black"
	Global.bot = "white"
	get_tree().change_scene("res://main.tscn")
	pass # Replace with function body.
