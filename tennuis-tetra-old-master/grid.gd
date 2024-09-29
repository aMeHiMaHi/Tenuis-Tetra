extends Node2D

# Constants for the grid size and cell size
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32

# Define Tetromino shapes and their colors
const TETROMINOS = [
	{ "shape": [
				[[0, 0, 0, 0], [1, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0]],   # I shape horizontal
				[[0, 0, 1, 0], [0, 0, 1, 0], [0, 0, 1, 0], [0, 0, 1, 0]],   # I shape vertical
				[[0, 0, 0, 0], [0, 0, 0, 0], [1, 1, 1, 1], [0, 0, 0, 0]],   # I shape horizontal (repeated)
				[[0, 1, 0, 0], [0, 1, 0, 0], [0, 1, 0, 0], [0, 1, 0, 0]]    # I shape vertical (repeated)
				], 
	  "color": Color(0, 1, 1) },  # Cyan
				  
	{ "shape": [
				[[1, 1], [1, 1]]              # O shape
				],           
	  "color": Color(1, 1, 0) },  # Yellow

	{ "shape": [
				[[0, 1, 0], [1, 1, 1]],      # T shape original
				[[0, 1], [1, 1], [0, 1]],    # T shape rotated 90
				[[1, 1, 1], [0, 1, 0]],      # T shape rotated 180
				[[1, 0], [1, 1], [1, 0]]     # T shape rotated 270
				],      
	  "color": Color(0.5, 0, 0.5) },  # Purple

	{ "shape": [
				[[0, 1, 1], [1, 1, 0]],      # S shape original
				[[1, 0], [1, 1], [0, 1]],    # S shape rotated 90
				[[0, 1, 1], [1, 1, 0]],      # S shape repeated original
				[[1, 0], [1, 1], [0, 1]]     # S shape repeated rotated 90
				],      
	  "color": Color(0, 1, 0) },  # Green

	{ "shape": [
				[[1, 1, 0], [0, 1, 1]],      # Z shape original
				[[0, 1], [1, 1], [1, 0]],    # Z shape rotated 90
				[[1, 1, 0], [0, 1, 1]],      # Z shape repeated original
				[[0, 1], [1, 1], [1, 0]]     # Z shape repeated rotated 90
				],      
	  "color": Color(1, 0, 0) },  # Red

	{ "shape": [
				[[1, 0, 0], [1, 1, 1]],      # J shape original
				[[1, 1], [1, 0], [1, 0]],    # J shape rotated 90
				[[1, 1, 1], [0, 0, 1]],      # J shape rotated 180
				[[0, 1], [0, 1], [1, 1]]     # J shape rotated 270
				],      
	  "color": Color(0, 0, 1) },  # Blue

	{ "shape": [
				[[0, 0, 1], [1, 1, 1]],      # L shape original
				[[1, 0], [1, 0], [1, 1]],    # L shape rotated 90
				[[1, 1, 1], [1, 0, 0]],      # L shape rotated 180
				[[1, 1], [0, 1], [0, 1]]     # L shape rotated 270
				],      
	  "color": Color(1, 0.5, 0) }  # Orange
]



const KICK_TABLE = {
	"I": [Vector2(0, 0), Vector2(-2, 0), Vector2(1, 0), Vector2(-2, -1), Vector2(1, 2)],
	"other": [Vector2(0, 0), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, -1), Vector2(1, -1)]
}

var grid = []
var current_piece
var current_position = Vector2(0, 0)
var current_rotation = 0

var held_piece = null
var hold_used = false  # To track if hold is used in the current turn

var fall_speed = 0.2
var time_since_last_fall = 0.0

var lock_timer = 0.0
var lock_delay = 0.5

var das_delay = 0.35  # DAS delay in seconds
var das_timer = 0.03
var das_direction = Vector2()

var soft_drop = false  # Track if the down key is being held

func _ready():
	initialize_grid()
	spawn_new_piece()
	queue_redraw()

func _process(delta):
	time_since_last_fall += delta
	if time_since_last_fall >= fall_speed or soft_drop:
		time_since_last_fall = 0.0
		move_piece(Vector2(0, 1)) # Move the piece down automatically or due to soft drop
	
	if das_direction != Vector2():
		das_timer += delta
		if das_timer >= das_delay:
			das_timer = 0.0
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
	current_piece = TETROMINOS[randi() % TETROMINOS.size()]
	current_position = Vector2(GRID_WIDTH / 2 - 2, 0)
	current_rotation = 0
	lock_timer = 0.0
	hold_used = false

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

func clear_lines():
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
			return true

func rotate_piece():
	var new_rotation = (current_rotation + 1) % current_piece["shape"].size()
	var rotated_shape = current_piece["shape"][new_rotation]
	if can_move_to(current_position, rotated_shape):
		current_rotation = new_rotation
		lock_timer = 0.0
		queue_redraw()
	else:
		for kick in KICK_TABLE["other"]:
			var kick_position = current_position + kick
			if can_move_to(kick_position, rotated_shape):
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
	else:
		for kick in KICK_TABLE["other"]:
			var kick_position = current_position + kick
			if can_move_to(kick_position, rotated_shape):
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
			elif event.keycode == KEY_RIGHT:
				move_piece(Vector2(1, 0))
				das_direction = Vector2(1, 0)  # Start DAS for right movement
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
