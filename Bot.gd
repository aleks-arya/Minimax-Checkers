extends Node

func minimax(board, depth, turn):
	#last recursion step
	if depth == 0 or win(board, turn):
		var eval = heuristic(board)
		return [eval, []]
		
	if turn:#max player
		var maxEval = -100
		var best_move = null
		
		#move = [board, [start, end, [skips]]]
		for move in get_all_moves(board, turn):
			#evaluation = [heuristic, move]
			var evaluation = minimax(move[0], depth-1, false)
			maxEval = max(maxEval, evaluation[0])
			
			#setting best move if eval is higher
			if maxEval == evaluation[0]:
				best_move = move[1]
		
		return [maxEval, best_move]
	else:#min player
		var minEval = 100
		var best_move = null
		
		#move = [board, [start, end, [skips]]]
		for move in get_all_moves(board, turn):
			#evaluation = [heuristic, move]
			var evaluation = minimax(move[0], depth-1, true)
			minEval = min(minEval, evaluation[0])
			
			#setting best move if eval is lower
			if minEval == evaluation[0]:
				best_move = move[1]
		
		return [minEval, best_move]

func alphabeta(board, depth, turn, alpha, beta):
	#returning for last recursion step
	if depth == 0 or win(board, turn):
		var eval = heuristic(board)
		return [eval, []]
	
	if turn:#max player
		var maxEval = alpha
		var best_move = null
		
		#move = [board, [start, end, [skips]]]
		for move in get_all_moves(board, turn):
			#evaluation = [heuristic, move]
			var evaluation = alphabeta(move[0], depth-1, false, maxEval, beta)
			maxEval = max(maxEval, evaluation[0]) #checking maximum
			
			#pruning tree if bigger than beta
			if maxEval >= beta:
				return [maxEval, []]
			#setting best move if evaluation is higher
			if maxEval == evaluation[0]:
				best_move = move[1]
				
		return [maxEval, best_move]
	else:#min player
		var minEval = beta
		var best_move = null
		
		#move = [board, [start, end, [skips]]]
		for move in get_all_moves(board, turn):
			#evaluation = [heuristic, move]
			var evaluation = alphabeta(move[0], depth-1, true, alpha, minEval)
			minEval = min(minEval, evaluation[0])
			
			#pruning tree if smaller than alpha
			if minEval <= alpha:
				return [minEval, []]
			#setting best move if evaluation is smaller
			if minEval == evaluation[0]:
				best_move = move[1]
		
		return [minEval, best_move]

func win(board, turn):
	#checking if there are possible moves for one player
	if get_all_moves(board, turn) == []:
		return true
	return false

func heuristic(board):
	#summing all board pieces
	#pawns are of value 1 for bot and -1 for player
	#queens are of value 2 for bot and -2 for player
	var sum = 0
	for row in board:
		for x in row:
			sum += x
	return sum
	
func get_all_moves(board, turn):
	#returing moves in form [board, [start, end, [skips]]]
	var moves = []
	
	#valid_moves[ [[start],[end], [skip]], ... ]
	#valid moves can consist of only jumps or only shifts
	var valid_moves = get_valid_moves(board, turn) 
	for moveset in valid_moves:
		for move in moveset:
			#creating temporary board
			var temp_board = board.duplicate(true)
			var new_board = simulate_move(temp_board, move[0], move[1], move[2])
			#creating move as [board, move]
			var temp = [new_board, move]
			moves.append(temp)
	
	return moves

func get_all_pieces(board, turn):
	#returning all pieces (Vector2(x,y)) for bot (turn = true) or player (turn = false)
	var pieces = []
	for x in range(8):
		for y in range(8):
			if turn and board[x][y] > 0:
				pieces.append(Vector2(x,y))
			elif not turn and board[x][y] < 0:
				pieces.append(Vector2(x,y))
	
	return pieces 

func get_valid_moves(board, turn):
	#if there is a possibility to capture a piece, such move must be made
	#so get_valid_moves returns only possible jumps or shifts
	var jumps = []
	for piece in get_all_pieces(board, turn):
		var temp = get_jumps(board, piece)
		if temp != []:
			jumps.append(temp)
	
	#if jumps table is not empty, only jumps are returned
	if jumps != []:
		return jumps
		
	#if jumps table is empty, we check for possible shifts
	var shifts = []
	for piece in get_all_pieces(board, turn):
		var temp = get_shifts(board, piece)
		if temp != []:
			shifts.append(temp)
	
	#the possible shifts table is returned
	return shifts
	
func get_shifts(board, piece):
	#get all possible shifts (one step) for one piece
	#move = [start, end, []]
	var moves = []
	var left = piece.x-1
	var right = piece.x+1
	var up = piece.y-1
	var down = piece.y+1
	
	#down direction
	#possible for bot pawns (value > 0) or all queens (abs value > 1)
	if board[piece.x][piece.y] > 0 or abs(board[piece.x][piece.y]) > 1:
		if down <=7:#checking board ranges
			if left >= 0:
				if board[left][down] == 0:
					#adding if left-down cell is empty
					moves.append([piece, Vector2(left, down), []])
			if right <= 7:
				if board[right][down] == 0:
					#adding if right-down cell is empty
					moves.append([piece, Vector2(right, down), []])	
	#up direction
	#possible for player pawns (value < 0) or all queens (abs value > 1)
	if board[piece.x][piece.y] < 0 or abs(board[piece.x][piece.y]) > 1:
		if up >= 0:#checking board ranges
			if left >= 0:
				if board[left][up] == 0:
					#adding if left-up cell is empty
					moves.append([piece, Vector2(left, up), []])
			if right <= 7:
				if board[right][up] == 0:
					#adding if right-up cell is empty
					moves.append([piece, Vector2(right, up), []])	
	return moves

func get_jumps(board, piece):
	#get all possible jumps for one piece
	#jump recursion ends when piece has no more possible jumps
	#move = [start, end, [skips]]
	var moves = []
	var left = piece.x-1
	var right = piece.x+1
	var up = piece.y-1
	var down = piece.y+1

	#down direction
	#possible for bot pawns (value > 0) or all queens (abs value > 1)
	if board[piece.x][piece.y] > 0 or abs(board[piece.x][piece.y]) > 1:
		if down <=7:#checking board ranges for one and two steps
			if left >= 0:
				#checking if enemy
				#values are opposite, so for enemy product will be negative (and 0 for empty)
				if (board[left][down]*board[piece.x][piece.y]) < 0:
					if down+1 <=7 and left-1 >= 0:
						if board[left-1][down+1] == 0:
							var skip = Vector2(left, down)
							var end = Vector2(left-1, down+1)
							#simulating board with such skip and recursive call of jumps
							var new_board = simulate_move(board, piece, end, [skip])
							var temp_move = get_jumps(new_board, end)
							
							if temp_move == []:
								#if no more jumps
								moves.append([piece, end, [skip]])
							else:
								for move in temp_move:
									#appending skips for multiple jumps
									var skipped = move[2]
									skipped.append(skip)
									moves.append([piece, move[1], skipped])
								
			if right <= 7:
				#checking if enemy
				#values are opposite, so for enemy product will be negative (and 0 for empty)
				if (board[right][down]*board[piece.x][piece.y]) < 0:
					if down+1 <=7 and right+1 <= 7:
						if board[right+1][down+1] == 0:
							var skip = Vector2(right, down)
							var end = Vector2(right+1, down+1)
							#simulating board with such skip and recursive call of jumps
							var new_board = simulate_move(board, piece, end, [skip])
							var temp_move = get_jumps(new_board, end)
							
							if temp_move == []:
								#if no more jumps
								moves.append([piece, end, [skip]])
							else:
								for move in temp_move:
									#appending skips for multiple jumps
									var skipped = move[2]
									skipped.append(skip)
									moves.append([piece, move[1], skipped])
	#up direction
	#possible for player pawns (value < 0) or all queens (abs value > 1)
	if board[piece.x][piece.y] < 0 or abs(board[piece.x][piece.y]) > 1:
		if up >= 0:#checking board ranges for one and two steps
			if left >= 0:
				#checking if enemy
				#values are opposite, so for enemy product will be negative (and 0 for empty)
				if (board[left][up]*board[piece.x][piece.y]) < 0:
					if up-1 >= 0 and left-1 >= 0:
						if board[left-1][up-1] == 0:
							var skip = Vector2(left, up)
							var end = Vector2(left-1, up-1)
							#simulating board with such skip and recursive call of jumps
							var new_board = simulate_move(board, piece, end, [skip])
							var temp_move = get_jumps(new_board, end)
							
							if temp_move == []:
								#if no more jumps
								moves.append([piece, end, [skip]])
							else:
								for move in temp_move:
									#appending skips for multiple jumps
									var skipped = move[2]
									skipped.append(skip)
									moves.append([piece, move[1], skipped])
								
			if right <= 7:
				#checking if enemy
				#values are opposite, so for enemy product will be negative (and 0 for empty)
				if (board[right][up]*board[piece.x][piece.y]) < 0:
					if up-1 >= 0 and right+1 <= 7:
						if board[right+1][up-1] == 0:
							var skip = Vector2(right, up)
							var end = Vector2(right+1, up-1)
							#simulating board with such skip and recursive call of jumps
							var new_board = simulate_move(board, piece, end, [skip])
							var temp_move = get_jumps(new_board, end)
							
							if temp_move == []:
								#if no more jumps
								moves.append([piece, end, [skip]])
							else:
								for move in temp_move:
									#appending skips for multiple jumps
									var skipped = move[2]
									skipped.append(skip)
									moves.append([piece, move[1], skipped])
	return moves

func simulate_move(board, start, end, skip):
	#create test array with move and return new board
	#duplicating board to create deepcopy
	var new_board = board.duplicate(true)
	
	#swapping values for pawn start and end
	var temp = new_board[start.x][start.y]
	new_board[start.x][start.y] = new_board[end.x][end.y]
	new_board[end.x][end.y] = temp
	
	#removing all skipped pieces
	for piece in skip:
		new_board[piece.x][piece.y] = 0
	
	return new_board
