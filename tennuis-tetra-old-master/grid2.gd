extends Node2D
# Declare the font variable
var my_font: FontFile
var next_pieces = []
var das_delay = 0.35  # DAS delay in seconds before DAS activates
var das_repeat_rate = 0.05  # Time in seconds for repeated movement after DAS activates
var das_timer = 0.0
# Constants for the grid size and cell size
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32

var bag = []
var score = 0
var level = 1
var lines_cleared = 0
var game_over = false

# Define Tetromino shapes and their colors
const TETROMINOS = [
	{ "shape": [
				[[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 1, 1, 1, 1], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],   # I shape horizontal
				[[0, 0, 0, 0, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0]],   # I shape vertical
				[[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [1, 1, 1, 1, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],   # I shape horizontal (repeated)
				[[0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [0, 0, 1, 0, 0], [0, 0, 0, 0, 0]]    # I shape vertical (repeated)
				], 
	  "color": Color(0, 1, 1), # Cyan
	  "name" : "I"},

	{ "shape": [
				[[0, 1, 1], [0, 1, 1], [0, 0, 0]],   # O shape original
				[[0, 0, 0], [0, 1, 1], [0, 1, 1]],   # O shape rotated 90
				[[0, 0, 0], [1, 1, 0], [1, 1, 0]],   # O shape rotated 180
				[[1, 1, 0], [1, 1, 0], [0, 0, 0]],   # O shape rotated 270
				],           
	  "color": Color(1, 1, 0),   # Yellow
	  "name" : "O"},

	{ "shape": [
				[[0, 1, 0], [1, 1, 1], [0, 0, 0]],    # T shape original
				[[0, 1, 0], [0, 1, 1], [0, 1, 0]],    # T shape rotated 90
				[[0, 0, 0], [1, 1, 1], [0, 1, 0]],    # T shape rotated 180
				[[0, 1, 0], [1, 1, 0], [0, 1, 0]]     # T shape rotated 270
				],      
	  "color": Color(0.5, 0, 0.5), # Purple
	  "name" : "other" }, 

	{ "shape": [
				[[0, 1, 1], [1, 1, 0], [0, 0, 0]],    # S shape original
				[[0, 1, 0], [0, 1, 1], [0, 0, 1]],    # S shape rotated 90
				[[0, 0, 0], [0, 1, 1], [1, 1, 0]],    # S shape rotated 180
				[[1, 0, 0], [1, 1, 0], [0, 1, 0]]     # S shape rotated 270
				],      
	  "color": Color(0, 1, 0),  # Green
	  "name" : "other" }, 

	{ "shape": [
				[[1, 1, 0], [0, 1, 1], [0, 0, 0]],    # Z shape original
				[[0, 0, 1], [0, 1, 1], [0, 1, 0]],    # Z shape rotated 90
				[[0, 0, 0], [1, 1, 0], [0, 1, 1]],    # Z shape rotated 180
				[[0, 1, 0], [1, 1, 0], [1, 0, 0]]     # Z shape rotated 270
				],      
	  "color": Color(1, 0, 0), # Red
	  "name" : "other" },  

	{ "shape": [
				[[1, 0, 0], [1, 1, 1], [0, 0, 0]],    # J shape original
				[[0, 1, 1], [0, 1, 0], [0, 1, 0]],    # J shape rotated 90
				[[0, 0, 0], [1, 1, 1], [0, 0, 1]],    # J shape rotated 180
				[[0, 1, 0], [0, 1, 0], [1, 1, 0]]     # J shape rotated 270
				],      
	  "color": Color(0, 0, 1), # Blue
	  "name" : "other" },  

	{ "shape": [
				[[0, 0, 1], [1, 1, 1], [0, 0, 0]],    # L shape original
				[[0, 1, 0], [0, 1, 0], [0, 1, 1]],    # L shape rotated 90
				[[0, 0, 0], [1, 1, 1], [1, 0, 0]],    # L shape rotated 180
				[[1, 1, 0], [0, 1, 0], [0, 1, 0]]     # L shape rotated 270
				],      
	  "color": Color(1, 0.5, 0), # Orange
	  "name" : "other" } 
]
const KICK_TABLE = {
	"I1": [Vector2(-1, 0), Vector2(1, 0), Vector2(-2, 0), Vector2(1, -1), Vector2(-2, 2)],
	"I2": [Vector2(-1, -1), Vector2(0, -1), Vector2(3, -1), Vector2(0, 1), Vector2(-3, -2)],
	"I3": [Vector2(0, -1), Vector2(-2, -1), Vector2(1, -1), Vector2(-2, 0), Vector2(1, 2)],
	"I0": [Vector2(0, 0), Vector2(-1, 0), Vector2(2, 0), Vector2(-1, -2), Vector2(2, 1)],
	"O0": [Vector2(0, 0)],
	"O1": [Vector2(0, 1)], 
	"O2": [Vector2(-1, 1)], 
	"O3": [Vector2(-1, 0)],
	"other0": [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(0, 2), Vector2(1, 2)],
	"other1": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, -2), Vector2(1, -2)],
	"other2": [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)],
	"other3": [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)]
}
var grid = []
var current_piece
var current_position = Vector2(0, 0)
var current_rotation = 0
var last_kick = Vector2(0, 0)

var held_piece = null
var hold_used = false  # To track if hold is used in the current turn

var fall_speed = 0.5
var time_since_last_fall = 0.0

var lock_timer = 0.0
var lock_delay = 0.5
var das_direction = Vector2()

var soft_drop = false  # Track if the down key is being held

func _ready():
	# Load the font file into a FontFile object
	my_font = load("res://mettaton-ex.otf")  # Replace with your actual font path
	initialize_grid()
	spawn_new_piece()
	queue_redraw()

func _process(delta):
	if game_over:
		return

	time_since_last_fall += delta
	if time_since_last_fall >= fall_speed or soft_drop:
		time_since_last_fall = 0.0
		move_piece(Vector2(0, 1))  # Move the piece down automatically or due to soft drop

	if das_direction != Vector2():
		das_timer += delta
		if das_timer >= das_delay:
			# Start continuous movement
			das_timer -= das_repeat_rate  # Subtract the repeat rate to allow for continuous movement
			move_piece(das_direction)
	
	# Handle locking after the delay
	if not can_move_to(current_position + Vector2(0, 1), current_piece["shape"][current_rotation]):
		lock_timer += delta
		if lock_timer >= lock_delay:
			lock_piece()
	else:
		lock_timer = 0.0  # Reset the lock timer if the piece can still move

func initialize_grid():
	for i in range(GRID_HEIGHT):
		var row = []
		for j in range(GRID_WIDTH):
			row.append(0)
		grid.append(row)

func spawn_new_piece():
	if game_over:
		return  # Do nothing if the game is already over

	# Fill the bag and next_pieces queue if empty
	if bag == []:
		bag = TETROMINOS.duplicate()
		bag.shuffle()

	while next_pieces.size() < 5:
		next_pieces.append(bag.pop_back())

	# Get the next piece from the queue
	current_piece = next_pieces.pop_front()

	# Add a new piece to the queue
	if bag == []:
		bag = TETROMINOS.duplicate()
		bag.shuffle()
	next_pieces.append(bag.pop_back())

	current_position = Vector2(GRID_WIDTH / 2 - 2, 0)
	current_rotation = 0
	lock_timer = 0.0
	hold_used = false

	# Check if the piece can be placed in the initial position
	if not can_move_to(current_position, current_piece["shape"][current_rotation]):
		game_over = true  # Game over if there's no space for a new piece
		print("Game Over! Score: " + str(score))


func move_piece(direction: Vector2):
	var new_position = current_position + direction
	if can_move_to(new_position, current_piece["shape"][current_rotation]):
		current_position = new_position
		lock_timer = 0.0
		queue_redraw()

func lock_piece():
	var shape = current_piece["shape"][current_rotation]
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] != 0:
				var grid_x = current_position.x + x
				var grid_y = current_position.y + y
				grid[grid_y][grid_x] = 1
	while clear_lines():
		clear_lines()
	spawn_new_piece()
func draw_next_pieces():
	var next_position = Vector2(400, 50)  # Adjust this to position the display on the screen
	for i in range(next_pieces.size()):
		var next_piece = next_pieces[i]
		var shape = next_piece["shape"][0]  # Always show the default rotation for preview
		var piece_position = next_position + Vector2(0, i * 100)  # Stack pieces vertically

		for y in range(shape.size()):
			for x in range(shape[y].size()):
				if shape[y][x] != 0:
					var cell_position = piece_position + Vector2(x * CELL_SIZE / 2, y * CELL_SIZE / 2)  # Smaller size
					draw_rect(Rect2(cell_position, Vector2(CELL_SIZE / 2, CELL_SIZE / 2)), next_piece["color"])

func clear_lines():
	var lines_cleared_in_this_move = 0
	for y in range(GRID_HEIGHT - 1, -1, -1):
		var is_full_line = true
		for x in range(GRID_WIDTH):
			if grid[y][x] == 0:
				is_full_line = false
				break
		if is_full_line:
			for row in range(y, 0, -1):
				grid[row] = grid[row - 1].duplicate()
			grid[0] = Array()
			for i in range(GRID_WIDTH):
				grid[0].append(0)
			lines_cleared_in_this_move += 1

	# Score calculation based on the number of lines cleared
	if lines_cleared_in_this_move > 0:
		lines_cleared += lines_cleared_in_this_move
		update_score(lines_cleared_in_this_move)

		# Increase level every 10 lines cleared
		level = (lines_cleared / 10) + 1
		update_fall_speed()
	
	return lines_cleared_in_this_move > 0

func update_score(lines_cleared_in_this_move):
	var line_score = 0
	match lines_cleared_in_this_move:
		1:
			line_score = 40
		2:
			line_score = 100
		3:
			line_score = 300
		4:
			line_score = 1200
	score += line_score * level

func update_fall_speed():
	fall_speed = max(0.05, 0.5 - (level - 1) * 0.05)

func rotate_piece():
	var new_rotation = (current_rotation + 1) % current_piece["shape"].size()
	var rotated_shape = current_piece["shape"][new_rotation]
	if can_move_to(current_position, rotated_shape):
		current_rotation = new_rotation
		lock_timer = 0.0
		queue_redraw()
	for kick in KICK_TABLE[current_piece["name"] + str(new_rotation)]:
		var kick_position = current_position + (last_kick - kick)
		if can_move_to(kick_position, rotated_shape):
			last_kick = kick
			current_position = kick_position
			current_rotation = new_rotation
			lock_timer = 0.0
			queue_redraw()
			break

func rotate_piece_ccw():
	var new_rotation = (current_rotation - 1 + current_piece["shape"].size()) % current_piece["shape"].size()
	var rotated_shape = current_piece["shape"][new_rotation]
	if can_move_to(current_position, rotated_shape):
		current_rotation = new_rotation
		lock_timer = 0.0
		queue_redraw()
	for kick in KICK_TABLE[current_piece["name"] + str(new_rotation)]:
		var kick_position = current_position + (last_kick - kick)
		if can_move_to(kick_position, rotated_shape):
			last_kick = kick
			current_position = kick_position
			current_rotation = new_rotation
			lock_timer = 0.0
			queue_redraw()
			break

func can_move_to(position: Vector2, shape: Array) -> bool:
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] != 0:
				var grid_x = position.x + x
				var grid_y = position.y + y
				if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y >= GRID_HEIGHT or grid[grid_y][grid_x] != 0:
					return false
	return true

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_LEFT:
				move_piece(Vector2(-1, 0))
				das_direction = Vector2(-1, 0)  # Start DAS for left movement
				das_timer = 0.0  # Reset DAS timer
			elif event.keycode == KEY_RIGHT:
				move_piece(Vector2(1, 0))
				das_direction = Vector2(1, 0)  # Start DAS for right movement
				das_timer = 0.0  # Reset DAS timer
			elif event.keycode == KEY_DOWN:
				soft_drop = true  # Enable continuous downward movement
			elif event.keycode == KEY_Z or event.keycode == KEY_UP:
				rotate_piece()
			elif event.keycode == KEY_X:
				rotate_piece_ccw()
			elif event.keycode == KEY_SPACE:
				hard_drop()
			elif event.keycode == KEY_C:
				hold_piece()
		elif event.is_released():
			if event.keycode == KEY_LEFT or event.keycode == KEY_RIGHT:
				das_direction = Vector2()  # Stop DAS when the key is released
				das_timer = 0.0  # Reset DAS timer
			elif event.keycode == KEY_DOWN:
				soft_drop = false  # Stop continuous downward movement

func hard_drop():
	while can_move_to(current_position + Vector2(0, 1), current_piece["shape"][current_rotation]):
		move_piece(Vector2(0, 1))
	lock_piece()

func hold_piece():
	if hold_used:
		return

	if held_piece == null:
		held_piece = current_piece
		spawn_new_piece()
	else:
		var temp = current_piece
		current_piece = held_piece
		held_piece = temp
		current_position = Vector2(GRID_WIDTH / 2 - 2, 0)
		current_rotation = 0
		lock_timer = 0.0

	hold_used = true

func _draw():
	var screen_size = get_viewport_rect().size
	var grid_size = Vector2(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	var start_position = (screen_size - grid_size) / 2

	# Draw the grid
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var cell_position = start_position + Vector2(x * CELL_SIZE, y * CELL_SIZE)
			if grid[y][x] != 0:
				draw_rect(Rect2(cell_position, Vector2(CELL_SIZE, CELL_SIZE)), Color(0.5, 0.5, 0.5))
			else:
				draw_rect(Rect2(cell_position, Vector2(CELL_SIZE, CELL_SIZE)), Color(1, 1, 1), false)

	# Draw the current piece
	if not game_over:
		var shape = current_piece["shape"][current_rotation]
		for y in range(shape.size()):
			for x in range(shape[y].size()):
				if shape[y][x] != 0:
					var cell_position = start_position + Vector2((current_position.x + x) * CELL_SIZE, (current_position.y + y) * CELL_SIZE)
					draw_rect(Rect2(cell_position, Vector2(CELL_SIZE, CELL_SIZE)), current_piece["color"])

	# Draw the ghost piece
	draw_ghost_piece(start_position)

	# Optional: Draw the held piece (if any)
	if held_piece != null:
		var held_position = Vector2(50, 50)
		var held_shape = held_piece["shape"][0]
		for y in range(held_shape.size()):
			for x in range(held_shape[y].size()):
				if held_shape[y][x] != 0:
					var cell_position = held_position + Vector2(x * CELL_SIZE, y * CELL_SIZE)
					draw_rect(Rect2(cell_position, Vector2(CELL_SIZE, CELL_SIZE)), held_piece["color"])

	# Draw the score and level
	draw_string(my_font, Vector2(10, 30), "Score: " + str(score))
	draw_string(my_font, Vector2(10, 60), "Level: " + str(level))

	# Draw the next pieces
	draw_next_pieces()

	# Draw game over text
	if game_over:
		draw_string(my_font, Vector2(screen_size.x / 2 - 50, screen_size.y / 2), "Game Over")


func draw_ghost_piece(start_position):
	var ghost_position = current_position
	while can_move_to(ghost_position + Vector2(0, 1), current_piece["shape"][current_rotation]):
		ghost_position += Vector2(0, 1)

	var shape = current_piece["shape"][current_rotation]
	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] != 0:
				var cell_position = start_position + Vector2((ghost_position.x + x) * CELL_SIZE, (ghost_position.y + y) * CELL_SIZE)
				draw_rect(Rect2(cell_position, Vector2(CELL_SIZE, CELL_SIZE)), current_piece["color"].lightened(0.5), false)
