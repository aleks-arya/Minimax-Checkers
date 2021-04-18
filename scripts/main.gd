extends Node2D

var offsetX = 40
var offsetY = 56
# X range - 24,280
# Y range - 40,286

var bot_pawns = []
var player_pawns = []

var active = false
var player_turn = true

var playerLabel
var botLabel

func _ready():
	var pos = Vector2(offsetX+32, offsetY)
	var count = 1
	for i in range(0,3):
		for j in range(0,4):
			var object = load("res://scripts/"+Global.bot+"_pawn.tscn").instance()
			object.name = "bot_"+str(count)
			bot_pawns.append(object)
			count = count+1
			$CanvasLayer.add_child(object)
			object.position = pos
			pos.x = pos.x+64
		pos.x = offsetX + i*32
		pos.y = pos.y+32
	
	pos = Vector2(offsetX, offsetY+5*32)
	count = 1
	for i in range(0,3):
		for j in range(0,4):
			var object = load("res://scripts/"+Global.player+"_pawn.tscn").instance()
			object.name = "player_"+str(count)
			player_pawns.append(object)
			count = count+1
			$CanvasLayer.add_child(object)
			object.position = pos
			pos.x = pos.x+64
		pos.x = offsetX + (1-i)*32
		pos.y = pos.y+32
	
	if Global.player == "black":
		player_turn = false
		bot_turn()
		player_turn = true
		
		playerLabel = $Labelblack
		botLabel = $Labelwhite
	else:
		playerLabel = $Labelwhite
		botLabel = $Labelblack
	
	$End/black_wins.visible = false
	$End/white_wins.visible = false
	pass # Replace with function body.

func _input(event):
	if player_turn and can_player_move() and can_bot_move():
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				var name = Global.active
				if name != "":
					if not Global.lock_active:
						var activate = find_node_by_name(get_tree().get_root(), name)
						if activate.is_queen:
							activate.sprite.animation = "queen_active"
						else:
							activate.sprite.animation = "active"
						
						if Global.prev_active == "" or Global.prev_active == name:
							Global.prev_active = name
							active = true
						else:
							var deactivate = find_node_by_name(get_tree().get_root(), Global.prev_active)
							if deactivate.is_queen:
								deactivate.sprite.animation = "queen_default"
							else:
								deactivate.sprite.animation = "default"
							Global.prev_active = name
						pass
				if active:
					var mouse_pos = get_global_mouse_position()
					var moving = find_node_by_name(get_tree().get_root(), name)
					if is_on_map(mouse_pos.x, mouse_pos.y):
						var cell = get_cell(mouse_pos.x, mouse_pos.y)
						var possible = possible_player_moves()
						var captures = possible_captures(moving)
						var moves = possible_moves(moving)

						if captures != []:
							if cell in captures:
								if cell in possible:
									var captured_pos = (cell+moving.position)/2
									var captured = get_pawn_by_cords(captured_pos.x, captured_pos.y)
									
									$CanvasLayer.remove_child(captured)
									bot_pawns.erase(captured)
									moving.position = cell
									captures = possible_captures(moving)
									
									if moving.position.y == 56:
										moving.is_queen = true
									
									if captures != []:
										Global.lock_active = true
									else:
										end_turn()
						elif moves != []:
							if cell in moves:
								if cell in possible:
									moving.position = cell
									
									if moving.position.y == 56:
										moving.is_queen = true
									end_turn()
					
	pass # Replace with function body.

func _process(delta):
	playerLabel.text = str(12 - bot_pawns.size())
	botLabel.text = str(12 - player_pawns.size())
	
	if can_bot_move() == false:
		if Global.player == "white":
			$End/white_wins.visible = true
		else:
			$End/black_wins.visible = true
	if can_player_move() == false:
		if Global.player == "white":
			$End/black_wins.visible = true
		else:
			$End/white_wins.visible = true
	
func is_on_map(x,y):
	if x in range(24,280) and y in range(40,286):
		return true
	return false

func get_cell(x,y):
	return Vector2((int(x-24)/32)*32 + offsetX, (int(y-40)/32)*32 + offsetY)

func get_pawn_by_cords(x,y):
	var pos = get_cell(x,y)
	
	for x in bot_pawns:
		if x.position == pos:
			return x
	
	for x in player_pawns:
		if x.position == pos:
			return x
	return null

func get_pawn_by_array(x,y):
	var cx = x*32 + 40
	var cy = y*32 + 56
	var pos = get_cell(cx,cy)
	
	for x in bot_pawns:
		if x.position == pos:
			return x
	
	for x in player_pawns:
		if x.position == pos:
			return x
	return null

func is_cell_ally(x,y):
	var pos = get_cell(x,y)
	
	for x in player_pawns:
		if x.position == pos:
			return true
	return false
	
func is_cell_enemy(x,y):
	var pos = get_cell(x,y)
	
	for x in bot_pawns:
		if x.position == pos:
			return true
	return false

func is_cell_empty(x,y):
	if is_cell_ally(x,y):
		return false
	if is_cell_enemy(x,y):
		return false
	return true

func possible_moves(node):
	var active = node
	if active == null:
		return []
	var moves = []

	if active in player_pawns or active.is_queen:
		#up left
		if is_cell_empty(active.position.x - 32, active.position.y - 32):
			if is_on_map(active.position.x - 32, active.position.y - 32):
				moves.append(Vector2(active.position.x - 32, active.position.y - 32))
		#up right
		if is_cell_empty(active.position.x + 32, active.position.y - 32):
			if is_on_map(active.position.x + 32, active.position.y - 32):
				moves.append(Vector2(active.position.x + 32, active.position.y - 32))
	
	if active in bot_pawns or active.is_queen:
		#down left
		if is_cell_empty(active.position.x - 32, active.position.y + 32):
			if is_on_map(active.position.x - 32, active.position.y + 32):
				moves.append(Vector2(active.position.x - 32, active.position.y + 32))
		#down right
		if is_cell_empty(active.position.x + 32, active.position.y + 32):
			if is_on_map(active.position.x + 32, active.position.y + 32):
				moves.append(Vector2(active.position.x + 32, active.position.y + 32))
	
	return moves
	
func possible_captures(node):
	var active = node
	if active == null:
		return []
	var captures = []
	
	if active in player_pawns or active.is_queen:
	#up left
		if is_cell_enemy(active.position.x - 32, active.position.y - 32) and is_cell_empty(active.position.x - 64, active.position.y - 64):
			if is_on_map(active.position.x - 64, active.position.y - 64):
				captures.append(Vector2(active.position.x - 64, active.position.y - 64))
		#up right
		if is_cell_enemy(active.position.x + 32, active.position.y - 32) and is_cell_empty(active.position.x + 64, active.position.y - 64):
			if is_on_map(active.position.x + 64, active.position.y - 64):
				captures.append(Vector2(active.position.x + 64, active.position.y - 64))
	
	if active in bot_pawns or active.is_queen:
		#down left
		if is_cell_enemy(active.position.x - 32, active.position.y + 32) and is_cell_empty(active.position.x - 64, active.position.y + 64):
			if is_on_map(active.position.x - 64, active.position.y + 64):
				captures.append(Vector2(active.position.x - 64, active.position.y + 64))
		#down right
		if is_cell_enemy(active.position.x + 32, active.position.y + 32) and is_cell_empty(active.position.x + 64, active.position.y + 64):
			if is_on_map(active.position.x + 64, active.position.y + 64):
				captures.append(Vector2(active.position.x + 64, active.position.y + 64))
	
	return captures

func possible_player_moves():
	var moves = []
	
	for pawn in player_pawns:
		for capture in possible_captures(pawn):
			if capture != null:
				moves.append(capture)
	
	if moves != []:
		return moves
	
	for pawn in player_pawns:
		for move in possible_moves(pawn):
			if move != null:
				moves.append(move)
	
	return moves

func can_bot_move():
	for x in bot_pawns:
		if possible_captures(x) != []:
			return true
		if possible_moves(x) != []:
			return true
	return false

func can_player_move():
	for x in player_pawns:
		if possible_captures(x) != []:
			return true
		if possible_moves(x) != []:
			return true
	return false

func end_turn():
	var deactivate = find_node_by_name(get_tree().get_root(), Global.prev_active)
	if deactivate.is_queen:
		deactivate.sprite.animation = "queen_default"
	else:
		deactivate.sprite.animation = "default"
	
	Global.lock_active = false
	Global.active = ""
	Global.prev_active = ""
	player_turn = false
	print("end of turn")
	bot_turn()
	player_turn = true

func get_board():
	var matrix=[]
	for x in range(8):
		matrix.append([])
		matrix[x]=[]
		for y in range(8):
			matrix[x].append([])
			matrix[x][y]=0
	
	for pawn in bot_pawns:
		var value = 1
		if pawn.is_queen:
			value = 2
		var x = (pawn.position.x-40)/32
		var y = (pawn.position.y-56)/32
		matrix[x][y] = value
	
	for pawn in player_pawns:
		var value = -1
		if pawn.is_queen:
			value = -2
		var x = (pawn.position.x-40)/32
		var y = (pawn.position.y-56)/32
		matrix[x][y] = value
	
	return matrix

func bot_turn():
	if can_bot_move():
		var board = get_board()
		#var changed = $Bot.minimax(board, 3, true)[1]
		var move = $Bot.minimax(board, 5, true)[1]

		var moving = get_pawn_by_array(move[0].x, move[0].y)
		var x = move[1].x*32 + 40
		var y = move[1].y*32 + 56
		moving.position = Vector2(x,y)
		
		if move[1].y == 7:
			moving.is_queen = true
			moving.sprite.animation = "queen_default"
			
		for pawn in move[2]:
			var captured = get_pawn_by_array(pawn.x, pawn.y)
			$CanvasLayer.remove_child(captured)
			player_pawns.erase(captured)

func find_node_by_name(root, name):
	if(root.get_name() == name): return root
	
	for child in root.get_children():
		if(child.get_name() == name):
			return child
		var found = find_node_by_name(child, name)
		
		if(found): return found
	return null

func _on_ButtonBack_pressed():
	get_tree().change_scene("res://menu.tscn")
	pass # Replace with function body.
