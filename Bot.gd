extends Node


func minimax(board, depth, turn):
	if depth == 0 or win(board):
		var eval = heuristic(board)
		return [eval, []]
		
	if turn:
		var maxEval = float('-inf')
		var best_move = null
		for move in get_all_moves(board, turn):
			var evaluation = minimax(move[0], depth-1, false)
			maxEval = max(maxEval, evaluation[0])
			if maxEval == evaluation[0]:
				best_move = move[1]
		
		return [maxEval, best_move]
	else:
		var minEval = float('inf')
		var best_move = null
		for move in get_all_moves(board, turn):
			var evaluation = minimax(move[0], depth-1, true)
			minEval = min(minEval, evaluation[0])
			if minEval == evaluation[0]:
				best_move = move[1]
		
		return [minEval, best_move]
		
func win(board):
	for row in board:
		for x in row:
			pass
	
func heuristic(board):
	var sum = 0
	for row in board:
		for x in row:
			sum += x
			
	return sum
	
func get_all_moves(board, turn):
	var moves = []
		
	var valid_moves = get_valid_moves(board, turn) #valid_moves[ [[start],[end], [skip]], ... ]
	for moveset in valid_moves:
		for move in moveset:
			var temp_board = board
			var new_board = simulate_move(temp_board, move[0], move[1], move[2])
			var temp = [new_board, move]
			moves.append(temp)
	
	return moves
			
func get_all_pieces(board, turn):
	var pieces = []
	for x in range(8):
		for y in range(8):
			if turn and board[x][y] > 0:
				pieces.append(Vector2(x,y))
			elif not turn and board[x][y] < 0:
				pieces.append(Vector2(x,y))
	
	return pieces 

func get_valid_moves(board, turn):
	var jumps = []
	for piece in get_all_pieces(board, turn):
		var temp = get_jumps(board, piece)
		if temp != []:
			jumps.append(temp)
		
	if jumps != []:
		return jumps
		
	var shifts = []
	for piece in get_all_pieces(board, turn):
		var temp = get_shifts(board, piece)
		if temp != []:
			shifts.append(temp)
	return shifts
	
func get_shifts(board, piece):
	var moves = []
	var left = piece.x-1
	var right = piece.x+1
	var up = piece.y-1
	var down = piece.y+1

	if board[piece.x][piece.y] > 0 or abs(board[piece.x][piece.y]) > 1:
		if down >= 0 and down <=7:
			if left >= 0 and left <= 7:
				if board[left][down] == 0:
					moves.append([piece, Vector2(left, down), []])
			if right >= 0 and right <= 7:
				if board[right][down] == 0:
					moves.append([piece, Vector2(right, down), []])	
	
	if board[piece.x][piece.y] < 0 or abs(board[piece.x][piece.y]) > 1:
		if up >= 0 and up <=7:
			if left >= 0 and left <= 7:
				if board[left][up] == 0:
					moves.append([piece, Vector2(left, up), []])
			if right >= 0 and right <= 7:
				if board[right][up] == 0:
					moves.append([piece, Vector2(right, up), []])	
	return moves

func get_jumps(board, piece):
	var moves = []
	var left = piece.x-1
	var right = piece.x+1
	var up = piece.y-1
	var down = piece.y+1

	if board[piece.x][piece.y] > 0 or abs(board[piece.x][piece.y]) > 1:

		if down >= 0 and down <=7:
			if left >= 0 and left <= 7:
				if (board[left][down]*board[piece.x][piece.y]) < 0:
					if down+1 >= 0 and down+1 <=7:
						if left-1 >= 0 and left-1 <= 7:
							if board[left-1][down+1] == 0:
								var skip = Vector2(left, down)
								var end = Vector2(left-1, down+1)
								var new_board = simulate_move(board, piece, end, [skip])
								var temp_move = get_jumps(new_board, end)
								
								if temp_move == []:
									moves.append([piece, end, [skip]])
								else:
									for move in temp_move:
										var skipped = move[2]
										skipped.append(skip)
										moves.append([piece, move[1], skipped])
								
			if right >= 0 and right <= 7:
				if (board[right][down]*board[piece.x][piece.y]) < 0:
					if down+1 >= 0 and down+1 <=7:
						if right+1 >= 0 and right+1 <= 7:
							if board[right+1][down+1] == 0:
								var skip = Vector2(right, down)
								var end = Vector2(right+1, down+1)
								var new_board = simulate_move(board, piece, end, [skip])
								var temp_move = get_jumps(new_board, end)
								
								if temp_move == []:
									moves.append([piece, end, [skip]])
								else:
									for move in temp_move:
										var skipped = move[2]
										skipped.append(skip)
										moves.append([piece, move[1], skipped])
		
	if board[piece.x][piece.y] < 0 or abs(board[piece.x][piece.y]) > 1:
		if up >= 0 and up <=7:
			if left >= 0 and left <= 7:
				if (board[left][up]*board[piece.x][piece.y]) < 0:
					if up-1 >= 0 and up-1 <=7:
						if left-1 >= 0 and left-1 <= 7:
							if board[left-1][up-1] == 0:
								var skip = Vector2(left, up)
								var end = Vector2(left-1, up-1)
								var new_board = simulate_move(board, piece, end, [skip])
								var temp_move = get_jumps(new_board, end)
								
								if temp_move == []:
									moves.append([piece, end, [skip]])
								else:
									for move in temp_move:
										var skipped = move[2]
										skipped.append(skip)
										moves.append([piece, move[1], skipped])
								
			if right >= 0 and right <= 7:
				if (board[right][up]*board[piece.x][piece.y]) < 0:
					if up-1 >= 0 and up-1 <=7:
						if right+1 >= 0 and right+1 <= 7:
							if board[right+1][up-1] == 0:
								var skip = Vector2(right, up)
								var end = Vector2(right+1, up-1)
								var new_board = simulate_move(board, piece, end, [skip])
								var temp_move = get_jumps(new_board, end)
								
								if temp_move == []:
									moves.append([piece, end, [skip]])
								else:
									for move in temp_move:
										var skipped = move[2]
										skipped.append(skip)
										moves.append([piece, move[1], skipped])
	return moves
	

func simulate_move(board, start, end, skip):
	var new_board = board.duplicate(true)
	var temp = new_board[start.x][start.y]
	new_board[start.x][start.y] = new_board[end.x][end.y]
	new_board[end.x][end.y] = temp
	
	for piece in skip:
		new_board[piece.x][piece.y] = 0
	
	return new_board
